import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/trail.dart';

/// Local persistence: saved trails, user reviews, recorded hikes.
class StorageService {
  static const _savedKey = 'trailblaze_saved_trails';
  static const _reviewsKey = 'trailblaze_reviews';
  static const _hikesKey = 'trailblaze_hikes';

  // ---- Saved trails ----
  Future<Set<String>> getSavedTrailIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_savedKey)?.toSet() ?? {};
  }

  Future<void> toggleSavedTrail(String trailId, bool saved) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_savedKey)?.toSet() ?? <String>{};
    if (saved) {
      ids.add(trailId);
    } else {
      ids.remove(trailId);
    }
    await prefs.setStringList(_savedKey, ids.toList());
  }

  // ---- Reviews (user-added, keyed by trail id) ----
  Future<List<TrailReview>> getUserReviews(String trailId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_reviewsKey);
    if (raw == null) return [];
    final map = jsonDecode(raw) as Map<String, dynamic>;
    final list = map[trailId] as List? ?? [];
    return list
        .map((e) => TrailReview.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addUserReview(String trailId, TrailReview review) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_reviewsKey);
    final map = raw == null
        ? <String, dynamic>{}
        : jsonDecode(raw) as Map<String, dynamic>;
    final list = (map[trailId] as List? ?? []).toList();
    list.insert(0, review.toJson());
    map[trailId] = list;
    await prefs.setString(_reviewsKey, jsonEncode(map));
  }

  // ---- Recorded hikes ----
  Future<List<RecordedHike>> getHikes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_hikesKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    final hikes = list
        .map((e) => RecordedHike.fromJson(e as Map<String, dynamic>))
        .toList();
    hikes.sort((a, b) => b.startTime.compareTo(a.startTime));
    return hikes;
  }

  Future<void> saveHike(RecordedHike hike) async {
    final prefs = await SharedPreferences.getInstance();
    final hikes = await getHikes();
    hikes.insert(0, hike);
    // Cap stored path points to keep prefs small.
    final trimmed = hikes.take(200).toList();
    await prefs.setString(
      _hikesKey,
      jsonEncode(trimmed.map((h) => h.toJson()).toList()),
    );
  }

  Future<void> deleteHike(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final hikes = await getHikes();
    hikes.removeWhere((h) => h.id == id);
    await prefs.setString(
      _hikesKey,
      jsonEncode(hikes.map((h) => h.toJson()).toList()),
    );
  }
}
