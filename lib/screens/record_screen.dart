import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../models/trail.dart';
import '../services/storage_service.dart';
import '../widgets/trail_map.dart';
import '../widgets/trail_widgets.dart';

enum _RecState { idle, recording, paused, done }

/// GPS hike recorder: start/pause/stop with live stats and a live map.
class RecordScreen extends StatefulWidget {
  final Trail? trail;

  const RecordScreen({super.key, this.trail});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final _storage = StorageService();

  _RecState _state = _RecState.idle;
  StreamSubscription<Position>? _posSub;
  Timer? _tick;

  final List<LatLng> _path = [];
  double _distanceMeters = 0;
  double _elevationGainM = 0;
  Position? _lastPos;
  LatLng? _currentLatLng;

  final Stopwatch _stopwatch = Stopwatch();
  Duration _displayElapsed = Duration.zero;

  String? _permMessage; // shown when permissions block recording
  bool _checkingPerm = false;

  static const _defaultCenter = LatLng(39.8283, -98.5795);

  @override
  void dispose() {
    _posSub?.cancel();
    _tick?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  // ---------- permission flow ----------
  Future<bool> _ensurePermission() async {
    setState(() {
      _checkingPerm = true;
      _permMessage = null;
    });
    try {
      final serviceOn = await Geolocator.isLocationServiceEnabled();
      if (!serviceOn) {
        setState(() {
          _permMessage =
              'Location services are off. Turn them on to record your hike.';
          _checkingPerm = false;
        });
        return false;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied) {
        setState(() {
          _permMessage =
              'Location permission was denied. TrailBlaze needs it to track your hike.';
          _checkingPerm = false;
        });
        return false;
      }
      if (perm == LocationPermission.deniedForever) {
        setState(() {
          _permMessage =
              'Location permission is permanently denied. Open Settings > Apps > TrailBlaze > Permissions and allow Location.';
          _checkingPerm = false;
        });
        return false;
      }
      setState(() => _checkingPerm = false);
      return true;
    } catch (e) {
      setState(() {
        _permMessage = 'Could not access location: $e';
        _checkingPerm = false;
      });
      return false;
    }
  }

  // ---------- recording ----------
  Future<void> _start() async {
    final ok = await _ensurePermission();
    if (!ok || !mounted) return;
    setState(() {
      _state = _RecState.recording;
      _path.clear();
      _distanceMeters = 0;
      _elevationGainM = 0;
      _lastPos = null;
      _stopwatch
        ..reset()
        ..start();
    });
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _displayElapsed = _stopwatch.elapsed);
      }
    });
    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen(_onPosition, onError: (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('GPS error: $e')),
        );
      }
    });
  }

  void _onPosition(Position pos) {
    if (_state != _RecState.recording || !mounted) return;
    // Ignore wildly inaccurate fixes.
    if (pos.accuracy > 50) return;
    setState(() {
      _currentLatLng = LatLng(pos.latitude, pos.longitude);
      if (_lastPos != null) {
        _distanceMeters += Geolocator.distanceBetween(
          _lastPos!.latitude,
          _lastPos!.longitude,
          pos.latitude,
          pos.longitude,
        );
        final dAlt = pos.altitude - _lastPos!.altitude;
        if (dAlt > 2) _elevationGainM += dAlt; // noise threshold
      }
      _lastPos = pos;
      _path.add(LatLng(pos.latitude, pos.longitude));
    });
  }

  void _pause() {
    _stopwatch.stop();
    setState(() => _state = _RecState.paused);
  }

  void _resume() {
    _stopwatch.start();
    setState(() => _state = _RecState.recording);
  }

  Future<void> _stop() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Finish hike?'),
        content: const Text(
            'This will stop GPS tracking and save your hike.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep going'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Finish'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await _posSub?.cancel();
    _tick?.cancel();
    _stopwatch.stop();
    final now = DateTime.now();
    final hike = RecordedHike(
      id: now.millisecondsSinceEpoch.toString(),
      trailId: widget.trail?.id,
      trailName: widget.trail?.name,
      startTime: now.subtract(_stopwatch.elapsed),
      endTime: now,
      distanceMiles: _distanceMeters / 1609.34,
      elevationGainFt: (_elevationGainM * 3.28084).round(),
      path: List.of(_path),
    );
    await _storage.saveHike(hike);
    if (mounted) setState(() => _state = _RecState.done);
  }

  void _reset() {
    setState(() {
      _state = _RecState.idle;
      _path.clear();
      _distanceMeters = 0;
      _elevationGainM = 0;
      _lastPos = null;
      _currentLatLng = null;
      _displayElapsed = Duration.zero;
      _stopwatch.reset();
    });
  }

  // ---------- formatting ----------
  String get _distanceStr =>
      '${(_distanceMeters / 1609.34).toStringAsFixed(2)} mi';

  String get _durationStr {
    final e = _displayElapsed;
    final h = e.inHours.toString().padLeft(2, '0');
    final m = (e.inMinutes % 60).toString().padLeft(2, '0');
    final s = (e.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String get _paceStr {
    final miles = _distanceMeters / 1609.34;
    if (miles < 0.05) return '--:--';
    final minPerMile = _displayElapsed.inSeconds / 60 / miles;
    final m = minPerMile.floor();
    final s = ((minPerMile - m) * 60).round();
    return '$m:${s.toString().padLeft(2, '0')} /mi';
  }

  String get _elevStr =>
      '${(_elevationGainM * 3.28084).round()} ft';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trail?.name ?? 'Record hike'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Live stats
          Container(
            padding: const EdgeInsets.all(16),
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
            child: Row(
              children: [
                StatTile(
                    icon: Icons.route,
                    value: _distanceStr,
                    label: 'Distance'),
                const SizedBox(width: 8),
                StatTile(
                    icon: Icons.timer,
                    value: _durationStr,
                    label: 'Time'),
                const SizedBox(width: 8),
                StatTile(
                    icon: Icons.trending_up,
                    value: _elevStr,
                    label: 'Elev gain'),
                const SizedBox(width: 8),
                StatTile(
                    icon: Icons.speed,
                    value: _paceStr,
                    label: 'Pace'),
              ],
            ),
          ),
          if (_permMessage != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_off,
                      color: scheme.onErrorContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _permMessage!,
                      style: TextStyle(
                          color: scheme.onErrorContainer,
                          fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Geolocator.openAppSettings(),
                    child: const Text('Settings'),
                  ),
                ],
              ),
            ),
          // Map
          Expanded(
            child: TrailMapView(
              routePoints: const [],
              trailhead: _currentLatLng ?? _defaultCenter,
              livePath: _path,
              livePosition: _currentLatLng,
              initialZoom: _currentLatLng != null ? 15 : 11,
            ),
          ),
          // Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildControls(scheme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(ColorScheme scheme) {
    if (_checkingPerm) {
      return const Center(child: CircularProgressIndicator());
    }
    switch (_state) {
      case _RecState.idle:
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start recording'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: _start,
          ),
        );
      case _RecState.recording:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.pause),
                label: const Text('Pause'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _pause,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.stop),
                label: const Text('Finish'),
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _stop,
              ),
            ),
          ],
        );
      case _RecState.paused:
        return Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Resume'),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _resume,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.stop),
                label: const Text('Finish'),
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _stop,
              ),
            ),
          ],
        );
      case _RecState.done:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle,
                      color: scheme.primary, size: 40),
                  const SizedBox(height: 8),
                  const Text(
                    'Hike saved!',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_distanceStr in $_durationStr · $_elevStr gain',
                    style: TextStyle(
                        color: scheme.onPrimaryContainer),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Record another'),
                onPressed: _reset,
              ),
            ),
          ],
        );
    }
  }
}

/// Formats a [RecordedHike] duration for list display.
String formatHikeDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  if (h > 0) return '${h}h ${m}m';
  return '${m}m';
}

/// Formats a date for list display.
String formatHikeDate(DateTime d) =>
    DateFormat('MMM d, yyyy · h:mm a').format(d);
