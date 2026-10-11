import 'dart:math';

import 'package:latlong2/latlong.dart';

import '../models/trail.dart';

/// Generates a plausible-looking route polyline from a trailhead.
/// [loop] creates a loop that returns near the start; otherwise out-and-back.
/// [spanDeg] is the approximate straight-line reach in degrees (~69 mi per deg).
List<LatLng> _route(
  double lat,
  double lng, {
  required double spanDeg,
  required bool loop,
  int seed = 1,
}) {
  final rand = Random(seed);
  final points = <LatLng>[];
  const n = 24;
  // Primary direction of travel (radians), varied per trail.
  final heading = rand.nextDouble() * 2 * pi;
  final perp = heading + pi / 2;

  for (var i = 0; i <= n; i++) {
    final t = i / n; // 0..1
    // Winding offset perpendicular to travel direction.
    final wobble =
        sin(t * pi * 3 + seed) * spanDeg * 0.12 * (0.5 + rand.nextDouble() * 0.5);
    double dLat, dLng;
    if (loop) {
      // Loop: go out and curve back around.
      final a = t * 2 * pi;
      final r = spanDeg * (0.55 + 0.15 * sin(a * 2 + seed));
      dLat = cos(a + heading) * r;
      dLng = sin(a + heading) * r * 1.2;
    } else {
      // Out-and-back: travel out, then retrace with slight offset.
      final tt = t <= 0.5 ? t * 2 : (1 - t) * 2;
      final back = t > 0.5 ? spanDeg * 0.015 : 0.0;
      dLat = cos(heading) * spanDeg * tt + cos(perp) * (wobble + back);
      dLng = sin(heading) * spanDeg * tt * 1.2 + sin(perp) * (wobble + back);
    }
    points.add(LatLng(lat + dLat, lng + dLng));
  }
  return points;
}

