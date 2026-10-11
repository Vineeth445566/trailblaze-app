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
  final List<Marker> extraMarkers;

  const TrailMapView({
    super.key,
    required this.routePoints,
    required this.trailhead,
    this.livePath,
    this.livePosition,
    this.initialZoom = 13,
    this.extraMarkers = const [],
  });

  @override
  State<TrailMapView> createState() => _TrailMapViewState();
}

class _TrailMapViewState extends State<TrailMapView> {
  bool _tileError = false;
  final MapController _mapController = MapController();
  bool _fitted = false;

  /// Zoom the map to fit the full route once the map is ready.
  void _fitRoute() {
    if (_fitted || widget.routePoints.isEmpty) return;
    _fitted = true;
    var minLat = widget.routePoints.first.latitude;
    var maxLat = minLat;
    var minLng = widget.routePoints.first.longitude;
    var maxLng = minLng;
    for (final p in widget.routePoints) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    // Pad the bounds so the route isn't edge-to-edge.
    const pad = 0.004;
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(
          LatLng(minLat - pad, minLng - pad),
          LatLng(maxLat + pad, maxLng + pad),
        ),
        padding: const EdgeInsets.all(24),
      ),
    );
  }

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
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.trailhead,
            initialZoom: widget.initialZoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onMapReady: _fitRoute,
          ),
          children: [
            TileLayer(
              // Esri World Topo: free, no API key, topographic detail
              // ideal for hiking. (CartoDB now requires an API key;
              // OSM standard tiles rate-limit mobile clients.)
              urlTemplate:
                  'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
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
                  // White halo for contrast against the topo background.
                  Polyline(
                    points: widget.routePoints,
                    color: Colors.white,
                    strokeWidth: 7,
                  ),
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
            MarkerLayer(
                markers: [...markers, ...widget.extraMarkers]),
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
