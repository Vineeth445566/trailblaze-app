import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/trail.dart';

/// Full-screen interactive trail map, opened by tapping the map preview.
/// Shows the route on a topo map, waypoint markers, an elevation profile,
/// trail stats, and Directions / Record actions.
class TrailMapFullscreenScreen extends StatefulWidget {
  final Trail trail;

  const TrailMapFullscreenScreen({super.key, required this.trail});

  @override
  State<TrailMapFullscreenScreen> createState() =>
      _TrailMapFullscreenScreenState();
}

class _TrailMapFullscreenScreenState
    extends State<TrailMapFullscreenScreen> {
  late final List<double> _elevationProfile;
  late final List<_Waypoint> _waypoints;
  bool _satellite = false;

  @override
  void initState() {
    super.initState();
    _elevationProfile = _buildElevationProfile();
    _waypoints = _buildWaypoints();
  }

  /// Synthetic elevation profile shaped by the trail's published gain.
  /// Clearly approximate — matches the approximate route disclaimer.
  List<double> _buildElevationProfile() {
    final rand = Random(widget.trail.id.hashCode);
    const n = 60;
    final gain = widget.trail.elevationGainFt.toDouble();
    final pts = <double>[];
    var elev = 0.0;
    for (var i = 0; i < n; i++) {
      final t = i / (n - 1);
      // General climb toward the summit with rolling variation.
      final target = gain * (0.55 * t + 0.45 * sin(t * pi * 0.9));
      elev += (target - elev) * 0.25 +
          (rand.nextDouble() - 0.5) * gain * 0.03;
      pts.add(elev.clamp(0, gain * 1.15));
    }
    return pts;
  }

  /// Waypoints: start, a mid highlight, and the destination, labeled
  /// from the trail name and tags.
  List<_Waypoint> _buildWaypoints() {
    final pts = widget.trail.routePoints;
    if (pts.isEmpty) return [];
    final name = widget.trail.name;
    // Derive a destination label from the trail name.
    final destLabel = name.contains('via')
        ? name.split('via').first.trim()
        : name;
    final wps = <_Waypoint>[
      _Waypoint(point: pts.first, label: 'Trailhead'),
    ];
    if (pts.length > 4) {
      wps.add(_Waypoint(
        point: pts[pts.length ~/ 2],
        label: widget.trail.tags.isNotEmpty
            ? widget.trail.tags.first
            : 'Viewpoint',
      ));
    }
    wps.add(_Waypoint(point: pts.last, label: destLabel));
    return wps;
  }

  Future<void> _openDirections() async {
    final t = widget.trail;
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination='
      '${t.lat},${t.lng}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open maps.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trail;
    final scheme = Theme.of(context).colorScheme;
    // Rough elevation loss estimate for the stats row.
    final loss = (t.elevationGainFt * 0.85).round();

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen map with route + waypoint markers.
          _FullMap(
            trail: t,
            satellite: _satellite,
            elevationProfile: _elevationProfile,
            waypoints: _waypoints,
          ),
          // Back button.
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
          // Map type toggle (topo / satellite).
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: Icon(
                        _satellite
                            ? Icons.terrain
                            : Icons.satellite_alt,
                        color: Colors.white),
                    tooltip: _satellite
                        ? 'Topo map'
                        : 'Satellite',
                    onPressed: () =>
                        setState(() => _satellite = !_satellite),
                  ),
                ),
              ],
            ),
          ),
          // Bottom info card.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20)),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, -2))
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: scheme.onSurfaceVariant
                              .withValues(alpha: 0.4),
                          borderRadius:
                              BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(t.name,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      '${t.lengthMiles.toStringAsFixed(1)} mi  •  '
                      '▲ ${t.elevationGainFt} ft  •  '
                      '▼ $loss ft',
                      style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    // Elevation profile.
                    SizedBox(
                      height: 90,
                      child: _ElevationProfile(
                          points: _elevationProfile),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.directions),
                            label:
                                const Text('Directions'),
                            onPressed: _openDirections,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            icon: const Icon(
                                Icons.play_circle_outline),
                            label: const Text('Start hike'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              // The detail screen's Record button
                              // handles GPS recording.
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Waypoint {
  final LatLng point;
  final String label;
  const _Waypoint({required this.point, required this.label});
}

/// Full-screen interactive map: topo or satellite base layer, route
/// polyline auto-fitted, waypoint markers.
class _FullMap extends StatefulWidget {
  final Trail trail;
  final bool satellite;
  final List<double> elevationProfile;
  final List<_Waypoint> waypoints;

  const _FullMap({
    required this.trail,
    required this.satellite,
    required this.elevationProfile,
    required this.waypoints,
  });

  @override
  State<_FullMap> createState() => _FullMapState();
}

class _FullMapState extends State<_FullMap> {
  final MapController _controller = MapController();
  bool _fitted = false;

  void _fitRoute() {
    final pts = widget.trail.routePoints;
    if (_fitted || pts.isEmpty) return;
    _fitted = true;
    var minLat = pts.first.latitude;
    var maxLat = minLat;
    var minLng = pts.first.longitude;
    var maxLng = minLng;
    for (final p in pts) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    const pad = 0.004;
    _controller.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(
          LatLng(minLat - pad, minLng - pad),
          LatLng(maxLat + pad, maxLng + pad),
        ),
        padding: const EdgeInsets.only(
            left: 24, right: 24, top: 80, bottom: 280),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = widget.trail;
    // Esri tiles are free with no API key.
    final tileUrl = widget.satellite
        ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
        : 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}';

    return FlutterMap(
      mapController: _controller,
      options: MapOptions(
        initialCenter: t.trailhead,
        initialZoom: 13,
        onMapReady: _fitRoute,
      ),
      children: [
        TileLayer(
          urlTemplate: tileUrl,
          userAgentPackageName: 'com.vineeth.trail_blaze',
        ),
        if (t.routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              // Bright green route with dark outline, like AllTrails.
              Polyline(
                points: t.routePoints,
                color: Colors.black54,
                strokeWidth: 7,
              ),
              Polyline(
                points: t.routePoints,
                color: const Color(0xFF4CAF50),
                strokeWidth: 4.5,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            Marker(
              point: t.trailhead,
              width: 40,
              height: 40,
              child: Icon(Icons.location_on,
                  color: scheme.primary, size: 36),
            ),
            ...widget.waypoints.skip(1).map((w) => Marker(
                  point: w.point,
                  width: 130,
                  height: 60,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Text(
                          w.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Icon(Icons.location_on,
                          color: Color(0xFF4CAF50), size: 28),
                    ],
                  ),
                )),
          ],
        ),
      ],
    );
  }
}

