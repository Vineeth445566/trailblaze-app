import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Reusable OpenStreetMap view with a trail route polyline,
/// a trailhead marker, and graceful offline handling.
class TrailMapView extends StatefulWidget {
  final List<LatLng> routePoints;
  final LatLng trailhead;
  final List<LatLng>? livePath;
  final LatLng? livePosition;
  final double initialZoom;

  const TrailMapView({
    super.key,
    required this.routePoints,
    required this.trailhead,
    this.livePath,
    this.livePosition,
    this.initialZoom = 13,
  });

  @override
  State<TrailMapView> createState() => _TrailMapViewState();
}

class _TrailMapViewState extends State<TrailMapView> {
  bool _tileError = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final markers = <Marker>[
      Marker(
        point: widget.trailhead,
        width: 40,
        height: 40,
        child: Icon(
          Icons.location_on,
          color: scheme.primary,
          size: 36,
        ),
      ),
    ];
    if (widget.livePosition != null) {
      markers.add(
        Marker(
          point: widget.livePosition!,
          width: 30,
          height: 30,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4)
              ],
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: widget.trailhead,
            initialZoom: widget.initialZoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            TileLayer(
              // CartoDB Voyager tiles: free, reliable, OSM-based.
              // (tile.openstreetmap.org rate-limits mobile clients.)
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.vineeth.trail_blaze',
              errorTileCallback: (tile, error, stackTrace) {
                if (mounted && !_tileError) {
                  setState(() => _tileError = true);
                }
              },
            ),
            if (widget.routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.routePoints,
                    color: scheme.primary,
                    strokeWidth: 4,
                  ),
                ],
              ),
            if (widget.livePath != null && widget.livePath!.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.livePath!,
                    color: Colors.blue,
                    strokeWidth: 5,
                  ),
                ],
              ),
            MarkerLayer(markers: markers),
          ],
        ),
        if (_tileError)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 16, color: Colors.white70),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Map tiles unavailable offline. Trail route still shown.',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