/// Real Phoenix-area trails. Stats verified from published trail guides
/// (Oct 2026). Ratings/review counts are illustrative.
final List<Trail> phoenixTrails = [
  Trail(
    id: 'echo-canyon',
    name: 'Camelback Mountain via Echo Canyon',
    park: 'Echo Canyon Recreation Area',
    lat: 33.5318,
    lng: -111.9730,
    lengthMiles: 2.4,
    elevationGainFt: 1264,
    difficulty: Difficulty.hard,
    rating: 4.7,
    reviewCount: 8934,
    dogFriendly: false,
    kidFriendly: false,
    fee: 'Free',
    description:
        'The defining Phoenix hike: a short but extremely steep climb up '
        'boulder fields with handrails, ending at 2,704 ft with sweeping '
        '360-degree views of the Valley. Fully exposed — bring more water '
        'than you think you need. Dogs are not permitted.',
    tags: ['Summit', 'Views', 'Scramble', 'Iconic'],
    routePoints: _route(33.5318, -111.9730,
        spanDeg: 0.011, loop: false, seed: 11),
  ),
  Trail(
    id: 'cholla',
    name: 'Camelback Mountain via Cholla Trail',
    park: 'Camelback Mountain',
    lat: 33.5249,
    lng: -111.9527,
    lengthMiles: 3.0,
    elevationGainFt: 1420,
    difficulty: Difficulty.hard,
    rating: 4.6,
    reviewCount: 6211,
    dogFriendly: false,
    kidFriendly: false,
    fee: 'Free',
    description:
        'The slightly longer east-side route to Camelback\'s summit. A '
        'moderate start through the foothills gives way to a vertigo-inducing '
        'ridgeline rock scramble near the top. Rebuilt trailhead with '
        'restrooms and roadside parking on Invergordon Rd.',
    tags: ['Summit', 'Views', 'Scramble', 'Ridgeline'],
    routePoints: _route(33.5249, -111.9527,
        spanDeg: 0.013, loop: false, seed: 12),
  ),
  Trail(
    id: 'piestewa-summit',
    name: 'Piestewa Peak Summit Trail #300',
    park: 'Phoenix Mountains Preserve',
    lat: 33.5690,
    lng: -112.0103,
    lengthMiles: 2.4,
    elevationGainFt: 1200,
    difficulty: Difficulty.hard,
    rating: 4.7,
    reviewCount: 7456,
    dogFriendly: false,
    kidFriendly: false,
    fee: 'Free',
    description:
        'Phoenix\'s classic stair-climb: 1.2 miles up switchbacks, stone '
        'steps and jagged rock to a 2,608 ft summit with 360-degree metro '
        'views. The City rates it Extremely Difficult. Dogs are prohibited '
        'on the Summit Trail year-round.',
    tags: ['Summit', 'Views', 'Workout', 'Iconic'],
    routePoints: _route(33.5690, -112.0103,
        spanDeg: 0.010, loop: false, seed: 13),
  ),
  Trail(
    id: 'mormon-hidden-valley',
    name: 'Hidden Valley via Mormon Trail',
    park: 'South Mountain Park & Preserve',
    lat: 33.3547,
    lng: -112.0343,
    lengthMiles: 3.4,
    elevationGainFt: 918,
    difficulty: Difficulty.moderate,
    rating: 4.5,
    reviewCount: 2103,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'Climb the Mormon Trail into a hidden desert playground of massive '
        'boulders, a natural rock tunnel, petroglyphs and the famous '
        'Fat Man\'s Pass squeeze. Most elevation gain is in the first mile; '
        'the valley itself is flat and fun to explore.',
    tags: ['Rock formations', 'Petroglyphs', 'Family', 'Tunnel'],
    routePoints: _route(33.3547, -112.0343,
        spanDeg: 0.015, loop: true, seed: 14),
  ),
  Trail(
    id: 'hole-in-the-rock',
    name: 'Hole in the Rock Trail',
    park: 'Papago Park',
    lat: 33.4581,
    lng: -111.9472,
    lengthMiles: 0.3,
    elevationGainFt: 200,
    difficulty: Difficulty.easy,
    rating: 4.6,
    reviewCount: 5120,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'A short climb up red sandstone to the iconic natural window the '
        'ancient Hohokam used as a solar calendar. Panoramic views of downtown '
        'Phoenix, the lagoons and the zoo. A perfect sunset spot — arrive '
        'early on weekends.',
    tags: ['Landmark', 'Sunset', 'Family', 'Quick'],
    routePoints: _route(33.4581, -111.9472,
        spanDeg: 0.002, loop: false, seed: 15),
  ),
  Trail(
    id: 'gateway-loop',
    name: 'Gateway Loop Trail',
    park: 'McDowell Sonoran Preserve',
    lat: 33.6494,
    lng: -111.8583,
    lengthMiles: 4.5,
    elevationGainFt: 610,
    difficulty: Difficulty.moderate,
    rating: 4.5,
    reviewCount: 1876,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'A scenic loop through cactus gardens and granite boulder fields with '
        'constant views of Tom\'s Thumb. Well-signed and well-maintained — a '
        'great introduction to the Preserve. Restrooms, water and maps at the '
        'Gateway Trailhead.',
    tags: ['Loop', 'Desert garden', 'Views', 'Beginner-friendly'],
    routePoints: _route(33.6494, -111.8583,
        spanDeg: 0.020, loop: true, seed: 16),
  ),
  Trail(
    id: 'toms-thumb',
    name: "Tom's Thumb Trail",
    park: 'McDowell Sonoran Preserve',
    lat: 33.6858,
    lng: -111.8102,
    lengthMiles: 5.0,
    elevationGainFt: 1200,
    difficulty: Difficulty.hard,
    rating: 4.8,
    reviewCount: 2987,
    dogFriendly: true,
    kidFriendly: false,
    fee: 'Free',
    description:
        'A steep, rewarding climb to the massive granite thumb formation — a '
        'landmark for rock climbers — with panoramic views of the Valley and '
        'Four Peaks. Rocky and exposed; carry plenty of water. Restroom at '
        'trailhead, no drinking water.',
    tags: ['Summit', 'Rock formation', 'Views', 'Climbing'],
    routePoints: _route(33.6858, -111.8102,
        spanDeg: 0.022, loop: false, seed: 17),
  ),
  Trail(
    id: 'flatiron',
    name: 'Flatiron via Siphon Draw',
    park: 'Lost Dutchman State Park',
    lat: 33.4694,
    lng: -111.4679,
    lengthMiles: 5.8,
    elevationGainFt: 2800,
    difficulty: Difficulty.hard,
    rating: 4.9,
    reviewCount: 3421,
    dogFriendly: true,
    kidFriendly: false,
    fee: '\$10 vehicle',
    description:
        'Arizona\'s most iconic scramble: a deceptively easy stroll to the '
        'Siphon Draw basin, then a relentless Class 3/4 climb up slick rock '
        'and boulders to the Flatiron\'s 360-degree summit. Start pre-dawn, '
        'carry 3+ liters, and follow the blue-white markers up top.',
    tags: ['Scramble', 'Summit', 'Bucket list', 'Expert'],
    routePoints: _route(33.4694, -111.4679,
        spanDeg: 0.024, loop: false, seed: 18),
  ),
  Trail(
    id: 'peralta',
    name: 'Peralta Trail to Fremont Saddle',
    park: 'Superstition Wilderness',
    lat: 33.3987,
    lng: -111.3542,
    lengthMiles: 4.7,
    elevationGainFt: 1308,
    difficulty: Difficulty.moderate,
    rating: 4.8,
    reviewCount: 2765,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'State Trust Land permit',
    description:
        'The best first Superstition hike: a steady climb up Peralta Canyon '
        'to Fremont Saddle with the legendary Weaver\'s Needle dead ahead. '
        'Great for visiting family. Note: the trailhead sits on State Trust '
        'Land — a recreational permit is required.',
    tags: ['Views', 'Canyon', 'Wildflowers', 'Classic'],
    routePoints: _route(33.3987, -111.3542,
        spanDeg: 0.020, loop: false, seed: 19),
  ),
  Trail(
    id: 'treasure-loop',
    name: 'Treasure Loop Trail',
    park: 'Lost Dutchman State Park',
    lat: 33.4646,
    lng: -111.4724,
    lengthMiles: 2.4,
    elevationGainFt: 500,
    difficulty: Difficulty.moderate,
    rating: 4.5,
    reviewCount: 1988,
    dogFriendly: true,
    kidFriendly: true,
    fee: '\$7 vehicle',
    description:
        'A gentle loop at the foot of the Superstitions with big mountain '
        'views, Praying Hands rock, saguaro forests and spring wildflowers. '
        'Wide, well-marked and runnable — an ideal sunset hike. Connects to '
        'Prospector\'s View and Jacob\'s Crosscut for more miles.',
    tags: ['Loop', 'Wildflowers', 'Family', 'Sunset'],
    routePoints: _route(33.4646, -111.4724,
        spanDeg: 0.011, loop: true, seed: 20),
  ),
  Trail(
    id: 'white-tank-waterfall',
    name: 'White Tank Waterfall Trail',
    park: 'White Tank Mountain Regional Park',
    lat: 33.5898,
    lng: -112.5072,
    lengthMiles: 1.9,
    elevationGainFt: 200,
    difficulty: Difficulty.easy,
    rating: 4.6,
    reviewCount: 3629,
    dogFriendly: true,
    kidFriendly: true,
    fee: '\$7 vehicle',
    description:
        'An easy, mostly paved walk into Waterfall Canyon past 1,000-year-old '
        'Hohokam petroglyphs to a seasonal waterfall that flows after winter '
        'rains. The first half-mile is barrier-free. Go right after a storm — '
        'the falls dry up fast.',
    tags: ['Waterfall', 'Petroglyphs', 'Accessible', 'Family'],
    routePoints: _route(33.5898, -112.5072,
        spanDeg: 0.009, loop: false, seed: 21),
  ),
  Trail(
    id: 'go-john',
    name: 'Go John Trail',
    park: 'Cave Creek Regional Park',
    lat: 33.8328,
    lng: -111.9956,
    lengthMiles: 5.8,
    elevationGainFt: 800,
    difficulty: Difficulty.moderate,
    rating: 4.4,
    reviewCount: 1102,
    dogFriendly: true,
    kidFriendly: true,
    fee: '\$7 vehicle',
    description:
        'A rolling loop around a desert mountain through upper Sonoran Desert '
        'with impressive saguaro stands, washes and wildlife. Light crowds '
        'and great wildflowers in wet years. Vault toilets at trailhead; '
        'carry at least 2 liters.',
    tags: ['Loop', 'Saguaros', 'Wildlife', 'Quiet'],
    routePoints: _route(33.8328, -111.9956,
        spanDeg: 0.026, loop: true, seed: 22),
  ),
  Trail(
    id: 'sunrise',
    name: 'Sunrise Trail',
    park: 'Thunderbird Conservation Park',
    lat: 33.6976,
    lng: -112.1779,
    lengthMiles: 2.0,
    elevationGainFt: 400,
    difficulty: Difficulty.moderate,
    rating: 4.3,
    reviewCount: 764,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'A moderate climb on the west side of the Valley with city views and '
        'four wildlife viewing blinds nearby. Less crowded than the central '
        'Phoenix peaks — a solid sunrise or sunset option. Free entry; lots '
        'of connecting trails for longer outings.',
    tags: ['Views', 'Wildlife', 'Sunset', 'Quiet'],
    routePoints: _route(33.6976, -112.1779,
        spanDeg: 0.009, loop: false, seed: 23),
  ),
  Trail(
    id: 'piestewa-nature',
    name: 'Piestewa Peak Nature Trail',
    park: 'Phoenix Mountains Preserve',
    lat: 33.5800,
    lng: -112.0060,
    lengthMiles: 1.4,
    elevationGainFt: 180,
    difficulty: Difficulty.easy,
    rating: 4.2,
    reviewCount: 542,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'A gentle loop skirting a deep desert wash — a true Sonoran escape '
        'minutes from the city, with excellent spring wildflowers. A great '
        'alternative when the Summit Trail crowds (or your legs) say no. '
        'Restrooms and drinking water at the 304 Trailhead.',
    tags: ['Loop', 'Wildflowers', 'Family', 'Easy'],
    routePoints: _route(33.5800, -112.0060,
        spanDeg: 0.007, loop: true, seed: 24),
  ),
  Trail(
    id: 'double-butte',
    name: 'Double Butte Loop',
    park: 'Papago Park',
    lat: 33.4518,
    lng: -111.9450,
    lengthMiles: 2.3,
    elevationGainFt: 100,
    difficulty: Difficulty.easy,
    rating: 4.3,
    reviewCount: 918,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'A flat, smooth loop around Papago\'s red sandstone buttes — perfect '
        'for an easy run, a family walk or mountain biking. Combine with '
        'Hole in the Rock for a classic Papago outing. Trails open until '
        '11 p.m.',
    tags: ['Loop', 'Running', 'Family', 'Biking'],
    routePoints: _route(33.4518, -111.9450,
        spanDeg: 0.010, loop: true, seed: 25),
  ),
];

