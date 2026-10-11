import 'package:latlong2/latlong.dart';

/// Difficulty levels for trails.
enum Difficulty { easy, moderate, hard }

extension DifficultyLabel on Difficulty {
  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.moderate:
        return 'Moderate';
      case Difficulty.hard:
        return 'Hard';
    }
  }
}

/// A hiking trail with a real trailhead and stats.
class Trail {
  final String id;
  final String name;
  final String park;
  final String state; // e.g. 'Arizona'
  final double lat;
  final double lng;
  final double lengthMiles;
  final int elevationGainFt;
  final Difficulty difficulty;
  final double rating;
  final int reviewCount;
  final bool dogFriendly;
  final bool kidFriendly;
  final String fee; // e.g. 'Free', '\$7 vehicle'
  final String description;
  final List<String> tags;
  final List<LatLng> routePoints;

  const Trail({
    required this.id,
    required this.name,
    required this.park,
    required this.state,
    required this.lat,
    required this.lng,
    required this.lengthMiles,
    required this.elevationGainFt,
    required this.difficulty,
    required this.rating,
    required this.reviewCount,
    required this.dogFriendly,
    required this.kidFriendly,
    required this.fee,
    required this.description,
    required this.tags,
    required this.routePoints,
  });

  LatLng get trailhead => LatLng(lat, lng);
}

/// A community review for a trail.
class TrailReview {
  final String author;
  final double rating;
  final String text;
  final DateTime date;

  const TrailReview({
    required this.author,
    required this.rating,
    required this.text,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'author': author,
        'rating': rating,
        'text': text,
        'date': date.toIso8601String(),
      };

  factory TrailReview.fromJson(Map<String, dynamic> json) => TrailReview(
        author: json['author'] as String,
        rating: (json['rating'] as num).toDouble(),
        text: json['text'] as String,
        date: DateTime.parse(json['date'] as String),
      );
}

/// A recorded hike from the GPS recorder.
class RecordedHike {
  final String id;
  final String? trailId;
  final String? trailName;
  final DateTime startTime;
  final DateTime endTime;
  final double distanceMiles;
  final int elevationGainFt;
  final List<LatLng> path;

  const RecordedHike({
    required this.id,
    this.trailId,
    this.trailName,
    required this.startTime,
    required this.endTime,
    required this.distanceMiles,
    required this.elevationGainFt,
    required this.path,
  });

  Duration get duration => endTime.difference(startTime);

  /// Pace in minutes per mile.
  double get paceMinPerMile {
    if (distanceMiles <= 0) return 0;
    return duration.inSeconds / 60 / distanceMiles;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'trailId': trailId,
        'trailName': trailName,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'distanceMiles': distanceMiles,
        'elevationGainFt': elevationGainFt,
        'path': path.map((p) => [p.latitude, p.longitude]).toList(),
      };

  factory RecordedHike.fromJson(Map<String, dynamic> json) => RecordedHike(
        id: json['id'] as String,
        trailId: json['trailId'] as String?,
        trailName: json['trailName'] as String?,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
        distanceMiles: (json['distanceMiles'] as num).toDouble(),
        elevationGainFt: (json['elevationGainFt'] as num).toInt(),
        path: (json['path'] as List)
            .map((e) => LatLng(
                  (e[0] as num).toDouble(),
                  (e[1] as num).toDouble(),
                ))
            .toList(),
      );
}
