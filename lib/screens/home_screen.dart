import 'package:flutter/material.dart';

import '../data/trails.dart';
import '../models/trail.dart';
import '../services/storage_service.dart';
import 'trail_detail_screen.dart';
import '../widgets/trail_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = StorageService();
  final _searchCtrl = TextEditingController();
  String _query = '';
  final Set<Difficulty> _difficulties = {};
  double _maxDistance = 15;
  bool _dogFriendlyOnly = false;
  Set<String> _savedIds = {};

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final ids = await _storage.getSavedTrailIds();
    if (mounted) setState(() => _savedIds = ids);
  }

  Future<void> _toggleSaved(Trail trail) async {
    final saved = !_savedIds.contains(trail.id);
    await _storage.toggleSavedTrail(trail.id, saved);
    if (mounted) {
      setState(() {
        if (saved) {
          _savedIds.add(trail.id);
        } else {
          _savedIds.remove(trail.id);
        }
      });
    }
  }

  List<Trail> get _filtered {
    return phoenixTrails.where((t) {
      if (_query.isNotEmpty) {
        final q = _query.toLowerCase();
        final hay = '${t.name} ${t.park} ${t.tags.join(' ')}'.toLowerCase();
        if (!hay.contains(q)) return false;
      }
      if (_difficulties.isNotEmpty && !_difficulties.contains(t.difficulty)) {
        return false;
      }
      if (t.lengthMiles > _maxDistance) return false;
      if (_dogFriendlyOnly && !t.dogFriendly) return false;
      return true;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trails = _filtered;
    return Scaffold(
      appBar: AppBar(
        title: const Text('TrailBlaze'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search trails, parks, tags...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          _buildFilterRow(),
          Expanded(
            child: trails.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 48),
                        SizedBox(height: 8),
                        Text('No trails match your filters.'),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadSaved,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: trails.length,
                      itemBuilder: (context, i) =>
                          _TrailCard(
                        trail: trails[i],
                        saved: _savedIds.contains(trails[i].id),
                        onToggleSaved: () => _toggleSaved(trails[i]),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TrailDetailScreen(
                                  trail: trails[i]),
                            ),
                          );
                          _loadSaved();
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              for (final d in Difficulty.values)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(d.label),
                    selected: _difficulties.contains(d),
                    onSelected: (sel) => setState(() {
                      sel
                          ? _difficulties.add(d)
                          : _difficulties.remove(d);
                    }),
                  ),
                ),
              FilterChip(
                label: const Text('Dog friendly'),
                avatar: const Icon(Icons.pets, size: 16),
                selected: _dogFriendlyOnly,
                onSelected: (sel) =>
                    setState(() => _dogFriendlyOnly = sel),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.route, size: 18),
              Expanded(
                child: Slider(
                  value: _maxDistance,
                  min: 1,
                  max: 15,
                  divisions: 14,
                  label: 'Up to ${_maxDistance.toStringAsFixed(0)} mi',
                  onChanged: (v) =>
                      setState(() => _maxDistance = v),
                ),
              ),
              SizedBox(
                width: 64,
                child: Text(
                  '< ${_maxDistance.toStringAsFixed(0)} mi',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrailCard extends StatelessWidget {
  final Trail trail;
  final bool saved;
  final VoidCallback onToggleSaved;
  final VoidCallback onTap;

  const _TrailCard({
    required this.trail,
    required this.saved,
    required this.onToggleSaved,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                TrailHeaderArt(trail: trail, height: 130),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      saved ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black45,
                    ),
                    onPressed: onToggleSaved,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trail.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    trail.park,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.route,
                          size: 14, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${trail.lengthMiles} mi',
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 12),
                      Icon(Icons.trending_up,
                          size: 14, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${trail.elevationGainFt} ft',
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 12),
                      Icon(Icons.confirmation_number_outlined,
                          size: 14, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(trail.fee,
                          style: const TextStyle(fontSize: 12)),
                      if (trail.dogFriendly) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.pets,
                            size: 14, color: scheme.onSurfaceVariant),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
