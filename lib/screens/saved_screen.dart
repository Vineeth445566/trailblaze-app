import 'package:flutter/material.dart';

import '../data/trails.dart';
import '../models/trail.dart';
import '../services/storage_service.dart';
import '../widgets/trail_widgets.dart';
import 'trail_detail_screen.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final _storage = StorageService();
  Set<String> _savedIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ids = await _storage.getSavedTrailIds();
    if (mounted) {
      setState(() {
        _savedIds = ids;
        _loading = false;
      });
    }
  }

  Future<void> _unsave(Trail trail) async {
    await _storage.toggleSavedTrail(trail.id, false);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final saved =
        allTrails.where((t) => _savedIds.contains(t.id)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Saved trails')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : saved.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bookmark_border,
                          size: 64,
                          color: scheme.onSurfaceVariant),
                      const SizedBox(height: 12),
                      const Text(
                        'No saved trails yet.',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap the bookmark on any trail to save it here.',
                        style: TextStyle(
                            color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: saved.length,
                    itemBuilder: (context, i) {
                      final t = saved[i];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        margin:
                            const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    TrailDetailScreen(trail: t),
                              ),
                            );
                            _load();
                          },
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              TrailHeaderArt(
                                  trail: t, height: 110),
                              ListTile(
                                title: Text(t.name,
                                    style: const TextStyle(
                                        fontWeight:
                                            FontWeight.bold)),
                                subtitle: Text(
                                    '${t.lengthMiles} mi · '
                                    '${t.difficulty.label} · '
                                    '${t.rating.toStringAsFixed(1)} stars'),
                                trailing: IconButton(
                                  icon: const Icon(
                                      Icons.bookmark),
                                  onPressed: () => _unsave(t),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