/// Simple elevation profile chart.
class _ElevationProfile extends StatelessWidget {
  final List<double> points;
  const _ElevationProfile({required this.points});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CustomPaint(
      painter: _ElevationPainter(
        points: points,
        lineColor: scheme.onSurface,
        fillColor: scheme.primary.withValues(alpha: 0.35),
        labelColor: scheme.onSurfaceVariant,
      ),
      child: Container(),
    );
  }
}

class _ElevationPainter extends CustomPainter {
  final List<double> points;
  final Color lineColor;
  final Color fillColor;
  final Color labelColor;

  _ElevationPainter({
    required this.points,
    required this.lineColor,
    required this.fillColor,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final maxV =
        points.reduce((a, b) => a > b ? a : b);
    final minV =
        points.reduce((a, b) => a < b ? a : b);
    final span = (maxV - minV).clamp(1.0, double.infinity);

    final path = ui.Path();
    final linePath = ui.Path();
    for (var i = 0; i < points.length; i++) {
      final x = size.width * i / (points.length - 1);
      final y = size.height - 14 -
          (size.height - 28) * (points[i] - minV) / span;
      if (i == 0) {
        path.moveTo(x, size.height - 14);
        path.lineTo(x, y);
        linePath.moveTo(x, y);
      } else {
        path.lineTo(x, y);
        linePath.lineTo(x, y);
      }
    }
    path.lineTo(size.width, size.height - 14);
    path.close();

    canvas.drawPath(
        path, Paint()..color = fillColor);
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Min/max labels.
    final tp = TextPainter(
        textDirection: TextDirection.ltr);
    tp.text = TextSpan(
      text: '${maxV.round()} ft',
      style: TextStyle(color: labelColor, fontSize: 10),
    );
    tp.layout();
    tp.paint(canvas, Offset(size.width - tp.width, 0));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) =>
      false;
}
