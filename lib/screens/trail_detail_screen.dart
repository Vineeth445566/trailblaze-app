import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/trails.dart';
import '../models/trail.dart';
import '../services/storage_service.dart';
import '../widgets/trail_map.dart';
import '../widgets/trail_widgets.dart';
import 'record_screen.dart';

class TrailDetailScreen extends StatefulWidget {
  final Trail trail;

  const TrailDetailScreen({super.key, required this.trail});

  @override
  State<TrailDetailScreen> createState() => _TrailDetailScreenState();
}

class _TrailDetailScreenState extends State<TrailDetailScreen> {
  final _storage = StorageService();
  bool _saved = false;
  List<TrailReview> _reviews = [];
  bool _loadingReviews = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final savedIds = await _storage.getSavedTrailIds();
    final userReviews = await _storage.getUserReviews(widget.trail.id);
    final seeded = seedReviews[widget.trail.id] ?? [];
    if (mounted) {
      setState(() {
        _saved = savedIds.contains(widget.trail.id);
        _reviews = [...userReviews, ...seeded];
        _loadingReviews = false;
      });
    }
  }

  Future<void> _toggleSaved() async {
    final next = !_saved;
    await _storage.toggleSavedTrail(widget.trail.id, next);
    if (mounted) setState(() => _saved = next);
  }

  Future<void> _openDirections() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination='
      '${widget.trail.lat},${widget.trail.lng}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open maps.')),
      );
    }
  }

  void _showAddReview() {
    final nameCtrl = TextEditingController();
    final textCtrl = TextEditingController();
    double rating = 5;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheet) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Write a review',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Your name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Rating:'),
                  const SizedBox(width: 8),
                  for (var i = 1; i <= 5; i++)
                    IconButton(
                      icon: Icon(
                        i <= rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () => setSheet(() => rating = i.toDouble()),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: textCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'How was the hike?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (textCtrl.text.trim().isEmpty) return;
                    await _storage.addUserReview(
                      widget.trail.id,
                      TrailReview(
                        author: nameCtrl.text.trim().isEmpty
                            ? 'Anonymous hiker'
                            : nameCtrl.text.trim(),
                        rating: rating,
                        text: textCtrl.text.trim(),
                        date: DateTime.now(),
                      ),
                    );
                    if (ctx.mounted) Navigator.of(ctx).pop();
                    _load();
                  },
                  child: const Text('Post review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trail;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                t.name,
                style: const TextStyle(fontSize: 16),
              ),
              background: TrailHeaderArt(trail: t, height: 200),
            ),
            actions: [
              IconButton(
                icon: Icon(_saved ? Icons.bookmark : Icons.bookmark_border),
                onPressed: _toggleSaved,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.park,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      StatTile(
                        icon: Icons.route,
                        value: '${t.lengthMiles} mi',
                        label: 'Length',
                      ),
                      const SizedBox(width: 8),
                      StatTile(
                        icon: Icons.trending_up,
                        value: '${t.elevationGainFt} ft',
                        label: 'Elevation gain',
                      ),
                      const SizedBox(width: 8),
                      StatTile(
                        icon: Icons.speed,
                        value: t.difficulty.label,
                        label: 'Difficulty',
                      ),
                      const SizedBox(width: 8),
                      StatTile(
                        icon: Icons.star,
                        value: t.rating.toStringAsFixed(1),
                        label: '${t.reviewCount} reviews',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _infoChip(
                          Icons.confirmation_number_outlined, t.fee),
                      _infoChip(Icons.pets,
                          t.dogFriendly ? 'Dogs OK' : 'No dogs'),
                      _infoChip(Icons.child_care,
                          t.kidFriendly ? 'Kid friendly' : 'Not for kids'),
                      for (final tag in t.tags)
                        _infoChip(Icons.tag, tag),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Trail map',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 240,
                      child: TrailMapView(
                        routePoints: t.routePoints,
                        trailhead: t.trailhead,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Route shown is approximate. Carry a real map on remote trails.',
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'About this trail',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.description,
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reviews',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add review'),
                        onPressed: _showAddReview,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_loadingReviews)
                    const Center(
                        child: CircularProgressIndicator())
                  else if (_reviews.isEmpty)
                    const Text(
                        'No reviews yet — be the first to share yours.'),
                  for (final r in _reviews) _reviewCard(r),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.directions),
                  label: const Text('Directions'),
                  onPressed: _openDirections,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.radio_button_checked),
                  label: const Text('Record hike'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            RecordScreen(trail: widget.trail),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor:
          scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      side: BorderSide.none,
    );
  }

  Widget _reviewCard(TrailReview r) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Text(
                    r.author.isNotEmpty
                        ? r.author[0].toUpperCase()
                        : '?',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.author,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                      Text(
                        DateFormat('MMM d, yyyy').format(r.date),
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star,
                        size: 14, color: Colors.amber),
                    Text(
                      r.rating.toStringAsFixed(0),
                      style:
                          const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(r.text,
                style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