/// A few seeded community reviews per popular trail (illustrative).
final Map<String, List<TrailReview>> seedReviews = {
  'echo-canyon': [
    TrailReview(
      author: 'DesertRat88',
      rating: 5,
      text: 'Brutal but worth it. Got to the trailhead at 6am on a Saturday '
          'and still barely found parking. The handrail section is no joke — '
          'bring gloves and twice the water you think you need.',
      date: DateTime(2026, 3, 14),
    ),
    TrailReview(
      author: 'Maya H.',
      rating: 5,
      text: 'Best sunrise in Phoenix, hands down. The city lights below and '
          'the sky turning pink behind the Praying Monk — unreal.',
      date: DateTime(2026, 2, 2),
    ),
    TrailReview(
      author: 'TrailNewbie',
      rating: 4,
      text: 'Way harder than expected for 2.4 miles. Lots of scrambling. '
          'Turned around at the saddle and still had a great morning.',
      date: DateTime(2026, 1, 19),
    ),
  ],
  'flatiron': [
    TrailReview(
      author: 'AZPeakBaggr',
      rating: 5,
      text: 'The scramble above the basin is the real deal — route finding, '
          'exposure, the works. Follow the painted markers and start before '
          'dawn. Hardest hike I\'ve done in the Valley and my favorite.',
      date: DateTime(2026, 4, 5),
    ),
    TrailReview(
      author: 'CactusFlower',
      rating: 5,
      text: 'Did it in March with perfect weather. The 360 view from the top '
          'with Weaver\'s Needle to the east is something I\'ll never forget.',
      date:  DateTime(2026, 3, 22),
    ),
  ],
  'peralta': [
    TrailReview(
      author: 'WeekendWanderer',
      rating: 5,
      text: 'Took my parents (60s) to Fremont Saddle and they loved it. '
          'Weaver\'s Needle view is stunning. Remember the State Trust Land '
          'permit — rangers do check.',
      date: DateTime(2026, 2, 28),
    ),
  ],
  'hole-in-the-rock': [
    TrailReview(
      author: 'SunsetChaser',
      rating: 5,
      text: 'Twenty minutes up, the best sunset view in the city. Go on a '
          'weekday if you want the hole to yourself for photos.',
      date: DateTime(2026, 5, 10),
    ),
  ],
  'white-tank-waterfall': [
    TrailReview(
      author: 'MonsoonHunter',
      rating: 4,
      text: 'Went two days after a big storm and the falls were flowing! '
          'Without water it\'s still a pleasant walk with cool petroglyphs, '
          'but check recent rain first.',
      date: DateTime(2026, 1, 8),
    ),
  ],
};
