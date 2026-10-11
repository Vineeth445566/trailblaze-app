import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../models/trail.dart';
import '../services/storage_service.dart';
import 'record_screen.dart' show formatHikeDuration, formatHikeDate;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _storage = StorageService();
  List<RecordedHike> _hikes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final hikes = await _storage.getHikes();
    if (mounted) {
      setState(() {
        _hikes = hikes;
        _loading = false;
      });
    }
  }

  Future<void> _delete(RecordedHike hike) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete hike?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _storage.deleteHike(hike.id);
      _load();
    }
  }

  double get _totalMiles =>
      _hikes.fold(0.0, (sum, h) => sum + h.distanceMiles);
  int get _totalElev =>
      _hikes.fold(0, (sum, h) => sum + h.elevationGainFt);
  Duration get _totalTime =>
      _hikes.fold(Duration.zero, (sum, h) => sum + h.duration);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Hike history')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _hikes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.hiking,
                          size: 64,
                          color: scheme.onSurfaceVariant),
                      const SizedBox(height: 12),
                      const Text(
                        'No hikes recorded yet.',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Head to the Record tab to track your first hike.',
                        style: TextStyle(
                            color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _statsHeader(scheme),
                      const SizedBox(height: 12),
                      for (final h in _hikes) _hikeCard(h, scheme),
                    ],
                  ),
                ),
    );
  }

  Widget _statsHeader(ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _total('Total', _totalMiles.toStringAsFixed(1), 'mi'),
          _total('Hikes', '${_hikes.length}', ''),
          _total('Elev', '${(_totalElev / 1000).toStringAsFixed(1)}k', 'ft'),
          _total('Time', formatHikeDuration(_totalTime), ''),
        ],
      ),
    );
  }

  Widget _total(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          unit.isEmpty ? value : '$value $unit',
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _hikeCard(RecordedHike h, ColorScheme scheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showHikeDetail(h),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.hiking, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      h.trailName ?? 'Freestyle hike',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatHikeDate(h.startTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${h.distanceMiles.toStringAsFixed(2)} mi · '
                      '${formatHikeDuration(h.duration)} · '
                      '${h.elevationGainFt} ft',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _delete(h),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHikeDetail(RecordedHike h) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        builder: (ctx, scrollCtrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    h.trailName ?? 'Freestyle hike',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatHikeDate(h.startTime)} · '
                    '${h.distanceMiles.toStringAsFixed(2)} miles · '
                    '${formatHikeDuration(h.duration)} · '
                    '${h.elevationGainFt} ft gain',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              child: h.path.length > 1
                  ? FlutterMap(
                      options: MapOptions(
                        initialCenter: h.path.first,
                        initialZoom: 14,
                        interactionOptions:
                            const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                              'com.vineeth.trail_blaze',
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: h.path,
                              color: Colors.blue,
                              strokeWidth: 5,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: h.path.first,
                              width: 36,
                              height: 36,
                              child: const Icon(
                                  Icons.location_on,
                                  color: Colors.green,
                                  size: 32),
                            ),
                            Marker(
                              point: h.path.last,
                              width: 36,
                              height: 36,
                              child: const Icon(
                                  Icons.flag,
                                  color: Colors.red,
                                  size: 30),
                            ),
                          ],
                        ),
                      ],
                    )
                  : const Center(
                      child:
                          Text('Not enough GPS points to draw a map.'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
