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

/// Iconic trails across the USA. Stats verified from published trail guides
/// (Oct 2026). Ratings/review counts are illustrative. Route polylines are
/// synthetic approximations for visualization — not for navigation.
final List<Trail> allTrails = [
  Trail(
    id: 'echo-canyon',
    name: 'Camelback Mountain via Echo Canyon',
    park: 'Echo Canyon Recreation Area',
    state: 'Arizona',
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
    state: 'Arizona',
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
    state: 'Arizona',
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
    state: 'Arizona',
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
    state: 'Arizona',
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
    state: 'Arizona',
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
    state: 'Arizona',
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
    state: 'Arizona',
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
    state: 'Arizona',
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
    state: 'Arizona',
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
    state: 'Arizona',
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
    state: 'Arizona',
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
    state: 'Arizona',
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
    state: 'Arizona',
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
    state: 'Arizona',
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
  Trail(
    id: 'cadillac-mountain-north-ridge-trail',
    name: 'Cadillac Mountain North Ridge Trail',
    park: 'Acadia National Park',
    state: 'Maine',
    lat: 44.3530,
    lng: -68.2252,
    lengthMiles: 4.2,
    elevationGainFt: 1128,
    difficulty: Difficulty.hard,
    rating: 4.7,
    reviewCount: 1209,
    dogFriendly: true,
    kidFriendly: false,
    fee: '\$35 vehicle (NPS pass)',
    description:
        'The classic route up Acadia\'s 1,530-foot crown jewel, climbing exposed '
        'granite slabs past overlooks of Frenchman Bay. Sunrise hikers gather at '
        'the summit, one of the first places in the US to catch morning light. '
        'Expect steady grades, sweeping ocean panoramas, and the option to return '
        'via the gentler South Ridge.',
    tags: ['Summit', 'Ocean Views', 'Granite'],
    routePoints: _route(44.3530, -68.2252,
        spanDeg: 0.0189, loop: false, seed: 100),
  ),
  Trail(
    id: 'the-beehive-loop-trail',
    name: 'The Beehive Loop Trail',
    park: 'Acadia National Park',
    state: 'Maine',
    lat: 44.3315,
    lng: -68.1853,
    lengthMiles: 1.6,
    elevationGainFt: 515,
    difficulty: Difficulty.hard,
    rating: 4.7,
    reviewCount: 4812,
    dogFriendly: false,
    kidFriendly: false,
    fee: '\$35 vehicle (NPS pass)',
    description:
        'Acadia\'s famous iron-rung adventure ascends a near-vertical granite dome '
        'on metal ladders and exposed ledges. The short but thrilling loop '
        'rewards with sweeping views of Sand Beach and the Atlantic. Not for the '
        'faint of heart, but the descent around the back is gentle and forested.',
    tags: ['Iron Rungs', 'Ocean Views', 'Scramble'],
    routePoints: _route(44.3315, -68.1853,
        spanDeg: 0.0072, loop: true, seed: 101),
  ),
  Trail(
    id: 'jordan-pond-path',
    name: 'Jordan Pond Path',
    park: 'Acadia National Park',
    state: 'Maine',
    lat: 44.33579,
    lng: -68.25358,
    lengthMiles: 3.3,
    elevationGainFt: 52,
    difficulty: Difficulty.easy,
    rating: 4.4,
    reviewCount: 2479,
    dogFriendly: true,
    kidFriendly: true,
    fee: '\$35 vehicle (NPS pass)',
    description:
        'This easy lakeside loop circles Jordan Pond on boardwalks and gravel '
        'path beneath the sheer Twin Bubbles. Reflections of the Bubbles on the '
        'glassy water make it one of the most photographed walks in the East. '
        'Finish at the Jordan Pond House, famous for its popovers.',
    tags: ['Lake', 'Mountain Views', 'Boardwalk'],
    routePoints: _route(44.33579, -68.25358,
        spanDeg: 0.0148, loop: true, seed: 102),
  ),
  Trail(
    id: 'franconia-ridge-loop',
    name: 'Franconia Ridge Loop',
    park: 'Franconia Notch State Park',
    state: 'New Hampshire',
    lat: 44.1427,
    lng: -71.6846,
    lengthMiles: 8.6,
    elevationGainFt: 3809,
    difficulty: Difficulty.hard,
    rating: 4.7,
    reviewCount: 9735,
    dogFriendly: true,
    kidFriendly: false,
    fee: '\$5 day-use parking',
    description:
        'Often called the best ridge hike in the Northeast, this 8.6-mile loop '
        'traverses three 5,000-foot summits above treeline. Sweeping views '
        'stretch from the Presidential Range to the Green Mountains across open '
        'alpine tundra. The steep Falling Waters descent passes a series of '
        'gorgeous cascades.',
    tags: ['Ridgeline', 'Alpine', 'Waterfall'],
    routePoints: _route(44.1427, -71.6846,
        spanDeg: 0.0387, loop: true, seed: 103),
  ),
  Trail(
    id: 'mount-washington-via-tuckerman-ravine',
    name: 'Mount Washington via Tuckerman Ravine',
    park: 'White Mountain National Forest',
    state: 'New Hampshire',
    lat: 44.2574,
    lng: -71.2529,
    lengthMiles: 8.5,
    elevationGainFt: 4240,
    difficulty: Difficulty.hard,
    rating: 4.4,
    reviewCount: 7712,
    dogFriendly: true,
    kidFriendly: false,
    fee: '\$5 day-use parking (WMNF)',
    description:
        'The most legendary route up the highest peak in the Northeast climbs '
        'into the dramatic glacial cirque of Tuckerman Ravine. Above treeline, '
        'alpine wildflowers and raw weather create an almost arctic feel. The '
        '6,288-foot summit rewards with views across six states on a clear day.',
    tags: ['Summit', 'Alpine', 'Tallest'],
    routePoints: _route(44.2574, -71.2529,
        spanDeg: 0.0382, loop: false, seed: 104),
  ),
  Trail(
    id: 'mount-monadnock-via-white-dot-and-white-cross',
    name: 'Mount Monadnock via White Dot and White Cross',
    park: 'Monadnock State Park',
    state: 'New Hampshire',
    lat: 42.84536,
    lng: -72.07653,
    lengthMiles: 3.8,
    elevationGainFt: 1742,
    difficulty: Difficulty.hard,
    rating: 4.3,
    reviewCount: 2335,
    dogFriendly: false,
    kidFriendly: true,
    fee: '\$5/person (NH state parks)',
    description:
        'One of the most climbed mountains in the world, Monadnock\'s bare granite '
        'dome rises alone above southern New Hampshire. The steep White Dot trail '
        'scrambles over ledges to a summit with 100-mile views. Loop back down '
        'the gentler White Cross through pine forest.',
    tags: ['Summit', 'Views', 'Scramble'],
    routePoints: _route(42.84536, -72.07653,
        spanDeg: 0.0171, loop: true, seed: 105),
  ),
  Trail(
    id: 'welch-dickey-loop',
    name: 'Welch-Dickey Loop',
    park: 'White Mountain National Forest',
    state: 'New Hampshire',
    lat: 43.90393,
    lng: -71.58885,
    lengthMiles: 4.4,
    elevationGainFt: 1802,
    difficulty: Difficulty.hard,
    rating: 4.4,
    reviewCount: 9079,
    dogFriendly: true,
    kidFriendly: true,
    fee: '\$5 day-use parking (WMNF)',
    description:
        'A compact 4.4-mile loop over two open granite domes with ledges that '
        'feel like walking on the moon. Views of the Sandwich Range unfold from '
        'nearly every step of the ridge. Smooth rock slabs demand caution when '
        'wet, but the payoff per mile is among the best in the Whites.',
    tags: ['Ridgeline', 'Views', 'Loop'],
    routePoints: _route(43.90393, -71.58885,
        spanDeg: 0.0198, loop: true, seed: 106),
  ),
  Trail(
    id: 'mount-mansfield-the-chin-via-sunset-ridge',
    name: 'Mount Mansfield: The Chin via Sunset Ridge',
    park: 'Underhill State Park',
    state: 'Vermont',
    lat: 44.5305,
    lng: -72.8331,
    lengthMiles: 5.4,
    elevationGainFt: 2529,
    difficulty: Difficulty.hard,
    rating: 4.7,
    reviewCount: 9995,
    dogFriendly: true,
    kidFriendly: false,
    fee: '\$4/person (VT state parks)',
    description:
        'Vermont\'s highest peak delivers a spectacular ridgeline traverse along '
        'the forehead, nose, and chin profile. Sunset Ridge offers open ledges '
        'with sweeping views of Lake Champlain and the Adirondacks. The Chin '
        'itself is a narrow rocky outcrop with 360-degree panoramas.',
    tags: ['Summit', 'Ridgeline', 'Views'],
    routePoints: _route(44.5305, -72.8331,
        spanDeg: 0.0243, loop: false, seed: 107),
  ),
  Trail(
    id: 'camel-s-hump-via-forest-city-long-and-burrows-lo',
    name: 'Camel\'s Hump via Forest City, Long and Burrows Loop',
    park: 'Camel\'s Hump State Park',
    state: 'Vermont',
    lat: 44.3195,
    lng: -72.8863,
    lengthMiles: 5.6,
    elevationGainFt: 2408,
    difficulty: Difficulty.hard,
    rating: 4.4,
    reviewCount: 11447,
    dogFriendly: true,
    kidFriendly: false,
    fee: 'Free',
    description:
        'Vermont\'s most beloved mountain is an undeveloped 4,083-foot alpine '
        'summit with a distinctive camel-hump profile. The loop through boreal '
        'forest and stunted alpine vegetation leads to airy ledges and huge '
        'views. It is the state\'s signature peak and its only undeveloped '
        '4,000-footer.',
    tags: ['Summit', 'Alpine', 'Views'],
    routePoints: _route(44.3195, -72.8863,
        spanDeg: 0.0252, loop: true, seed: 108),
  ),
  Trail(
    id: 'sterling-pond-trail',
    name: 'Sterling Pond Trail',
    park: 'Smugglers\' Notch State Park',
    state: 'Vermont',
    lat: 44.5553,
    lng: -72.7957,
    lengthMiles: 3.3,
    elevationGainFt: 1320,
    difficulty: Difficulty.moderate,
    rating: 4.7,
    reviewCount: 7673,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'A steep boardwalk climb through the notch leads to Vermont\'s '
        'highest-elevation trout pond, cradled below Mount Mansfield. Loons call '
        'across the still water on quiet mornings. Pair it with the short '
        'scramble to the notch overlooks for dramatic cliff views.',
    tags: ['Alpine Lake', 'Notch', 'Views'],
    routePoints: _route(44.5553, -72.7957,
        spanDeg: 0.0148, loop: true, seed: 109),
  ),
  Trail(
    id: 'mount-greylock-via-bellows-pipe-trail',
    name: 'Mount Greylock via Bellows Pipe Trail',
    park: 'Mount Greylock State Reservation',
    state: 'Massachusetts',
    lat: 42.62756,
    lng: -73.14498,
    lengthMiles: 5.7,
    elevationGainFt: 2241,
    difficulty: Difficulty.hard,
    rating: 4.4,
    reviewCount: 10454,
    dogFriendly: true,
    kidFriendly: false,
    fee: 'Free',
    description:
        'The toughest approach up Massachusetts\' highest peak climbs past Money '
        'Brook and March Cataract Falls through old-growth spruce. The 3,491-foot '
        'summit is crowned with the Veterans War Memorial Tower and views across '
        'three states. A rite of passage for every Bay State hiker.',
    tags: ['Summit', 'Waterfall', 'Memorial Tower'],
    routePoints: _route(42.62756, -73.14498,
        spanDeg: 0.0256, loop: false, seed: 110),
  ),
  Trail(
    id: 'bash-bish-falls-trail',
    name: 'Bash Bish Falls Trail',
    park: 'Bash Bish Falls State Park',
    state: 'Massachusetts',
    lat: 42.11501,
    lng: -73.49165,
    lengthMiles: 2.0,
    elevationGainFt: 535,
    difficulty: Difficulty.moderate,
    rating: 4.5,
    reviewCount: 906,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'A short riverside walk descends into a rocky gorge ending at '
        'Massachusetts\' tallest waterfall, plunging 60 feet into a turquoise '
        'pool. Towering hemlocks and mossy cliffs frame the cascades. The falls '
        'are iconic; swimming at the base is prohibited but the views are worth '
        'the trip.',
    tags: ['Waterfall', 'Gorge', 'Swimming Hole'],
    routePoints: _route(42.11501, -73.49165,
        spanDeg: 0.009, loop: false, seed: 111),
  ),
  Trail(
    id: 'wachusett-mountain-via-echo-lake-and-jack-frost',
    name: 'Wachusett Mountain via Echo Lake and Jack Frost',
    park: 'Wachusett Mountain State Reservation',
    state: 'Massachusetts',
    lat: 42.51887,
    lng: -71.88025,
    lengthMiles: 3.0,
    elevationGainFt: 807,
    difficulty: Difficulty.moderate,
    rating: 4.8,
    reviewCount: 3415,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'Central Massachusetts\' most popular summit offers a breezy 2,006-foot '
        'top with a fire tower and views to Boston and Mount Monadnock. The loop '
        'around Echo Lake adds variety with forested trails and lakeside '
        'stretches. In fall, the foliage from the summit is legendary.',
    tags: ['Summit', 'Lake', 'Views'],
    routePoints: _route(42.51887, -71.88025,
        spanDeg: 0.0135, loop: true, seed: 112),
  ),
  Trail(
    id: 'cliff-walk',
    name: 'Cliff Walk',
    park: 'Newport',
    state: 'Rhode Island',
    lat: 41.48866,
    lng: -71.29062,
    lengthMiles: 7.0,
    elevationGainFt: 291,
    difficulty: Difficulty.easy,
    rating: 4.7,
    reviewCount: 6374,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'This 3.5-mile one-way coastal path threads between Newport\'s Gilded Age '
        'mansions and the pounding Atlantic. Rocky shorelines, tunnels, and ocean '
        'vistas alternate with views of marble palaces. It is a National '
        'Recreation Trail and Rhode Island\'s signature stroll.',
    tags: ['Coastal', 'Mansions', 'Ocean Views'],
    routePoints: _route(41.48866, -71.29062,
        spanDeg: 0.0315, loop: false, seed: 113),
  ),
  Trail(
    id: 'sachuest-point-national-wildlife-refuge-trail',
    name: 'Sachuest Point National Wildlife Refuge Trail',
    park: 'Sachuest Point National Wildlife Refuge',
    state: 'Rhode Island',
    lat: 41.4797,
    lng: -71.244,
    lengthMiles: 2.5,
    elevationGainFt: 65,
    difficulty: Difficulty.easy,
    rating: 4.5,
    reviewCount: 4327,
    dogFriendly: false,
    kidFriendly: true,
    fee: 'Free',
    description:
        'A flat, wheelchair-accessible 2.5-mile loop around a windswept peninsula '
        'of rocky shore and salt marsh. Winter brings harlequin ducks and snowy '
        'owls; summer brings nesting shorebirds and sea breezes. A visitor center '
        'with exhibits anchors the trailhead.',
    tags: ['Coastal', 'Birding', 'Wildlife'],
    routePoints: _route(41.4797, -71.244,
        spanDeg: 0.0112, loop: true, seed: 114),
  ),
  Trail(
    id: 'sleeping-giant-tower-trail',
    name: 'Sleeping Giant Tower Trail',
    park: 'Sleeping Giant State Park',
    state: 'Connecticut',
    lat: 41.42176,
    lng: -72.89946,
    lengthMiles: 3.1,
    elevationGainFt: 600,
    difficulty: Difficulty.moderate,
    rating: 4.9,
    reviewCount: 6314,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free (CT plates); out-of-state vehicle fee',
    description:
        'The giant ridgeline above Quinnipiac resembles a sleeping figure, and '
        'its stone tower commands views to Long Island Sound. A network of trails '
        'crosses trap-rock ridges and hemlock groves. The tower trail is '
        'Connecticut\'s classic family hike.',
    tags: ['Summit', 'Tower', 'Views'],
    routePoints: _route(41.42176, -72.89946,
        spanDeg: 0.0139, loop: false, seed: 115),
  ),
  Trail(
    id: 'bear-mountain-via-undermountain-and-appalachian-',
    name: 'Bear Mountain via Undermountain and Appalachian Trails',
    park: 'Appalachian Trail, Salisbury',
    state: 'Connecticut',
    lat: 41.99296,
    lng: -73.42612,
    lengthMiles: 5.6,
    elevationGainFt: 1797,
    difficulty: Difficulty.hard,
    rating: 4.4,
    reviewCount: 7024,
    dogFriendly: true,
    kidFriendly: false,
    fee: 'Free',
    description:
        'Connecticut\'s highest summit at 2,316 feet is reached via the AT\'s '
        'famous Undermountain Trail past Riga Falls. The rocky summit\'s stone '
        'obelisk frames views of the Berkshires and Catskills. A stiff climb that '
        'earns its views.',
    tags: ['Summit', 'AT', 'Tallest in CT'],
    routePoints: _route(41.99296, -73.42612,
        spanDeg: 0.0252, loop: false, seed: 116),
  ),
  Trail(
    id: 'talcott-mountain-yellow-trail-to-heublein-tower',
    name: 'Talcott Mountain Yellow Trail to Heublein Tower',
    park: 'Talcott Mountain State Park',
    state: 'Connecticut',
    lat: 41.83844,
    lng: -72.78493,
    lengthMiles: 3.0,
    elevationGainFt: 446,
    difficulty: Difficulty.moderate,
    rating: 4.4,
    reviewCount: 6435,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free (CT residents); out-of-state vehicle fee',
    description:
        'A gentle 3-mile loop climbs to the Heublein Tower, a 165-foot Germanic '
        'castle-like structure on Talcott Mountain\'s ridge. The tower\'s '
        'observation room overlooks the Farmington Valley and Hartford skyline. '
        'Picnic grounds at the base make it a perfect family outing.',
    tags: ['Tower', 'Views', 'Loop'],
    routePoints: _route(41.83844, -72.78493,
        spanDeg: 0.0135, loop: true, seed: 117),
  ),
  Trail(
    id: 'breakneck-ridge-long-loop',
    name: 'Breakneck Ridge Long Loop',
    park: 'Hudson Highlands State Park',
    state: 'New York',
    lat: 41.44563,
    lng: -73.97934,
    lengthMiles: 3.2,
    elevationGainFt: 1269,
    difficulty: Difficulty.hard,
    rating: 4.7,
    reviewCount: 1511,
    dogFriendly: false,
    kidFriendly: false,
    fee: 'Free',
    description:
        'The steepest, most adrenaline-pumping scramble in the Hudson Highlands '
        'climbs rock faces with sweeping views of the Hudson River. Each bump of '
        'the ridge offers a bigger panorama, from Storm King to the Catskills. '
        'Trailheads have been closed since April 2025 for about two years of '
        'construction; check status before going.',
    tags: ['Rock Scramble', 'Hudson River', 'Views'],
    routePoints: _route(41.44563, -73.97934,
        spanDeg: 0.0144, loop: true, seed: 118),
  ),
  Trail(
    id: 'bear-mountain-via-major-welch-and-at-loop',
    name: 'Bear Mountain via Major Welch and AT Loop',
    park: 'Bear Mountain State Park',
    state: 'New York',
    lat: 41.31311,
    lng: -73.9897,
    lengthMiles: 4.3,
    elevationGainFt: 1151,
    difficulty: Difficulty.moderate,
    rating: 4.7,
    reviewCount: 9585,
    dogFriendly: true,
    kidFriendly: true,
    fee: '\$10 vehicle (NY state parks)',
    description:
        'A classic loop combining the steep Major Welch Trail with the '
        'Appalachian Trail around Hessian Lake. The summit\'s Perkins Memorial '
        'Tower overlooks the Hudson Valley and the Bear Mountain Bridge. A zoo '
        'and carousel at the base make it a full-day family destination.',
    tags: ['Summit', 'Hudson River', 'Loop'],
    routePoints: _route(41.31311, -73.9897,
        spanDeg: 0.0193, loop: true, seed: 119),
  ),
  Trail(
    id: 'kaaterskill-falls-trail-and-viewing-platform',
    name: 'Kaaterskill Falls Trail and Viewing Platform',
    park: 'Catskill Park',
    state: 'New York',
    lat: 42.19562,
    lng: -74.06351,
    lengthMiles: 1.6,
    elevationGainFt: 374,
    difficulty: Difficulty.moderate,
    rating: 4.4,
    reviewCount: 7001,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'New York\'s most famous waterfall drops 260 feet in two tiers through a '
        'dramatic Catskill gorge. The trail leads to an ADA-accessible viewing '
        'platform with a straight-on view of the cascades. Rip Van Winkle country '
        'at its most photogenic.',
    tags: ['Waterfall', 'Viewing Platform', 'Catskills'],
    routePoints: _route(42.19562, -74.06351,
        spanDeg: 0.0072, loop: false, seed: 120),
  ),
  Trail(
    id: 'mount-tammany-loop-red-dot-blue-blaze',
    name: 'Mount Tammany Loop (Red Dot/Blue Blaze)',
    park: 'Worthington State Forest, Delaware Water Gap NRA',
    state: 'New Jersey',
    lat: 40.97188,
    lng: -75.12382,
    lengthMiles: 3.5,
    elevationGainFt: 1198,
    difficulty: Difficulty.hard,
    rating: 4.3,
    reviewCount: 5603,
    dogFriendly: true,
    kidFriendly: false,
    fee: 'Free',
    description:
        'The Delaware Water Gap\'s signature scramble climbs rocky switchbacks to '
        'a summit with jaw-dropping views of the gap. The loop descends the '
        'gentler Blue Blaze past small waterfalls. It is the most popular, and '
        'most rewarding, short hike in the region.',
    tags: ['Summit', 'Water Gap', 'Views'],
    routePoints: _route(40.97188, -75.12382,
        spanDeg: 0.0158, loop: true, seed: 121),
  ),
  Trail(
    id: 'stairway-to-heaven-trail-at-pinwheel-vista',
    name: 'Stairway to Heaven Trail (AT/Pinwheel Vista)',
    park: 'Wawayanda State Park, Appalachian Trail',
    state: 'New Jersey',
    lat: 41.20397,
    lng: -74.47681,
    lengthMiles: 2.8,
    elevationGainFt: 898,
    difficulty: Difficulty.moderate,
    rating: 4.8,
    reviewCount: 10933,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'This AT section crosses a long boardwalk through the Pochuck wetlands '
        'before climbing to Pinwheel Vista. The rocky summit overlooks the '
        'Kittatinny Valley and Pochuck Swamp. A perfect introduction to the '
        'Appalachian Trail in New Jersey.',
    tags: ['AT', 'Boardwalk', 'Vista'],
    routePoints: _route(41.20397, -74.47681,
        spanDeg: 0.0126, loop: false, seed: 122),
  ),
  Trail(
    id: 'sunfish-pond-via-dunnfield-creek-trail',
    name: 'Sunfish Pond via Dunnfield Creek Trail',
    park: 'Worthington State Forest, Delaware Water Gap NRA',
    state: 'New Jersey',
    lat: 40.97175,
    lng: -75.12563,
    lengthMiles: 9.0,
    elevationGainFt: 800,
    difficulty: Difficulty.moderate,
    rating: 4.8,
    reviewCount: 6725,
    dogFriendly: true,
    kidFriendly: false,
    fee: 'Free',
    description:
        'A 9-mile round trip through the Delaware Water Gap\'s wildest backcountry '
        'reaches a pristine glacial lake atop Kittatinny Ridge. The Dunnfield '
        'Creek Trail passes small falls and rhododendron thickets. Sunfish Pond '
        'is a National Natural Landmark; swimming is prohibited.',
    tags: ['Glacial Lake', 'Waterfall', 'Wilderness'],
    routePoints: _route(40.97175, -75.12563,
        spanDeg: 0.0405, loop: false, seed: 123),
  ),
  Trail(
    id: 'ricketts-glen-falls-loop',
    name: 'Ricketts Glen Falls Loop',
    park: 'Ricketts Glen State Park',
    state: 'Pennsylvania',
    lat: 41.32988,
    lng: -76.29109,
    lengthMiles: 6.3,
    elevationGainFt: 1040,
    difficulty: Difficulty.hard,
    rating: 4.6,
    reviewCount: 1939,
    dogFriendly: true,
    kidFriendly: false,
    fee: 'Free',
    description:
        'The crown jewel of Pennsylvania hiking passes 21 named waterfalls, '
        'including the 94-foot Ganoga Falls, in a single loop. The Falls Trail '
        'threads mossy gorges and rocky steps past one cascade after another. '
        'Arguably the finest waterfall hike east of the Mississippi.',
    tags: ['Waterfalls', 'Gorge', 'Loop'],
    routePoints: _route(41.32988, -76.29109,
        spanDeg: 0.0283, loop: true, seed: 124),
  ),
  Trail(
    id: 'pulpit-rock-and-pinnacle-loop',
    name: 'Pulpit Rock and Pinnacle Loop',
    park: 'Appalachian Trail, State Game Lands 106',
    state: 'Pennsylvania',
    lat: 40.58309,
    lng: -75.93733,
    lengthMiles: 9.3,
    elevationGainFt: 1250,
    difficulty: Difficulty.moderate,
    rating: 4.3,
    reviewCount: 4533,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'This long AT loop rewards with two of the finest overlooks in '
        'Pennsylvania: the Pinnacle\'s sweeping valley view and Pulpit Rock\'s '
        'dramatic perch. Rhododendron tunnels and talus slopes add variety along '
        'the ridge. A favorite training hike for thru-hiker hopefuls.',
    tags: ['Overlook', 'AT', 'Ridgeline'],
    routePoints: _route(40.58309, -75.93733,
        spanDeg: 0.0418, loop: true, seed: 125),
  ),
  Trail(
    id: 'mount-minsi-via-appalachian-trail',
    name: 'Mount Minsi via Appalachian Trail',
    park: 'Delaware Water Gap NRA',
    state: 'Pennsylvania',
    lat: 40.9786,
    lng: -75.14032,
    lengthMiles: 4.9,
    elevationGainFt: 1035,
    difficulty: Difficulty.moderate,
    rating: 4.8,
    reviewCount: 2107,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'Across the river from Mount Tammany, Pennsylvania\'s Mount Minsi offers '
        'equally stunning Water Gap views via the Appalachian Trail. Lookout Rock '
        'and Council Rock frame the Delaware River slicing through Kittatinny '
        'Mountain. Quieter and more gradual than its New Jersey twin.',
    tags: ['AT', 'Water Gap', 'Lookouts'],
    routePoints: _route(40.9786, -75.14032,
        spanDeg: 0.0221, loop: false, seed: 126),
  ),
  Trail(
    id: 'white-clay-creek-state-park-loop',
    name: 'White Clay Creek State Park Loop',
    park: 'White Clay Creek State Park',
    state: 'Delaware',
    lat: 39.7233,
    lng: -75.7569,
    lengthMiles: 10.5,
    elevationGainFt: 816,
    difficulty: Difficulty.moderate,
    rating: 4.8,
    reviewCount: 2454,
    dogFriendly: true,
    kidFriendly: true,
    fee: '\$4-8 vehicle (DE state parks)',
    description:
        'Delaware\'s premier trail system weaves 37 miles of paths through the '
        'Piedmont\'s rolling forests and the White Clay Creek valley. The popular '
        '10.5-mile loop samples streams, covered-bridge country, and lush woods. '
        'A surprisingly wild escape in the Mid-Atlantic suburbs.',
    tags: ['Creek', 'Woods', 'Loop'],
    routePoints: _route(39.7233, -75.7569,
        spanDeg: 0.0472, loop: true, seed: 127),
  ),
  Trail(
    id: 'gordon-s-pond-trail',
    name: 'Gordon\'s Pond Trail',
    park: 'Cape Henlopen State Park',
    state: 'Delaware',
    lat: 38.76919,
    lng: -75.09845,
    lengthMiles: 3.2,
    elevationGainFt: 26,
    difficulty: Difficulty.easy,
    rating: 4.5,
    reviewCount: 8228,
    dogFriendly: true,
    kidFriendly: true,
    fee: '\$4-8 vehicle (DE state parks)',
    description:
        'A flat, easy trail through salt marsh and maritime forest along the '
        'Delaware Bay coast. Boardwalks cross the marsh where herons and osprey '
        'hunt, and the trail ends at the ocean near Herring Point. One of '
        'Delaware\'s best birding walks.',
    tags: ['Coastal', 'Boardwalk', 'Wildlife'],
    routePoints: _route(38.76919, -75.09845,
        spanDeg: 0.0144, loop: false, seed: 128),
  ),
  Trail(
    id: 'billy-goat-trail-section-a-and-great-falls-overl',
    name: 'Billy Goat Trail Section A and Great Falls Overlook',
    park: 'Chesapeake and Ohio Canal NHP',
    state: 'Maryland',
    lat: 39.00021,
    lng: -77.24817,
    lengthMiles: 4.8,
    elevationGainFt: 203,
    difficulty: Difficulty.hard,
    rating: 4.7,
    reviewCount: 6777,
    dogFriendly: false,
    kidFriendly: false,
    fee: '\$20 vehicle (NPS pass)',
    description:
        'The most famous rock scramble near DC traverses the Potomac\'s '
        'boulder-strewn gorge along the C&O Canal. Hikers hop across rocks with '
        'views of Great Falls\' thundering cascades. Section A is the wildest '
        'stretch, and dogs are prohibited on this section.',
    tags: ['Rock Scramble', 'Potomac', 'Waterfall'],
    routePoints: _route(39.00021, -77.24817,
        spanDeg: 0.0216, loop: true, seed: 129),
  ),
  Trail(
    id: 'maryland-heights-via-harpers-ferry',
    name: 'Maryland Heights via Harpers Ferry',
    park: 'Harpers Ferry NHP',
    state: 'Maryland',
    lat: 39.31439,
    lng: -77.76334,
    lengthMiles: 4.5,
    elevationGainFt: 1062,
    difficulty: Difficulty.moderate,
    rating: 4.4,
    reviewCount: 6620,
    dogFriendly: true,
    kidFriendly: true,
    fee: '\$20 vehicle (NPS pass)',
    description:
        'This steep climb above Harpers Ferry ends at a Civil War-era overlook '
        'with the iconic view of the Shenandoah and Potomac rivers meeting. Stone '
        'fortifications and artillery batteries line the trail. History and '
        'scenery in perfect combination.',
    tags: ['Overlook', 'Civil War', 'River Confluence'],
    routePoints: _route(39.31439, -77.76334,
        spanDeg: 0.0202, loop: false, seed: 130),
  ),
  Trail(
    id: 'old-rag-circuit',
    name: 'Old Rag Circuit',
    park: 'Shenandoah National Park',
    state: 'Virginia',
    lat: 38.5714,
    lng: -78.2931,
    lengthMiles: 9.4,
    elevationGainFt: 2348,
    difficulty: Difficulty.hard,
    rating: 4.4,
    reviewCount: 5174,
    dogFriendly: false,
    kidFriendly: false,
    fee: '\$35 vehicle (NPS pass) + \$2 day-use ticket',
    description:
        'Shenandoah\'s legendary rock scramble squeezes through boulder chutes and '
        'across granite slabs to a 3,291-foot summit. The 9.4-mile circuit is a '
        'rite of passage for Mid-Atlantic hikers. Timed day-use tickets are '
        'required, so plan ahead.',
    tags: ['Rock Scramble', 'Summit', 'Views'],
    routePoints: _route(38.5714, -78.2931,
        spanDeg: 0.0423, loop: true, seed: 131),
  ),
  Trail(
    id: 'mcafee-knob-via-appalachian-trail',
    name: 'McAfee Knob via Appalachian Trail',
    park: 'Jefferson National Forest / McAfee Knob',
    state: 'Virginia',
    lat: 37.38029,
    lng: -80.09921,
    lengthMiles: 8.0,
    elevationGainFt: 1654,
    difficulty: Difficulty.moderate,
    rating: 4.7,
    reviewCount: 11999,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'The most photographed spot on the entire Appalachian Trail: a dramatic '
        'stone ledge jutting over the Catawba Valley. The 8-mile round trip '
        'follows the AT through open meadows and ridgetop forest. Sunrise here is '
        'unforgettable.',
    tags: ['AT', 'Ledge', 'Views'],
    routePoints: _route(37.38029, -80.09921,
        spanDeg: 0.036, loop: false, seed: 132),
  ),
  Trail(
    id: 'humpback-rocks',
    name: 'Humpback Rocks',
    park: 'Blue Ridge Parkway MP 6',
    state: 'Virginia',
    lat: 37.96746,
    lng: -78.90059,
    lengthMiles: 2.0,
    elevationGainFt: 700,
    difficulty: Difficulty.moderate,
    rating: 4.7,
    reviewCount: 10780,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'A short but steep climb off the Blue Ridge Parkway leads to massive '
        'greenstone outcrops with sweeping Shenandoah Valley views. The nearby '
        'Mountain Farm Museum showcases 19th-century Appalachian homesteads. A '
        'perfect sunset stop on the Parkway.',
    tags: ['Rock Outcrop', 'Parkway', 'Sunset'],
    routePoints: _route(37.96746, -78.90059,
        spanDeg: 0.009, loop: false, seed: 133),
  ),
  Trail(
    id: 'blackbird-knob-to-harman-to-rocky-ridge-loop',
    name: 'Blackbird Knob to Harman to Rocky Ridge Loop',
    park: 'Dolly Sods Wilderness',
    state: 'West Virginia',
    lat: 39.03348,
    lng: -79.31424,
    lengthMiles: 6.0,
    elevationGainFt: 679,
    difficulty: Difficulty.moderate,
    rating: 4.7,
    reviewCount: 9551,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'West Virginia\'s most otherworldly hike crosses windswept heath barrens '
        'and red spruce bogs that feel like Canada. Rocky ridges, mountain '
        'cranberry bogs, and huge views define this wilderness loop. Fall color '
        'here is spectacular.',
    tags: ['Wilderness', 'Meadows', 'Loop'],
    routePoints: _route(39.03348, -79.31424,
        spanDeg: 0.027, loop: true, seed: 134),
  ),
  Trail(
    id: 'seneca-rocks-trail',
    name: 'Seneca Rocks Trail',
    park: 'Spruce Knob-Seneca Rocks NRA',
    state: 'West Virginia',
    lat: 38.83557,
    lng: -79.37261,
    lengthMiles: 3.6,
    elevationGainFt: 840,
    difficulty: Difficulty.moderate,
    rating: 4.7,
    reviewCount: 3477,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'The trail switchbacks up to an observation deck beneath one of the '
        'East\'s most dramatic rock fins. Sheer Tuscarora sandstone walls tower '
        'above, dotted with climbers. The view west over the Germany Valley is '
        'unforgettable.',
    tags: ['Rock Fin', 'Overlook', 'Climbing'],
    routePoints: _route(38.83557, -79.37261,
        spanDeg: 0.0162, loop: false, seed: 135),
  ),
  Trail(
    id: 'endless-wall-trail',
    name: 'Endless Wall Trail',
    park: 'New River Gorge National Park',
    state: 'West Virginia',
    lat: 38.0596,
    lng: -81.0491,
    lengthMiles: 2.4,
    elevationGainFt: 427,
    difficulty: Difficulty.moderate,
    rating: 4.6,
    reviewCount: 5222,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'A clifftop trail along the New River Gorge rim threads rhododendron '
        'tunnels to one dizzying overlook after another. Ladders descend to the '
        'base of the cliffs for a different perspective. Short, easy, and '
        'endlessly scenic.',
    tags: ['Cliff Views', 'Gorge', 'Ladders'],
    routePoints: _route(38.0596, -81.0491,
        spanDeg: 0.0108, loop: true, seed: 136),
  ),
  Trail(
    id: 'grays-and-torreys-peaks-trail',
    name: 'Grays and Torreys Peaks Trail',
    park: 'Arapaho National Forest',
    state: 'Colorado',
    lat: 39.6611,
    lng: -105.7840,
    lengthMiles: 8.3,
    elevationGainFt: 3605,
    difficulty: Difficulty.hard,
    rating: 4.9,
    reviewCount: 11285,
    dogFriendly: true,
    kidFriendly: false,
    fee: 'Free',
    description:
        'Two of Colorado\'s most popular 14ers in a single hike, joined by a '
        'saddle at 13,707 ft. A steep, fully exposed alpine climb above treeline '
        'with sweeping Continental Divide views. Arrive before dawn in summer for '
        'parking and to beat afternoon storms.',
    tags: ['Summit', '14er', 'Alpine', 'Views'],
    routePoints: _route(39.6611, -105.7840,
        spanDeg: 0.0374, loop: false, seed: 137),
  ),
  Trail(
    id: 'quandary-peak-east-ridge',
    name: 'Quandary Peak (East Ridge)',
    park: 'White River National Forest',
    state: 'Colorado',
    lat: 39.3856,
    lng: -106.0618,
    lengthMiles: 6.75,
    elevationGainFt: 3450,
    difficulty: Difficulty.hard,
    rating: 4.7,
    reviewCount: 4398,
    dogFriendly: true,
    kidFriendly: false,
    fee: '\$30 parking reservation (or free shuttle)',
    description:
        'Colorado\'s most-climbed 14er via a nontechnical Class 1 ridge route with '
        'world-class views of the Mosquito and Gore ranges. Mountain goats '
        'frequent the upper slopes. A parking reservation is now required in '
        'season.',
    tags: ['Summit', '14er', 'Views', 'Wildlife'],
    routePoints: _route(39.3856, -106.0618,
        spanDeg: 0.0304, loop: false, seed: 138),
  ),
  Trail(
    id: 'emerald-lake-trail',
    name: 'Emerald Lake Trail',
    park: 'Rocky Mountain National Park',
    state: 'Colorado',
    lat: 40.3117,
    lng: -105.6461,
    lengthMiles: 3.4,
    elevationGainFt: 692,
    difficulty: Difficulty.moderate,
    rating: 4.7,
    reviewCount: 1716,
    dogFriendly: false,
    kidFriendly: true,
    fee: '\$30 vehicle (NPS pass)',
    description:
        'RMNP\'s most beloved short hike, passing Nymph and Dream Lakes to a '
        'turquoise alpine lake beneath Hallett Peak\'s sheer cliffs. Short but '
        'punchy; a Bear Lake timed-entry reservation is required in summer.',
    tags: ['Lake', 'Alpine', 'Waterfall', 'Views'],
    routePoints: _route(40.3117, -105.6461,
        spanDeg: 0.0153, loop: false, seed: 139),
  ),
  Trail(
    id: 'jenny-lake-loop',
    name: 'Jenny Lake Loop',
    park: 'Grand Teton National Park',
    state: 'Wyoming',
    lat: 43.7515,
    lng: -110.7254,
    lengthMiles: 7.1,
    elevationGainFt: 1040,
    difficulty: Difficulty.moderate,
    rating: 4.4,
    reviewCount: 1325,
    dogFriendly: false,
    kidFriendly: true,
    fee: '\$35 vehicle (NPS pass)',
    description:
        'A scenic lakeside loop beneath the Cathedral Group, with the Grand, Mt. '
        'Owen, and Teewinot towering over glacial Jenny Lake. Add the spur to '
        'Hidden Falls and Inspiration Point, or take the boat shuttle to skip the '
        'north shore. Parking fills by 9am.',
    tags: ['Lake', 'Waterfall', 'Views', 'Loop'],
    routePoints: _route(43.7515, -110.7254,
        spanDeg: 0.0319, loop: true, seed: 140),
  ),
  Trail(
    id: 'tower-trail',
    name: 'Tower Trail',
    park: 'Devils Tower National Monument',
    state: 'Wyoming',
    lat: 44.5909,
    lng: -104.7203,
    lengthMiles: 1.3,
    elevationGainFt: 164,
    difficulty: Difficulty.easy,
    rating: 4.8,
    reviewCount: 7372,
    dogFriendly: false,
    kidFriendly: true,
    fee: '\$25 vehicle (NPS pass)',
    description:
        'A fully paved loop circling the base of America\'s first national '
        'monument, with ever-shifting angles of the 1,267-ft igneous columns. '
        'Watch for rock climbers on the tower and prairie dogs in the meadows.',
    tags: ['Geologic', 'Views', 'Loop', 'Wildlife'],
    routePoints: _route(44.5909, -104.7203,
        spanDeg: 0.0059, loop: true, seed: 141),
  ),
  Trail(
    id: 'grinnell-glacier-trail',
    name: 'Grinnell Glacier Trail',
    park: 'Glacier National Park',
    state: 'Montana',
    lat: 48.7973,
    lng: -113.6687,
    lengthMiles: 10.6,
    elevationGainFt: 1600,
    difficulty: Difficulty.hard,
    rating: 4.5,
    reviewCount: 4256,
    dogFriendly: false,
    kidFriendly: false,
    fee: '\$35 vehicle (NPS pass)',
    description:
        'Glacier NP\'s signature hike to a living, shrinking glacier, passing '
        'turquoise Grinnell and Josephine Lakes. Waterfalls, wildflower meadows, '
        'and frequent moose and grizzly sightings make bear spray essential. Boat '
        'shuttles can trim about 4 miles.',
    tags: ['Glacier', 'Lake', 'Waterfall', 'Wildlife'],
    routePoints: _route(48.7973, -113.6687,
        spanDeg: 0.0477, loop: false, seed: 142),
  ),
  Trail(
    id: 'highline-trail-logan-pass-to-the-loop',
    name: 'Highline Trail (Logan Pass to the Loop)',
    park: 'Glacier National Park',
    state: 'Montana',
    lat: 48.6966,
    lng: -113.7180,
    lengthMiles: 11.8,
    elevationGainFt: 800,
    difficulty: Difficulty.moderate,
    rating: 4.8,
    reviewCount: 10092,
    dogFriendly: false,
    kidFriendly: false,
    fee: '\$35 vehicle (NPS pass)',
    description:
        'A contour traverse along the Garden Wall on the Continental Divide, one '
        'of Glacier\'s most iconic day hikes. Cliffside ledges with a hand cable, '
        'mountain goats, and sweeping views down the Going-to-the-Sun corridor; '
        'usually hiked point-to-point via shuttle.',
    tags: ['Views', 'Wildflowers', 'Wildlife', 'Alpine'],
    routePoints: _route(48.6966, -113.7180,
        spanDeg: 0.0531, loop: false, seed: 143),
  ),
  Trail(
    id: 'avalanche-lake-trail',
    name: 'Avalanche Lake Trail',
    park: 'Glacier National Park',
    state: 'Montana',
    lat: 48.6781,
    lng: -113.8164,
    lengthMiles: 5.9,
    elevationGainFt: 757,
    difficulty: Difficulty.moderate,
    rating: 4.8,
    reviewCount: 5955,
    dogFriendly: false,
    kidFriendly: true,
    fee: '\$35 vehicle (NPS pass)',
    description:
        'A family favorite through ancient cedar-hemlock forest to a pristine '
        'lake walled by cliffs shedding waterfalls from Sperry Glacier. Shares '
        'its start with the wheelchair-accessible Trail of the Cedars. Grizzly '
        'country, so carry spray.',
    tags: ['Lake', 'Waterfall', 'Forest', 'Wildlife'],
    routePoints: _route(48.6781, -113.8164,
        spanDeg: 0.0266, loop: false, seed: 144),
  ),
  Trail(
    id: 'angels-landing',
    name: 'Angels Landing',
    park: 'Zion National Park',
    state: 'Utah',
    lat: 37.2591,
    lng: -112.9510,
    lengthMiles: 4.8,
    elevationGainFt: 1488,
    difficulty: Difficulty.hard,
    rating: 4.4,
    reviewCount: 8979,
    dogFriendly: false,
    kidFriendly: false,
    fee: '\$35 vehicle (NPS pass) + \$6 permit lottery',
    description:
        'Zion\'s bucket-list fin: a chain-assisted scramble along a knife-edge '
        'ridge 1,488 ft above the Virgin River. Walter\'s Wiggles switchbacks lead '
        'to Scout Lookout, and the chained final half-mile demands no fear of '
        'heights. A permit is required past Scout Lookout.',
    tags: ['Summit', 'Views', 'Canyon', 'Cliffside'],
    routePoints: _route(37.2591, -112.9510,
        spanDeg: 0.0216, loop: false, seed: 145),
  ),
  Trail(
    id: 'the-narrows-bottom-up',
    name: 'The Narrows (Bottom-Up)',
    park: 'Zion National Park',
    state: 'Utah',
    lat: 37.2849,
    lng: -112.9486,
    lengthMiles: 8.6,
    elevationGainFt: 400,
    difficulty: Difficulty.moderate,
    rating: 4.5,
    reviewCount: 11332,
    dogFriendly: false,
    kidFriendly: true,
    fee: '\$35 vehicle (NPS pass)',
    description:
        'The signature Zion adventure: hiking in the Virgin River between '
        '1,000-ft walls through the narrowest slot canyon section. Go as far as '
        'you like up to Big Springs, 4.3 miles in; rent canyoneering shoes and '
        'dry bags in Springdale. Check the flash flood forecast first.',
    tags: ['River', 'Canyon', 'Slot Canyon', 'Waterfall'],
    routePoints: _route(37.2849, -112.9486,
        spanDeg: 0.0387, loop: false, seed: 146),
  ),
  Trail(
    id: 'delicate-arch',
    name: 'Delicate Arch',
    park: 'Arches National Park',
    state: 'Utah',
    lat: 38.7355,
    lng: -109.5207,
    lengthMiles: 3.2,
    elevationGainFt: 629,
    difficulty: Difficulty.hard,
    rating: 4.6,
    reviewCount: 5139,
    dogFriendly: false,
    kidFriendly: false,
    fee: '\$30 vehicle (NPS pass)',
    description:
        'Utah\'s most famous landmark: a 65-ft freestanding arch in a natural '
        'red-rock amphitheater with the La Sal Mountains behind. The slickrock '
        'climb is fully exposed with no shade, and sunset is prime time. Timed '
        'entry is required at Arches.',
    tags: ['Arch', 'Slickrock', 'Sunset', 'Views'],
    routePoints: _route(38.7355, -109.5207,
        spanDeg: 0.0144, loop: false, seed: 147),
  ),
  Trail(
    id: 'cathedral-rock-trail',
    name: 'Cathedral Rock Trail',
    park: 'Spring Mountains National Recreation Area',
    state: 'Nevada',
    lat: 36.2541,
    lng: -115.6427,
    lengthMiles: 2.8,
    elevationGainFt: 1000,
    difficulty: Difficulty.hard,
    rating: 4.4,
    reviewCount: 9997,
    dogFriendly: true,
    kidFriendly: false,
    fee: 'Free',
    description:
        'The best short workout in the Spring Mountains: a steep 1,000-ft climb '
        'through ponderosa and aspen to a summit overlooking Kyle Canyon. Roughly '
        '30 degrees cooler than Las Vegas in summer. Closed in winter.',
    tags: ['Summit', 'Views', 'Forest', 'Desert'],
    routePoints: _route(36.2541, -115.6427,
        spanDeg: 0.0126, loop: false, seed: 148),
  ),
  Trail(
    id: 'calico-tanks-trail',
    name: 'Calico Tanks Trail',
    park: 'Red Rock Canyon National Conservation Area',
    state: 'Nevada',
    lat: 36.1626,
    lng: -115.4502,
    lengthMiles: 2.4,
    elevationGainFt: 420,
    difficulty: Difficulty.moderate,
    rating: 4.6,
    reviewCount: 10377,
    dogFriendly: true,
    kidFriendly: false,
    fee: '\$15 vehicle (timed entry)',
    description:
        'Red Rock Canyon\'s most popular trail: red-and-white Aztec sandstone '
        'scrambling to a hidden water tank and a lookout over the Las Vegas '
        'Strip. Short, physical, and photogenic; a timed entry reservation is '
        'required.',
    tags: ['Views', 'Scrambling', 'Desert', 'Sandstone'],
    routePoints: _route(36.1626, -115.4502,
        spanDeg: 0.0108, loop: false, seed: 149),
  ),
  Trail(
    id: 'alice-lake-trail',
    name: 'Alice Lake Trail',
    park: 'Sawtooth National Recreation Area',
    state: 'Idaho',
    lat: 43.9844,
    lng: -114.8719,
    lengthMiles: 11.0,
    elevationGainFt: 1600,
    difficulty: Difficulty.hard,
    rating: 4.6,
    reviewCount: 10360,
    dogFriendly: true,
    kidFriendly: false,
    fee: 'Free',
    description:
        'The classic Sawtooths day hike: five stream crossings through lodgepole '
        'forest to a turquoise lake beneath the jagged 9,901-ft El Capitan. A '
        'free self-issued wilderness permit is required at the boundary. Twin '
        'Lakes makes an easy extension.',
    tags: ['Lake', 'Alpine', 'Wildlife', 'Views'],
    routePoints: _route(43.9844, -114.8719,
        spanDeg: 0.0495, loop: false, seed: 150),
  ),
  Trail(
    id: 'table-rock-trail',
    name: 'Table Rock Trail',
    park: 'Boise Foothills (Ridge to Rivers)',
    state: 'Idaho',
    lat: 43.6037,
    lng: -116.1626,
    lengthMiles: 3.6,
    elevationGainFt: 892,
    difficulty: Difficulty.moderate,
    rating: 4.5,
    reviewCount: 4393,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'Boise\'s beloved sunset hike: a loop up a sandstone butte crowned with a '
        '60-ft illuminated cross, with panoramic views of downtown and the '
        'Treasure Valley. No shade, so go early or at golden hour; watch for '
        'mud-season closures.',
    tags: ['Views', 'Sunset', 'City', 'Loop'],
    routePoints: _route(43.6037, -116.1626,
        spanDeg: 0.0162, loop: true, seed: 151),
  ),
  Trail(
    id: 'rattlesnake-ledge',
    name: 'Rattlesnake Ledge',
    park: 'Rattlesnake Lake Recreation Area',
    state: 'Washington',
    lat: 47.4340,
    lng: -121.7684,
    lengthMiles: 4.0,
    elevationGainFt: 1160,
    difficulty: Difficulty.moderate,
    rating: 4.9,
    reviewCount: 3066,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'Seattle\'s classic first hike: a well-graded forest climb to rocky ledges '
        '1,160 ft above Rattlesnake Lake. Sweeping views of the Cascades, Mt. Si, '
        'and on clear days Mt. Rainier. Arrive early; the lot overflows on '
        'weekends.',
    tags: ['Views', 'Lake', 'Overlook', 'Forest'],
    routePoints: _route(47.4340, -121.7684,
        spanDeg: 0.018, loop: false, seed: 152),
  ),
  Trail(
    id: 'mount-si',
    name: 'Mount Si',
    park: 'Mount Si Natural Resources Conservation Area',
    state: 'Washington',
    lat: 47.4876,
    lng: -121.7233,
    lengthMiles: 8.0,
    elevationGainFt: 3150,
    difficulty: Difficulty.hard,
    rating: 4.6,
    reviewCount: 2289,
    dogFriendly: true,
    kidFriendly: false,
    fee: '\$10 day Discover Pass',
    description:
        'The I-90 corridor\'s famous quad-burner: 3,150 ft of switchbacks through '
        'old growth to a rocky basin overlooking the Snoqualmie Valley and '
        'Cascades. A rite of passage for Seattle hikers and Rainier conditioning. '
        'A Discover Pass is required.',
    tags: ['Summit', 'Views', 'Training', 'Forest'],
    routePoints: _route(47.4876, -121.7233,
        spanDeg: 0.036, loop: false, seed: 153),
  ),
  Trail(
    id: 'skyline-trail-panorama-point',
    name: 'Skyline Trail (Panorama Point)',
    park: 'Mount Rainier National Park',
    state: 'Washington',
    lat: 46.7867,
    lng: -121.7345,
    lengthMiles: 5.5,
    elevationGainFt: 1700,
    difficulty: Difficulty.moderate,
    rating: 4.8,
    reviewCount: 2596,
    dogFriendly: false,
    kidFriendly: true,
    fee: '\$30 vehicle (NPS pass)',
    description:
        'The quintessential Mt. Rainier day hike: a loop through subalpine '
        'wildflower meadows to Panorama Point with the mountain looming overhead. '
        'Marmots, Myrtle Falls, and on clear days views to Mt. Adams and Mt. St. '
        'Helens.',
    tags: ['Views', 'Glacier', 'Wildflowers', 'Waterfall'],
    routePoints: _route(46.7867, -121.7345,
        spanDeg: 0.0247, loop: true, seed: 154),
  ),
  Trail(
    id: 'multnomah-falls-trail',
    name: 'Multnomah Falls Trail',
    park: 'Columbia River Gorge National Scenic Area',
    state: 'Oregon',
    lat: 45.5763,
    lng: -122.1153,
    lengthMiles: 2.4,
    elevationGainFt: 800,
    difficulty: Difficulty.moderate,
    rating: 4.4,
    reviewCount: 3421,
    dogFriendly: true,
    kidFriendly: true,
    fee: '\$2 timed entry permit (May-Sep)',
    description:
        'Oregon\'s tallest waterfall at 620 ft draws over 2 million visitors a '
        'year; the paved switchback climb to the top adds perspective beyond '
        'Benson Bridge. Go early to beat crowds; a timed parking permit is '
        'required in summer. Dogs must stay leashed.',
    tags: ['Waterfall', 'Views', 'Canyon', 'Forest'],
    routePoints: _route(45.5763, -122.1153,
        spanDeg: 0.0108, loop: false, seed: 155),
  ),
  Trail(
    id: 'garfield-peak',
    name: 'Garfield Peak',
    park: 'Crater Lake National Park',
    state: 'Oregon',
    lat: 42.9342,
    lng: -122.1402,
    lengthMiles: 3.4,
    elevationGainFt: 1010,
    difficulty: Difficulty.moderate,
    rating: 4.8,
    reviewCount: 7716,
    dogFriendly: false,
    kidFriendly: false,
    fee: '\$30 vehicle (NPS pass)',
    description:
        'Crater Lake\'s best short climb: 1,010 ft along the caldera rim to an '
        '8,054-ft summit with a 360-degree panorama of the deepest blue lake in '
        'America. Pikas and marmots work the rocky slopes; snow lingers into '
        'July.',
    tags: ['Summit', 'Lake', 'Views', 'Wildflowers'],
    routePoints: _route(42.9342, -122.1402,
        spanDeg: 0.0153, loop: false, seed: 156),
  ),
  Trail(
    id: 'half-dome-via-mist-trail',
    name: 'Half Dome via Mist Trail',
    park: 'Yosemite National Park',
    state: 'California',
    lat: 37.7322,
    lng: -119.5580,
    lengthMiles: 14.2,
    elevationGainFt: 4800,
    difficulty: Difficulty.hard,
    rating: 4.7,
    reviewCount: 7104,
    dogFriendly: false,
    kidFriendly: false,
    fee: '\$35 vehicle (NPS pass) + Half Dome permit',
    description:
        'Yosemite\'s crown jewel: past Vernal and Nevada Falls, then the famous '
        'cable climb up Half Dome\'s 400-ft granite backside. A 10-to-12-hour '
        'sufferfest with permit-lottery access to the cables. Start before '
        'sunrise and carry 4-plus liters of water.',
    tags: ['Summit', 'Waterfall', 'Cables', 'Views'],
    routePoints: _route(37.7322, -119.5580,
        spanDeg: 0.0639, loop: false, seed: 157),
  ),
  Trail(
    id: 'fern-canyon',
    name: 'Fern Canyon',
    park: 'Redwood National and State Parks',
    state: 'California',
    lat: 41.4006,
    lng: -124.0659,
    lengthMiles: 1.1,
    elevationGainFt: 150,
    difficulty: Difficulty.easy,
    rating: 4.5,
    reviewCount: 8468,
    dogFriendly: false,
    kidFriendly: true,
    fee: '\$12 day use (+ free permit May 15-Sep 15)',
    description:
        'A prehistoric slot canyon with 50-ft walls dripping in ferns and moss, a '
        'filming location for Jurassic Park. Wade Home Creek between seasonal '
        'footbridges; Roosevelt elk graze at nearby Gold Bluffs Beach.',
    tags: ['Canyon', 'Ferns', 'Waterfall', 'Redwoods'],
    routePoints: _route(41.4006, -124.0659,
        spanDeg: 0.005, loop: true, seed: 158),
  ),
  Trail(
    id: 'flattop-mountain',
    name: 'Flattop Mountain',
    park: 'Chugach State Park',
    state: 'Alaska',
    lat: 61.1031,
    lng: -149.6833,
    lengthMiles: 3.0,
    elevationGainFt: 1280,
    difficulty: Difficulty.hard,
    rating: 4.6,
    reviewCount: 9864,
    dogFriendly: true,
    kidFriendly: false,
    fee: '\$5 day-use parking',
    description:
        'Alaska\'s most-climbed mountain: a short, steep grunt from Glen Alps to a '
        'flat summit with Anchorage, Cook Inlet, and on clear days Denali spread '
        'below. Rocky and exposed near the top; moose and bears are possible.',
    tags: ['Summit', 'Views', 'City', 'Wildlife'],
    routePoints: _route(61.1031, -149.6833,
        spanDeg: 0.0135, loop: false, seed: 159),
  ),
  Trail(
    id: 'harding-icefield-trail',
    name: 'Harding Icefield Trail',
    park: 'Kenai Fjords National Park',
    state: 'Alaska',
    lat: 60.1890,
    lng: -149.6304,
    lengthMiles: 8.2,
    elevationGainFt: 3000,
    difficulty: Difficulty.hard,
    rating: 4.8,
    reviewCount: 988,
    dogFriendly: false,
    kidFriendly: false,
    fee: 'Free',
    description:
        'Kenai Fjords\' premier day hike: 3,000 ft of climbing from cottonwood '
        'forest past Exit Glacier to an overlook of the 300-square-mile Harding '
        'Icefield. Nunataks pierce endless ice; weather turns fast. There is no '
        'park entrance fee.',
    tags: ['Glacier', 'Alpine', 'Views', 'Wildflowers'],
    routePoints: _route(60.1890, -149.6304,
        spanDeg: 0.0369, loop: false, seed: 160),
  ),
  Trail(
    id: 'diamond-head-leahi',
    name: 'Diamond Head (Leahi)',
    park: 'Diamond Head State Monument',
    state: 'Hawaii',
    lat: 21.2636,
    lng: -157.8060,
    lengthMiles: 1.6,
    elevationGainFt: 560,
    difficulty: Difficulty.moderate,
    rating: 4.7,
    reviewCount: 2676,
    dogFriendly: false,
    kidFriendly: true,
    fee: '\$5/person reservation (+\$10 parking)',
    description:
        'The iconic O\'ahu crater hike: 560 ft of switchbacks, stairs, and a WWII '
        'bunker tunnel to a panoramic rim over Waikiki and the Pacific. Steep but '
        'short; an advance reservation is required for non-residents.',
    tags: ['Summit', 'Views', 'Volcano', 'Historic'],
    routePoints: _route(21.2636, -157.8060,
        spanDeg: 0.0072, loop: false, seed: 161),
  ),
  Trail(
    id: 'kalalau-trail-to-hanakapiai-beach',
    name: 'Kalalau Trail (to Hanakapiai Beach)',
    park: 'Haena State Park',
    state: 'Hawaii',
    lat: 22.2204,
    lng: -159.5826,
    lengthMiles: 4.0,
    elevationGainFt: 800,
    difficulty: Difficulty.moderate,
    rating: 4.7,
    reviewCount: 9597,
    dogFriendly: false,
    kidFriendly: false,
    fee: '\$5/person reservation (+\$10 parking)',
    description:
        'The first 2 miles of the legendary Na Pali Coast trail: a muddy, '
        'cliff-hugging jungle traverse to a wild beach that is dangerous for '
        'swimming. Ocean views from the start, then a stream crossing at the end. '
        'A Ha\'ena State Park reservation is mandatory.',
    tags: ['Beach', 'Coastline', 'Cliffs', 'Jungle'],
    routePoints: _route(22.2204, -159.5826,
        spanDeg: 0.018, loop: false, seed: 162),
  ),
  Trail(
    id: 'bright-angel-trail-to-plateau-point',
    name: 'Bright Angel Trail (to Plateau Point)',
    park: 'Grand Canyon National Park',
    state: 'Arizona',
    lat: 36.0573,
    lng: -112.1436,
    lengthMiles: 12.2,
    elevationGainFt: 3195,
    difficulty: Difficulty.hard,
    rating: 4.8,
    reviewCount: 11301,
    dogFriendly: false,
    kidFriendly: false,
    fee: '\$35 vehicle (NPS pass)',
    description:
        'Grand Canyon\'s most-traveled corridor trail: switchbacks down past two '
        'tunnels and resthouses to Plateau Point\'s Colorado River overlook. Easy '
        'going down, brutal coming up; plan on twice your descent time. The only '
        'maintained trail with seasonal water.',
    tags: ['Canyon', 'Desert', 'Views', 'River'],
    routePoints: _route(36.0573, -112.1436,
        spanDeg: 0.0549, loop: false, seed: 163),
  ),
  Trail(
    id: 'havasu-falls-trail',
    name: 'Havasu Falls Trail',
    park: 'Havasupai Indian Reservation',
    state: 'Arizona',
    lat: 36.1597,
    lng: -112.7091,
    lengthMiles: 20.0,
    elevationGainFt: 2500,
    difficulty: Difficulty.hard,
    rating: 4.5,
    reviewCount: 5608,
    dogFriendly: false,
    kidFriendly: false,
    fee: '\$455/person permit (3-night)',
    description:
        'A 10-mile descent into Havasu Canyon to turquoise travertine falls '
        'sacred to the Havasupai people. Permits (3-night minimum) sell out in '
        'hours each February, and day hiking is not allowed. Summer heat is '
        'extreme; train with a loaded pack.',
    tags: ['Waterfall', 'Canyon', 'Desert', 'Backpacking'],
    routePoints: _route(36.1597, -112.7091,
        spanDeg: 0.09, loop: false, seed: 164),
  ),
  Trail(
    id: 'humphreys-peak',
    name: 'Humphreys Peak',
    park: 'Coconino National Forest',
    state: 'Arizona',
    lat: 35.3300,
    lng: -111.7050,
    lengthMiles: 9.6,
    elevationGainFt: 3434,
    difficulty: Difficulty.hard,
    rating: 4.6,
    reviewCount: 8233,
    dogFriendly: true,
    kidFriendly: false,
    fee: 'Free',
    description:
        'The roof of Arizona at 12,633 ft: from Snowbowl through aspen and '
        'bristlecone to an exposed tundra ridge with the Grand Canyon on the '
        'horizon. Thin air and afternoon lightning demand an early start.',
    tags: ['Summit', 'Alpine', 'Views', 'Volcano'],
    routePoints: _route(35.3300, -111.7050,
        spanDeg: 0.0432, loop: false, seed: 165),
  ),
  Trail(
    id: 'guadalupe-peak-trail',
    name: 'Guadalupe Peak Trail',
    park: 'Guadalupe Mountains National Park',
    state: 'Texas',
    lat: 31.89438,
    lng: -104.82137,
    lengthMiles: 8.4,
    elevationGainFt: 3000,
    difficulty: Difficulty.hard,
    rating: 4.3,
    reviewCount: 5115,
    dogFriendly: false,
    kidFriendly: false,
    fee: '\$10 per person (NPS)',
    description:
        'The climb to the highest point in Texas at 8,751 feet, this relentless '
        '8.4-mile trek gains 3,000 feet through Chihuahuan Desert scrub into '
        'high-country pine forest. Relentless switchbacks, a false summit, and a '
        'wooden bridge lead to a 360-degree panorama spanning West Texas and New '
        'Mexico. It is Texas\'s signature bucket-list summit and its most '
        'demanding day hike.',
    tags: ['Summit', 'Views', 'Desert', 'Ridgeline'],
    routePoints: _route(31.89438, -104.82137,
        spanDeg: 0.0378, loop: false, seed: 166),
  ),
  Trail(
    id: 'south-rim-trail',
    name: 'South Rim Trail',
    park: 'Big Bend National Park',
    state: 'Texas',
    lat: 29.27051,
    lng: -103.29934,
    lengthMiles: 12.6,
    elevationGainFt: 2800,
    difficulty: Difficulty.hard,
    rating: 4.9,
    reviewCount: 3727,
    dogFriendly: false,
    kidFriendly: false,
    fee: '\$30 per vehicle (NPS)',
    description:
        'Called one of the lower 48\'s top one-day hikes, this classic Chisos '
        'Mountains loop traverses grasslands and boot canyon to a dramatic cliff '
        'edge overlooking the vast Chihuahuan Desert. The route combines the '
        'Laguna Meadows and Pinnacles trails for constantly changing high-desert '
        'scenery. Peregrine falcon closures can affect the rim seasonally, so '
        'check conditions before going.',
    tags: ['Desert', 'Views', 'Loop', 'Cliffs'],
    routePoints: _route(29.27051, -103.29934,
        spanDeg: 0.0567, loop: true, seed: 167),
  ),
  Trail(
    id: 'window-trail',
    name: 'Window Trail',
    park: 'Big Bend National Park',
    state: 'Texas',
    lat: 29.27003,
    lng: -103.30111,
    lengthMiles: 5.6,
    elevationGainFt: 960,
    difficulty: Difficulty.moderate,
    rating: 4.6,
    reviewCount: 2543,
    dogFriendly: false,
    kidFriendly: true,
    fee: '\$30 per vehicle (NPS)',
    description:
        'This downhill-out, uphill-back trail descends Oak Creek Canyon through '
        'desert wash to the Window pour-off, a V-shaped notch framing the desert '
        'floor hundreds of feet below. Sunset pouring through the notch is the '
        'classic Big Bend photograph. The 950-foot climb back to the Chisos Basin '
        'is the real workout, so save water and legs for the return.',
    tags: ['Desert', 'Canyon', 'Views', 'Sunset'],
    routePoints: _route(29.27003, -103.30111,
        spanDeg: 0.0252, loop: false, seed: 168),
  ),
  Trail(
    id: 'looking-glass-rock-trail',
    name: 'Looking Glass Rock Trail',
    park: 'Pisgah National Forest',
    state: 'North Carolina',
    lat: 35.29095,
    lng: -82.77685,
    lengthMiles: 6.0,
    elevationGainFt: 1699,
    difficulty: Difficulty.moderate,
    rating: 4.8,
    reviewCount: 5689,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'One of the most popular hikes in Pisgah National Forest, this trail '
        'switchbacks through rhododendron and mountain laurel tunnels to the top '
        'of a massive granite dome. Named for the mirror-like reflection of ice '
        'off its sheer face in winter, the summit offers sweeping Blue Ridge '
        'panoramas. Pair it with a stop at roadside Looking Glass Falls on US '
        '276.',
    tags: ['Summit', 'Views', 'Granite', 'Forest'],
    routePoints: _route(35.29095, -82.77685,
        spanDeg: 0.027, loop: false, seed: 169),
  ),
  Trail(
    id: 'whiteside-mountain-trail',
    name: 'Whiteside Mountain Trail',
    park: 'Nantahala National Forest',
    state: 'North Carolina',
    lat: 35.080582,
    lng: -83.143926,
    lengthMiles: 2.0,
    elevationGainFt: 495,
    difficulty: Difficulty.moderate,
    rating: 4.8,
    reviewCount: 9117,
    dogFriendly: true,
    kidFriendly: true,
    fee: '\$3 per vehicle + \$1 per person',
    description:
        'An easy-access 2-mile loop atop 4,930-foot Whiteside Mountain, home to '
        'some of the highest sheer cliffs in the eastern United States. The trail '
        'traces the cliff edge with panoramic views south into Georgia and South '
        'Carolina. It is a short, family-friendly payoff hike between Highlands '
        'and Cashiers.',
    tags: ['Cliffs', 'Views', 'Loop', 'Summit'],
    routePoints: _route(35.080582, -83.143926,
        spanDeg: 0.009, loop: true, seed: 170),
  ),
  Trail(
    id: 'grandfather-mountain-profile-trail',
    name: 'Grandfather Mountain Profile Trail',
    park: 'Grandfather Mountain State Park',
    state: 'North Carolina',
    lat: 36.121972,
    lng: -81.829995,
    lengthMiles: 7.0,
    elevationGainFt: 2164,
    difficulty: Difficulty.hard,
    rating: 4.7,
    reviewCount: 3304,
    dogFriendly: true,
    kidFriendly: false,
    fee: 'Free',
    description:
        'This rugged out-and-back climbs from NC-105 past the namesake Profile '
        'rock formation to Calloway Peak, the 5,964-foot high point of the '
        'Grandfather ridgeline. Expect ladders, cables, cracked boulders, and '
        'exposure near the top on one of the Southeast\'s most technical trails. '
        'The payoff is a true alpine-feeling ridgeline walk with endless High '
        'Country views.',
    tags: ['Summit', 'Ridgeline', 'Views', 'Ladders'],
    routePoints: _route(36.121972, -81.829995,
        spanDeg: 0.0315, loop: false, seed: 171),
  ),
  Trail(
    id: 'table-rock-trail-2',
    name: 'Table Rock Trail',
    park: 'Table Rock State Park',
    state: 'South Carolina',
    lat: 35.03205,
    lng: -82.70018,
    lengthMiles: 7.0,
    elevationGainFt: 2316,
    difficulty: Difficulty.hard,
    rating: 4.5,
    reviewCount: 3446,
    dogFriendly: true,
    kidFriendly: false,
    fee: '\$6 per adult',
    description:
        'South Carolina\'s most famous summit hike climbs uneven rock stairs and '
        'boulder fields 2,316 feet to the granite dome of Table Rock Mountain. '
        'Stops at Carrick Creek Falls and Governor\'s Rock break up the steep '
        'ascent. The summit panorama over the Blue Ridge escarpment is the '
        'state\'s signature view.',
    tags: ['Summit', 'Views', 'Waterfall', 'Challenging'],
    routePoints: _route(35.03205, -82.70018,
        spanDeg: 0.0315, loop: false, seed: 172),
  ),
  Trail(
    id: 'raven-cliff-falls-trail',
    name: 'Raven Cliff Falls Trail',
    park: 'Caesars Head State Park',
    state: 'South Carolina',
    lat: 35.115599,
    lng: -82.638317,
    lengthMiles: 4.4,
    elevationGainFt: 738,
    difficulty: Difficulty.moderate,
    rating: 4.6,
    reviewCount: 9489,
    dogFriendly: true,
    kidFriendly: true,
    fee: '\$2 per adult',
    description:
        'The state\'s tallest waterfall drops an estimated 420 feet down Matthews '
        'Creek into the Mountain Bridge Wilderness. This moderate out-and-back '
        'follows a wide gravel path to an overlook across the gorge, with an '
        'optional longer loop to a suspension bridge directly over the falls. It '
        'is the marquee hike at Caesars Head and perfect for families.',
    tags: ['Waterfall', 'Overlook', 'Forest', 'Bridge'],
    routePoints: _route(35.115599, -82.638317,
        spanDeg: 0.0198, loop: false, seed: 173),
  ),
  Trail(
    id: 'pinnacle-mountain-trail',
    name: 'Pinnacle Mountain Trail',
    park: 'Table Rock State Park',
    state: 'South Carolina',
    lat: 35.03255,
    lng: -82.70948,
    lengthMiles: 8.5,
    elevationGainFt: 2329,
    difficulty: Difficulty.hard,
    rating: 4.9,
    reviewCount: 10613,
    dogFriendly: true,
    kidFriendly: false,
    fee: '\$6 per adult',
    description:
        'A strenuous yellow-blazed climb to the tallest mountain entirely within '
        'South Carolina, passing Mill Creek Falls and the Bald Knob overlook with '
        'views to Greenville. Rocky switchbacks, boardwalks over gullies, and '
        'wooden steps make it a full-body workout. Quieter than neighboring Table '
        'Rock with equally big payoffs.',
    tags: ['Summit', 'Waterfall', 'Ridgeline', 'Views'],
    routePoints: _route(35.03255, -82.70948,
        spanDeg: 0.0382, loop: false, seed: 174),
  ),
  Trail(
    id: 'providence-canyon-perimeter-loop-trail',
    name: 'Providence Canyon Perimeter Loop Trail',
    park: 'Providence Canyon State Park',
    state: 'Georgia',
    lat: 32.06987,
    lng: -84.90752,
    lengthMiles: 2.6,
    elevationGainFt: 232,
    difficulty: Difficulty.easy,
    rating: 4.5,
    reviewCount: 1119,
    dogFriendly: true,
    kidFriendly: true,
    fee: '\$5 per vehicle',
    description:
        'Georgia\'s "Little Grand Canyon" is a surreal landscape of pink, orange, '
        'red, and purple gullies up to 150 feet deep, carved by 19th-century '
        'farming erosion. This easy rim loop threads pine and oak forest with '
        'constant overlooks into the colorful canyons. Watch for the rare '
        'plumleaf azalea blooming in late summer.',
    tags: ['Canyon', 'Views', 'Loop', 'Unique'],
    routePoints: _route(32.06987, -84.90752,
        spanDeg: 0.0117, loop: true, seed: 175),
  ),
  Trail(
    id: 'mount-yonah-trail',
    name: 'Mount Yonah Trail',
    park: 'Chattahoochee National Forest',
    state: 'Georgia',
    lat: 34.6371,
    lng: -83.73209,
    lengthMiles: 4.4,
    elevationGainFt: 1496,
    difficulty: Difficulty.hard,
    rating: 4.4,
    reviewCount: 6747,
    dogFriendly: true,
    kidFriendly: false,
    fee: 'Free',
    description:
        'One of North Georgia\'s most popular and steepest day hikes, climbing '
        '1,500 feet in under 2.5 miles to a grassy summit bald with huge views. '
        'The Army\'s Ranger School trains on its cliffs, and the exposed granite '
        'ledges demand respect near the edges. It is a short, punishing, and '
        'deeply rewarding workout near Helen.',
    tags: ['Summit', 'Views', 'Rocky', 'Bald'],
    routePoints: _route(34.6371, -83.73209,
        spanDeg: 0.0198, loop: false, seed: 176),
  ),
  Trail(
    id: 'blood-mountain-via-appalachian-trail',
    name: 'Blood Mountain via Appalachian Trail',
    park: 'Chattahoochee National Forest',
    state: 'Georgia',
    lat: 34.73556,
    lng: -83.91861,
    lengthMiles: 4.3,
    elevationGainFt: 1400,
    difficulty: Difficulty.moderate,
    rating: 4.8,
    reviewCount: 5838,
    dogFriendly: true,
    kidFriendly: false,
    fee: 'Free',
    description:
        'Starting at Neels Gap, this classic Appalachian Trail section climbs to '
        'Georgia\'s highest AT peak at 4,458 feet. The summit holds a historic '
        '1934 CCC stone shelter and sweeping views of the surrounding Blue Ridge. '
        'Boulders near the top make it a fun scramble and a rite of passage for '
        'northbound thru-hikers.',
    tags: ['Summit', 'Views', 'Appalachian Trail', 'Historic'],
    routePoints: _route(34.73556, -83.91861,
        spanDeg: 0.0193, loop: false, seed: 177),
  ),
  Trail(
    id: 'torreya-trail',
    name: 'Torreya Trail',
    park: 'Torreya State Park',
    state: 'Florida',
    lat: 30.56496,
    lng: -84.94681,
    lengthMiles: 6.4,
    elevationGainFt: 761,
    difficulty: Difficulty.moderate,
    rating: 4.4,
    reviewCount: 4746,
    dogFriendly: true,
    kidFriendly: false,
    fee: '\$3 per vehicle',
    description:
        'Florida\'s most rugged trail winds across 150-foot bluffs and deep '
        'ravines above the Apalachicola River, with the most elevation change in '
        'the state. Hardwood forests, rare Torreya trees, and river overlooks '
        'make it feel nothing like flat Florida. It is the Panhandle\'s premier '
        'hiking destination and a genuine workout.',
    tags: ['Bluffs', 'River', 'Forest', 'Loop'],
    routePoints: _route(30.56496, -84.94681,
        spanDeg: 0.0288, loop: true, seed: 178),
  ),
  Trail(
    id: 'la-chua-trail',
    name: 'La Chua Trail',
    park: 'Paynes Prairie Preserve State Park',
    state: 'Florida',
    lat: 29.5993,
    lng: -82.27818,
    lengthMiles: 3.0,
    elevationGainFt: 13,
    difficulty: Difficulty.easy,
    rating: 4.8,
    reviewCount: 2090,
    dogFriendly: false,
    kidFriendly: true,
    fee: '\$6 per vehicle',
    description:
        'This flat boardwalk-and-trail route into the heart of Paynes Prairie is '
        'Florida\'s best wildlife walk, with dozens of alligators, wild horses, '
        'bison, and sandhill cranes. The trail ends at an observation platform '
        'over Alachua Sink with panoramic marsh views. Go early morning for the '
        'most active wildlife and fewest crowds.',
    tags: ['Wildlife', 'Alligators', 'Boardwalk', 'Birding'],
    routePoints: _route(29.5993, -82.27818,
        spanDeg: 0.0135, loop: false, seed: 179),
  ),
  Trail(
    id: 'sipsey-river-trail',
    name: 'Sipsey River Trail',
    park: 'Bankhead National Forest (Sipsey Wilderness)',
    state: 'Alabama',
    lat: 34.31624,
    lng: -87.47084,
    lengthMiles: 10.4,
    elevationGainFt: 200,
    difficulty: Difficulty.moderate,
    rating: 4.4,
    reviewCount: 8762,
    dogFriendly: true,
    kidFriendly: false,
    fee: 'Free',
    description:
        'Trail 209 follows Alabama\'s only National Wild and Scenic River through '
        'the Sipsey Wilderness, the largest wilderness east of the Mississippi. '
        'Expect waterfalls, boulder fields, small caves, and a river ford in a '
        'lush, untrammeled canyon. It is the state\'s definitive backcountry '
        'experience with abundant creekside campsites.',
    tags: ['Waterfall', 'Wilderness', 'River', 'Backpacking'],
    routePoints: _route(34.31624, -87.47084,
        spanDeg: 0.0468, loop: false, seed: 180),
  ),
  Trail(
    id: 'desoto-falls-bottom-and-bluff-overlook-trail',
    name: 'DeSoto Falls Bottom and Bluff Overlook Trail',
    park: 'DeSoto State Park',
    state: 'Alabama',
    lat: 34.5491,
    lng: -85.58976,
    lengthMiles: 2.0,
    elevationGainFt: 232,
    difficulty: Difficulty.moderate,
    rating: 4.8,
    reviewCount: 9527,
    dogFriendly: true,
    kidFriendly: false,
    fee: '\$4 per adult',
    description:
        'This short trail visits DeSoto Falls, one of Alabama\'s tallest '
        'waterfalls, plunging into a gorge on the West Fork of the Little River. '
        'The route combines the base of the falls with a bluff overlook spanning '
        'the limestone cliffs and the river below. It is at its best after rain, '
        'when the falls run full and loud.',
    tags: ['Waterfall', 'Overlook', 'Cliffs', 'River'],
    routePoints: _route(34.5491, -85.58976,
        spanDeg: 0.009, loop: false, seed: 181),
  ),
  Trail(
    id: 'alum-cave-trail',
    name: 'Alum Cave Trail',
    park: 'Great Smoky Mountains National Park',
    state: 'Tennessee',
    lat: 35.62955,
    lng: -83.45154,
    lengthMiles: 4.5,
    elevationGainFt: 1200,
    difficulty: Difficulty.moderate,
    rating: 4.8,
    reviewCount: 2903,
    dogFriendly: false,
    kidFriendly: true,
    fee: '\$5 parking tag (no entrance fee)',
    description:
        'The Smokies\' most beloved trail passes Arch Rock\'s natural stone '
        'staircase and Inspiration Point before reaching the towering Alum Cave '
        'Bluffs. This moderate route packs waterfalls, old-growth forest, and '
        'cable-assisted cliff sections into 4.5 miles. Strong hikers can continue '
        'another 2.7 miles to the summit of Mount LeConte.',
    tags: ['Bluffs', 'Views', 'Forest', 'Historic'],
    routePoints: _route(35.62955, -83.45154,
        spanDeg: 0.0202, loop: false, seed: 182),
  ),
  Trail(
    id: 'chimney-tops-trail',
    name: 'Chimney Tops Trail',
    park: 'Great Smoky Mountains National Park',
    state: 'Tennessee',
    lat: 35.63544,
    lng: -83.46976,
    lengthMiles: 3.8,
    elevationGainFt: 1487,
    difficulty: Difficulty.hard,
    rating: 4.7,
    reviewCount: 9807,
    dogFriendly: false,
    kidFriendly: false,
    fee: '\$5 parking tag (no entrance fee)',
    description:
        'Short, steep, and spectacular, this 3.8-mile climb gains nearly 1,500 '
        'feet to a new observation deck below the fire-scarred twin pinnacles. '
        'Cascading streams and rhododendron line the lower trail before the '
        'relentless rocky ascent begins. The panorama of Mount LeConte and the '
        'surrounding Smokies is among the park\'s finest.',
    tags: ['Summit', 'Views', 'Waterfall', 'Rocky'],
    routePoints: _route(35.63544, -83.46976,
        spanDeg: 0.0171, loop: false, seed: 183),
  ),
  Trail(
    id: 'virgin-falls-trail',
    name: 'Virgin Falls Trail',
    park: 'Virgin Falls State Natural Area',
    state: 'Tennessee',
    lat: 35.85408,
    lng: -85.2822,
    lengthMiles: 8.6,
    elevationGainFt: 1610,
    difficulty: Difficulty.hard,
    rating: 4.4,
    reviewCount: 9445,
    dogFriendly: true,
    kidFriendly: false,
    fee: 'Free',
    description:
        'A strenuous Cumberland Plateau trek to a 110-foot waterfall that pours '
        'from a cave mouth and vanishes back underground. The 8.6-mile route '
        'passes Big Laurel Falls, Martha\'s Pretty Point overlook, and karst '
        'sinkholes through Scott\'s Gulf. It is Tennessee\'s most celebrated '
        'waterfall hike and a classic backpacking objective.',
    tags: ['Waterfall', 'Cave', 'Backpacking', 'Gorge'],
    routePoints: _route(35.85408, -85.2822,
        spanDeg: 0.0387, loop: false, seed: 184),
  ),
  Trail(
    id: 'eagle-falls-trail',
    name: 'Eagle Falls Trail',
    park: 'Cumberland Falls State Resort Park',
    state: 'Kentucky',
    lat: 36.836597,
    lng: -84.345128,
    lengthMiles: 2.5,
    elevationGainFt: 400,
    difficulty: Difficulty.moderate,
    rating: 4.8,
    reviewCount: 7732,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'This trail pairs the "Niagara of the South" with 44-foot Eagle Falls in '
        'one of Kentucky\'s most scenic state parks. Rocky riverside walking, '
        'clifftop overlooks, and staircases lead to wading pools at the base of '
        'Eagle Falls. Visit on a full-moon night for the park\'s famous moonbow '
        'over Cumberland Falls.',
    tags: ['Waterfall', 'River', 'Views', 'Swimming'],
    routePoints: _route(36.836597, -84.345128,
        spanDeg: 0.0112, loop: false, seed: 185),
  ),
  Trail(
    id: 'double-arch-courthouse-rock-and-auxier-ridge-loo',
    name: 'Double Arch, Courthouse Rock and Auxier Ridge Loop',
    park: 'Daniel Boone National Forest (Red River Gorge)',
    state: 'Kentucky',
    lat: 37.82023,
    lng: -83.68128,
    lengthMiles: 6.2,
    elevationGainFt: 1043,
    difficulty: Difficulty.moderate,
    rating: 4.9,
    reviewCount: 9635,
    dogFriendly: true,
    kidFriendly: false,
    fee: '\$5 per vehicle (day-use permit)',
    description:
        'The Red River Gorge\'s signature loop walks an exposed sandstone '
        'ridgeline past Haystack Rock to Courthouse Rock, then drops to massive '
        'Double Arch. With over 100 natural arches, the Gorge holds the highest '
        'concentration east of the Rockies. Cliff-edge views, rock scrambles, and '
        'rhododendron tunnels make this Kentucky\'s most iconic hike.',
    tags: ['Arches', 'Ridgeline', 'Loop', 'Cliffs'],
    routePoints: _route(37.82023, -83.68128,
        spanDeg: 0.0279, loop: true, seed: 186),
  ),
  Trail(
    id: 'gray-s-arch-trail',
    name: 'Gray\'s Arch Trail',
    park: 'Daniel Boone National Forest (Red River Gorge)',
    state: 'Kentucky',
    lat: 37.80842,
    lng: -83.65797,
    lengthMiles: 2.5,
    elevationGainFt: 308,
    difficulty: Difficulty.moderate,
    rating: 4.8,
    reviewCount: 4095,
    dogFriendly: true,
    kidFriendly: true,
    fee: '\$5 per vehicle (day-use permit)',
    description:
        'A short, family-friendly trail to one of the largest arches in the Red '
        'River Gorge, a 79-foot span with live trees growing on top. The descent '
        'passes a seasonal waterfall and huge rock shelters before arriving '
        'beneath the arch. It is the easiest way to experience the Gorge\'s famous '
        'sandstone architecture.',
    tags: ['Arch', 'Waterfall', 'Forest', 'Family'],
    routePoints: _route(37.80842, -83.65797,
        spanDeg: 0.0112, loop: false, seed: 187),
  ),
  Trail(
    id: 'clark-creek-primitive-trail',
    name: 'Clark Creek Primitive Trail',
    park: 'Clark Creek Natural Area',
    state: 'Mississippi',
    lat: 31.0794,
    lng: -91.52855,
    lengthMiles: 5.0,
    elevationGainFt: 1020,
    difficulty: Difficulty.moderate,
    rating: 4.7,
    reviewCount: 7337,
    dogFriendly: true,
    kidFriendly: false,
    fee: '\$4 per vehicle',
    description:
        'Mississippi\'s "Middle Earth" holds nearly 50 waterfalls cascading over '
        'limestone shelves in steep loess bluffs near Woodville. The 5-mile '
        'primitive loop climbs over 1,000 feet via wooden stairs between falls, '
        'mossy boulders, and umbrella magnolias. It is the most unexpectedly '
        'rugged hiking in the Deep South.',
    tags: ['Waterfalls', 'Loop', 'Bluffs', 'Forest'],
    routePoints: _route(31.0794, -91.52855,
        spanDeg: 0.0225, loop: true, seed: 188),
  ),
  Trail(
    id: 'bear-creek-outcroppings-trail',
    name: 'Bear Creek Outcroppings Trail',
    park: 'Tishomingo State Park',
    state: 'Mississippi',
    lat: 34.60959,
    lng: -88.23512,
    lengthMiles: 1.9,
    elevationGainFt: 134,
    difficulty: Difficulty.easy,
    rating: 4.9,
    reviewCount: 11447,
    dogFriendly: true,
    kidFriendly: true,
    fee: '\$4 per vehicle',
    description:
        'The highest-rated trail in Tishomingo State Park threads between massive '
        'moss-covered sandstone outcroppings in the Appalachian foothills. '
        'Fern-filled crevices, a small waterfall, and the park\'s famous swinging '
        'bridge make this an easy, magical loop. It looks nothing like the '
        'Mississippi most people imagine.',
    tags: ['Rock Formations', 'Waterfall', 'Loop', 'Family'],
    routePoints: _route(34.60959, -88.23512,
        spanDeg: 0.0085, loop: true, seed: 189),
  ),
  Trail(
    id: 'pinnacle-mountain-west-summit-trail',
    name: 'Pinnacle Mountain West Summit Trail',
    park: 'Pinnacle Mountain State Park',
    state: 'Arkansas',
    lat: 34.83910,
    lng: -92.49273,
    lengthMiles: 1.5,
    elevationGainFt: 738,
    difficulty: Difficulty.hard,
    rating: 4.5,
    reviewCount: 9279,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'Just 25 minutes from downtown Little Rock, this steep 1.5-mile scramble '
        'climbs 738 feet over boulders to a 360-degree summit. From the top, the '
        'Arkansas River Valley, Lake Maumelle, and the Ouachita Mountains spread '
        'out below. Yellow blazes mark the route, with an easier curve or a '
        'direct boulder scramble two-thirds of the way up.',
    tags: ['Summit', 'Views', 'Rocky', 'Scramble'],
    routePoints: _route(34.83910, -92.49273,
        spanDeg: 0.0067, loop: false, seed: 190),
  ),
  Trail(
    id: 'whitaker-point-trail-hawksbill-crag',
    name: 'Whitaker Point Trail (Hawksbill Crag)',
    park: 'Ozark National Forest',
    state: 'Arkansas',
    lat: 35.89836,
    lng: -93.45803,
    lengthMiles: 2.9,
    elevationGainFt: 413,
    difficulty: Difficulty.moderate,
    rating: 4.6,
    reviewCount: 4861,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'Arkansas\'s most photographed overlook, a hawk\'s-bill rock balcony '
        'jutting over the Buffalo River valley. The easy-moderate 2.9-mile trail '
        'descends through Ozark hardwood forest, then climbs back to the '
        'trailhead. Fall color and sunrise here are legendary, but use caution '
        'near the cliff edges.',
    tags: ['Overlook', 'Cliffs', 'Forest', 'Photography'],
    routePoints: _route(35.89836, -93.45803,
        spanDeg: 0.013, loop: false, seed: 191),
  ),
  Trail(
    id: 'seven-hollows-trail',
    name: 'Seven Hollows Trail',
    park: 'Petit Jean State Park',
    state: 'Arkansas',
    lat: 35.114182,
    lng: -92.945395,
    lengthMiles: 4.5,
    elevationGainFt: 561,
    difficulty: Difficulty.moderate,
    rating: 4.4,
    reviewCount: 6339,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'This 4.5-mile loop through four stream-carved hollows features a natural '
        'sandstone bridge, the Grotto waterfall cave, and turtle rocks. Its '
        'unique geology is what inspired Petit Jean Mountain to become Arkansas\'s '
        'first state park. Diverse plant life ranges from ferns to cacti along '
        'the rocky, scenic loop.',
    tags: ['Natural Bridge', 'Grotto', 'Waterfall', 'Loop'],
    routePoints: _route(35.114182, -92.945395,
        spanDeg: 0.0202, loop: true, seed: 192),
  ),
  Trail(
    id: 'wild-azalea-trail',
    name: 'Wild Azalea Trail',
    park: 'Kisatchie National Forest',
    state: 'Louisiana',
    lat: 31.21324,
    lng: -92.6157,
    lengthMiles: 23.9,
    elevationGainFt: 1700,
    difficulty: Difficulty.moderate,
    rating: 4.3,
    reviewCount: 9875,
    dogFriendly: true,
    kidFriendly: false,
    fee: 'Free',
    description:
        'Louisiana\'s longest trail and a designated National Recreation Trail, '
        'running 23.9 miles between Valentine Lake and Woodworth through pine '
        'hills and hardwood bottoms. Named for the pink and white wild azaleas '
        'that bloom in March and April, it climbs over 1,700 cumulative feet of '
        'rolling terrain. It is the state\'s premier multi-day backpacking route '
        'with trailside campsites.',
    tags: ['Backpacking', 'Wildflowers', 'Forest', 'Long-Distance'],
    routePoints: _route(31.21324, -92.6157,
        spanDeg: 0.1075, loop: false, seed: 193),
  ),
  Trail(
    id: 'caroline-dormon-trail',
    name: 'Caroline Dormon Trail',
    park: 'Kisatchie National Forest',
    state: 'Louisiana',
    lat: 31.49191,
    lng: -93.1925,
    lengthMiles: 10.5,
    elevationGainFt: 1204,
    difficulty: Difficulty.moderate,
    rating: 4.4,
    reviewCount: 4408,
    dogFriendly: true,
    kidFriendly: false,
    fee: 'Free',
    description:
        'Featured in "50 Hikes in Louisiana," this 10.5-mile point-to-point trail '
        'runs from the Longleaf Scenic Byway to the Kisatchie Bayou Recreation '
        'Area. Rolling hills, creek crossings, and small sandstone water features '
        'make it the state\'s best weekend backpacking trip. It connects with the '
        'Backbone and Sandstone trails for longer adventures.',
    tags: ['Backpacking', 'Bayou', 'Forest', 'Waterfalls'],
    routePoints: _route(31.49191, -93.1925,
        spanDeg: 0.0472, loop: false, seed: 194),
  ),
  Trail(
    id: 'old-man-s-cave-to-whispering-cave-loop',
    name: 'Old Man\'s Cave to Whispering Cave Loop',
    park: 'Hocking Hills State Park',
    state: 'Ohio',
    lat: 39.43451,
    lng: -82.54210,
    lengthMiles: 3.4,
    elevationGainFt: 288,
    difficulty: Difficulty.moderate,
    rating: 4.3,
    reviewCount: 11139,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'Ohio\'s most famous hike winds through a sandstone gorge past Upper '
        'Falls, Devil\'s Bathtub, and the giant recess cave named for trapper '
        'Richard Rowe. It extends to Whispering Cave, one of the largest recess '
        'caves in the eastern US, before looping back to the visitor center.',
    tags: ['Waterfall', 'Cave', 'Gorge', 'Loop'],
    routePoints: _route(39.43451, -82.54210,
        spanDeg: 0.0153, loop: true, seed: 195),
  ),
  Trail(
    id: 'ledges-trail',
    name: 'Ledges Trail',
    park: 'Cuyahoga Valley National Park',
    state: 'Ohio',
    lat: 41.22370,
    lng: -81.51020,
    lengthMiles: 2.2,
    elevationGainFt: 80,
    difficulty: Difficulty.easy,
    rating: 4.3,
    reviewCount: 1904,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'This beloved circuit wanders among the massive moss-covered Ritchie '
        'Ledges sandstone formations and the hidden Icebox Cave. A short spur to '
        'the Ledges Overlook delivers sweeping sunset views over the Cuyahoga '
        'Valley.',
    tags: ['Rock Formations', 'Overlook', 'Forest', 'Loop'],
    routePoints: _route(41.22370, -81.51020,
        spanDeg: 0.0099, loop: true, seed: 196),
  ),
  Trail(
    id: 'cantwell-cliffs-loop',
    name: 'Cantwell Cliffs Loop',
    park: 'Hocking Hills State Park',
    state: 'Ohio',
    lat: 39.53970,
    lng: -82.57562,
    lengthMiles: 1.8,
    elevationGainFt: 400,
    difficulty: Difficulty.moderate,
    rating: 4.8,
    reviewCount: 6213,
    dogFriendly: true,
    kidFriendly: false,
    fee: 'Free',
    description:
        'The quietest of Hocking Hills\' seven major areas features 150-foot '
        'Blackhand sandstone cliffs, deep Buck Run gorge, and the famous narrow '
        'passage "Fat Woman\'s Squeeze." The rim loop offers panoramic valley '
        'views but has unfenced cliff edges requiring caution.',
    tags: ['Cliffs', 'Gorge', 'Rim Views', 'Loop'],
    routePoints: _route(39.53970, -82.57562,
        spanDeg: 0.0081, loop: true, seed: 197),
  ),
  Trail(
    id: 'turkey-run-trails-3-5-and-9-loop',
    name: 'Turkey Run Trails 3, 5 and 9 Loop',
    park: 'Turkey Run State Park',
    state: 'Indiana',
    lat: 39.88439,
    lng: -87.20571,
    lengthMiles: 4.4,
    elevationGainFt: 636,
    difficulty: Difficulty.moderate,
    rating: 4.3,
    reviewCount: 4699,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Indiana State Park entrance fee',
    description:
        'Indiana\'s top-voted trail combo scrambles through sandstone canyons, '
        'climbs the famous ladders of Trail 3, and crosses streams beneath '
        'old-growth hemlock. Rocky Gorge and the Narrows showcase the park\'s '
        'signature waterfall-carved canyon walls.',
    tags: ['Canyons', 'Ladders', 'Waterfall', 'Forest'],
    routePoints: _route(39.88439, -87.20571,
        spanDeg: 0.0198, loop: true, seed: 198),
  ),
  Trail(
    id: 'clifty-falls-trail-6-and-7-loop',
    name: 'Clifty Falls Trail 6 and 7 Loop',
    park: 'Clifty Falls State Park',
    state: 'Indiana',
    lat: 38.76940,
    lng: -85.43665,
    lengthMiles: 2.2,
    elevationGainFt: 314,
    difficulty: Difficulty.moderate,
    rating: 4.5,
    reviewCount: 8753,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Indiana State Park entrance fee',
    description:
        'This loop links Tunnel Falls and Little Clifty Falls through a rugged '
        'limestone gorge near Madison on the Ohio River. After heavy rain the '
        'falls pour dramatically over the canyon rim, and the rim trail offers '
        'sweeping canyon overlooks.',
    tags: ['Waterfall', 'Gorge', 'Forest', 'Loop'],
    routePoints: _route(38.76940, -85.43665,
        spanDeg: 0.0099, loop: true, seed: 199),
  ),
  Trail(
    id: 'starved-rock-and-sandstone-point-overlook-trail',
    name: 'Starved Rock and Sandstone Point Overlook Trail',
    park: 'Starved Rock State Park',
    state: 'Illinois',
    lat: 41.32150,
    lng: -88.99380,
    lengthMiles: 4.2,
    elevationGainFt: 337,
    difficulty: Difficulty.moderate,
    rating: 4.4,
    reviewCount: 2967,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'Illinois\' most visited hike climbs the 125-foot namesake butte for '
        'panoramic views of the Illinois River and dam. The route continues to '
        'Lover\'s Leap and Sandstone Point overlooks, passing glacially carved '
        'canyons that flow with waterfalls in spring.',
    tags: ['Overlook', 'River', 'Canyon', 'Waterfall'],
    routePoints: _route(41.32150, -88.99380,
        spanDeg: 0.0189, loop: true, seed: 200),
  ),
  Trail(
    id: 'garden-of-the-gods-observation-trail',
    name: 'Garden of the Gods Observation Trail',
    park: 'Shawnee National Forest',
    state: 'Illinois',
    lat: 37.60463,
    lng: -88.38436,
    lengthMiles: 0.5,
    elevationGainFt: 39,
    difficulty: Difficulty.easy,
    rating: 4.7,
    reviewCount: 10155,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'A short flagstone loop atop sheer bluffs threads through the famous '
        'Camel Rock, Table Rock, and hoodoo-like sandstone formations. Panoramic '
        'views stretch across the Garden of the Gods Wilderness, and sunsets here '
        'are legendary.',
    tags: ['Rock Formations', 'Overlook', 'Sunset', 'Loop'],
    routePoints: _route(37.60463, -88.38436,
        spanDeg: 0.0022, loop: true, seed: 201),
  ),
  Trail(
    id: 'dune-climb-trail',
    name: 'Dune Climb Trail',
    park: 'Sleeping Bear Dunes National Lakeshore',
    state: 'Michigan',
    lat: 44.88242,
    lng: -86.04220,
    lengthMiles: 3.5,
    elevationGainFt: 656,
    difficulty: Difficulty.hard,
    rating: 4.6,
    reviewCount: 4781,
    dogFriendly: false,
    kidFriendly: true,
    fee: '\$25/vehicle (NPS pass)',
    description:
        'The iconic thigh-burning ascent up a towering sand dune rewards with '
        'views of Little Glen Lake from the first plateau. Continuing over the '
        'dunes leads to the shores of Lake Michigan for a refreshing plunge, with '
        'the Manitou Islands on the horizon.',
    tags: ['Dunes', 'Lake Views', 'Workout', 'Views'],
    routePoints: _route(44.88242, -86.04220,
        spanDeg: 0.0158, loop: false, seed: 202),
  ),
  Trail(
    id: 'chapel-loop',
    name: 'Chapel Loop',
    park: 'Pictured Rocks National Lakeshore',
    state: 'Michigan',
    lat: 46.51955,
    lng: -86.46181,
    lengthMiles: 10.0,
    elevationGainFt: 600,
    difficulty: Difficulty.moderate,
    rating: 4.8,
    reviewCount: 7469,
    dogFriendly: false,
    kidFriendly: false,
    fee: '\$20/vehicle (NPS pass)',
    description:
        'Michigan\'s premier day hike traces 200-foot sandstone cliffs above Lake '
        'Superior, passing Chapel Falls, Mosquito Falls, and Chapel Rock with its '
        'lone white pine. The loop crosses Chapel Beach and Grand Portal Point '
        'for the full multicolor-cliff experience.',
    tags: ['Waterfall', 'Cliffs', 'Lake', 'Loop'],
    routePoints: _route(46.51955, -86.46181,
        spanDeg: 0.045, loop: true, seed: 203),
  ),
  Trail(
    id: 'sugarloaf-mountain-trail',
    name: 'Sugarloaf Mountain Trail',
    park: 'Marquette Area (Michigan DNR)',
    state: 'Michigan',
    lat: 46.58937,
    lng: -87.44540,
    lengthMiles: 1.2,
    elevationGainFt: 285,
    difficulty: Difficulty.easy,
    rating: 4.4,
    reviewCount: 2388,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'This short stair-filled climb just north of Marquette tops out on a '
        'granite summit 407 feet above Lake Superior. Three viewing platforms '
        'give 360-degree panoramas of the Lake Superior shoreline, Marquette\'s '
        'ore docks, and the Huron Mountains.',
    tags: ['Summit', 'Lake Views', 'Stairs', 'Overlook'],
    routePoints: _route(46.58937, -87.44540,
        spanDeg: 0.0054, loop: false, seed: 204),
  ),
  Trail(
    id: 'east-bluff-and-east-bluff-woods-trail-loop',
    name: 'East Bluff and East Bluff Woods Trail Loop',
    park: 'Devil\'s Lake State Park',
    state: 'Wisconsin',
    lat: 43.42846,
    lng: -89.72660,
    lengthMiles: 3.0,
    elevationGainFt: 682,
    difficulty: Difficulty.moderate,
    rating: 4.7,
    reviewCount: 6604,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'WI State Park vehicle sticker',
    description:
        'Wisconsin\'s most popular loop climbs 1.6-billion-year-old quartzite '
        'bluffs to Devil\'s Doorway and balanced-rock formations. Constant '
        'overlooks of Devil\'s Lake and the Baraboo Hills line the bluff-top '
        'trail.',
    tags: ['Bluff Views', 'Devil\'s Doorway', 'Lake', 'Loop'],
    routePoints: _route(43.42846, -89.72660,
        spanDeg: 0.0135, loop: true, seed: 205),
  ),
  Trail(
    id: 'parfrey-s-glen-trail',
    name: 'Parfrey\'s Glen Trail',
    park: 'Parfrey\'s Glen State Natural Area',
    state: 'Wisconsin',
    lat: 43.41025,
    lng: -89.63699,
    lengthMiles: 1.7,
    elevationGainFt: 203,
    difficulty: Difficulty.moderate,
    rating: 4.6,
    reviewCount: 8451,
    dogFriendly: false,
    kidFriendly: true,
    fee: 'Free',
    description:
        'Wisconsin\'s first state natural area is a deep mossy sandstone gorge cut '
        'into the Baraboo Hills, home to rare plants found nowhere else on Earth. '
        'The trail follows a mountain-type stream through the canyon to a small '
        'waterfall at its head.',
    tags: ['Gorge', 'Waterfall', 'Stream', 'Canyon'],
    routePoints: _route(43.41025, -89.63699,
        spanDeg: 0.0076, loop: false, seed: 206),
  ),
  Trail(
    id: 'fifth-falls-and-superior-hiking-trail-loop',
    name: 'Fifth Falls and Superior Hiking Trail Loop',
    park: 'Gooseberry Falls State Park',
    state: 'Minnesota',
    lat: 47.14224,
    lng: -91.46879,
    lengthMiles: 2.9,
    elevationGainFt: 256,
    difficulty: Difficulty.moderate,
    rating: 4.8,
    reviewCount: 1687,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'MN State Park vehicle permit',
    description:
        'The North Shore\'s most visited park pairs its famous Upper, Middle, and '
        'Lower Gooseberry Falls with this quieter loop to Fifth Falls along the '
        'Superior Hiking Trail. The route follows the Gooseberry River through '
        'birch-aspen forest with peaceful pools and cascades.',
    tags: ['Waterfall', 'River', 'Forest', 'Loop'],
    routePoints: _route(47.14224, -91.46879,
        spanDeg: 0.013, loop: true, seed: 207),
  ),
  Trail(
    id: 'shovel-point-trail',
    name: 'Shovel Point Trail',
    park: 'Tettegouche State Park',
    state: 'Minnesota',
    lat: 47.33854,
    lng: -91.19606,
    lengthMiles: 2.0,
    elevationGainFt: 250,
    difficulty: Difficulty.moderate,
    rating: 4.7,
    reviewCount: 11387,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'MN State Park vehicle permit',
    description:
        'A stair-filled climb to a rocky point jutting into Lake Superior '
        'delivers some of the North Shore\'s best cliff-and-surf views. Combine it '
        'with the High Falls of the Baptism River, the tallest waterfall entirely '
        'within Minnesota, for a perfect Tettegouche day.',
    tags: ['Lake Views', 'Cliffs', 'Waterfall', 'Stairs'],
    routePoints: _route(47.33854, -91.19606,
        spanDeg: 0.009, loop: false, seed: 208),
  ),
  Trail(
    id: 'maquoketa-caves-loop',
    name: 'Maquoketa Caves Loop',
    park: 'Maquoketa Caves State Park',
    state: 'Iowa',
    lat: 42.11907,
    lng: -90.77318,
    lengthMiles: 4.5,
    elevationGainFt: 500,
    difficulty: Difficulty.moderate,
    rating: 4.4,
    reviewCount: 7396,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'Iowa\'s most beloved state park threads a deep limestone gorge where '
        'sheer 200-foot walls shelter 14 explorable caves. Boardwalks, overlooks, '
        'and the ridge trails above the gorge make this an endlessly explorable '
        'spelunker\'s playground.',
    tags: ['Caves', 'Gorge', 'Canyon', 'Adventure'],
    routePoints: _route(42.11907, -90.77318,
        spanDeg: 0.0202, loop: true, seed: 209),
  ),
  Trail(
    id: 'eagle-rock-fire-point-and-little-bear-mound-grou',
    name: 'Eagle Rock, Fire Point and Little Bear Mound Group Loop',
    park: 'Effigy Mounds National Monument',
    state: 'Iowa',
    lat: 43.08822,
    lng: -91.18757,
    lengthMiles: 1.7,
    elevationGainFt: 295,
    difficulty: Difficulty.moderate,
    rating: 4.7,
    reviewCount: 2590,
    dogFriendly: false,
    kidFriendly: true,
    fee: 'Free',
    description:
        'Iowa\'s only national monument preserves 200+ ancient Native American '
        'mounds, including the Great Bear effigy. Two bluff-top overlooks deliver '
        'dramatic views of the Mississippi River valley, best paired with the '
        'monument\'s ranger-led programs.',
    tags: ['Overlook', 'History', 'River', 'Loop'],
    routePoints: _route(43.08822, -91.18757,
        spanDeg: 0.0076, loop: true, seed: 210),
  ),
  Trail(
    id: 'mina-sauk-falls-trail',
    name: 'Mina Sauk Falls Trail',
    park: 'Taum Sauk Mountain State Park',
    state: 'Missouri',
    lat: 37.57280,
    lng: -90.72827,
    lengthMiles: 3.0,
    elevationGainFt: 433,
    difficulty: Difficulty.moderate,
    rating: 4.4,
    reviewCount: 3916,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'This loop visits Missouri\'s two geological superlatives: the state\'s '
        '1,772-foot high point and its tallest waterfall, cascading 132 feet over '
        'rhyolite ledges. Rocky open glades along the way offer sweeping views of '
        'the St. Francois Mountains, Missouri\'s ancient peaks.',
    tags: ['Waterfall', 'Highpoint', 'Glades', 'Views'],
    routePoints: _route(37.57280, -90.72827,
        spanDeg: 0.0135, loop: true, seed: 211),
  ),
  Trail(
    id: 'spring-brook-trail-loop-via-devil-s-icebox-trail',
    name: 'Spring Brook Trail Loop via Devil\'s Icebox Trail',
    park: 'Rock Bridge Memorial State Park',
    state: 'Missouri',
    lat: 38.87302,
    lng: -92.32590,
    lengthMiles: 2.3,
    elevationGainFt: 207,
    difficulty: Difficulty.easy,
    rating: 4.6,
    reviewCount: 3096,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'Minutes from Columbia, this loop showcases premier karst geology: the '
        '63-foot natural rock bridge, the double-sinkhole entrance of Devil\'s '
        'Icebox, and Connor\'s Cave. Boardwalks, stairs, and interpretive signs '
        'make it an ideal family geology walk.',
    tags: ['Caves', 'Karst', 'Natural Bridge', 'Loop'],
    routePoints: _route(38.87302, -92.32590,
        spanDeg: 0.0103, loop: true, seed: 212),
  ),
  Trail(
    id: 'konza-prairie-nature-trail-loop',
    name: 'Konza Prairie Nature Trail Loop',
    park: 'Konza Prairie Biological Station',
    state: 'Kansas',
    lat: 39.10756,
    lng: -96.60969,
    lengthMiles: 2.8,
    elevationGainFt: 275,
    difficulty: Difficulty.moderate,
    rating: 4.6,
    reviewCount: 5363,
    dogFriendly: false,
    kidFriendly: true,
    fee: 'Free (\$2 suggested donation)',
    description:
        'This loop crosses one of the last remaining tallgrass prairies in North '
        'America, part of the Flint Hills ecosystem. Rolling prairie, Kings '
        'Creek\'s timber-lined banks, the 1878 Hokanson Homestead, and roaming '
        'bison make this Kansas\'s signature hike.',
    tags: ['Tallgrass Prairie', 'Bison', 'Hills', 'Loop'],
    routePoints: _route(39.10756, -96.60969,
        spanDeg: 0.0126, loop: true, seed: 213),
  ),
  Trail(
    id: 'elk-river-hiking-trail-via-hwy-160',
    name: 'Elk River Hiking Trail via HWY 160',
    park: 'Elk City State Park area',
    state: 'Kansas',
    lat: 37.26792,
    lng: -95.90069,
    lengthMiles: 11.0,
    elevationGainFt: 531,
    difficulty: Difficulty.moderate,
    rating: 4.6,
    reviewCount: 2035,
    dogFriendly: true,
    kidFriendly: false,
    fee: 'Free',
    description:
        'Named Backpacker Magazine\'s "Best Hike in Kansas," this 15-mile National '
        'Recreation Trail is the state\'s most rugged backcountry route. '
        'Moss-covered limestone bluffs, creek crossings, rock canyons, and a '
        'small waterfall reward those willing to tackle its wild Chautauqua Hills '
        'terrain.',
    tags: ['Forest', 'Bluffs', 'Waterfall', 'Backpacking'],
    routePoints: _route(37.26792, -95.90069,
        spanDeg: 0.0495, loop: false, seed: 214),
  ),
  Trail(
    id: 'saddle-rock-trail',
    name: 'Saddle Rock Trail',
    park: 'Scotts Bluff National Monument',
    state: 'Nebraska',
    lat: 41.82861,
    lng: -103.70749,
    lengthMiles: 3.2,
    elevationGainFt: 583,
    difficulty: Difficulty.moderate,
    rating: 4.6,
    reviewCount: 9816,
    dogFriendly: false,
    kidFriendly: true,
    fee: '\$10/vehicle (NPS pass)',
    description:
        'This switchbacking paved trail climbs 435 feet to the 4,649-foot summit '
        'of Scotts Bluff, the great landmark of the Oregon, California, and '
        'Mormon Trails. The summit overlooks the North Platte Valley, Mitchell '
        'Pass, and Chimney Rock 20 miles east.',
    tags: ['Bluff Views', 'History', 'Summit', 'Oregon Trail'],
    routePoints: _route(41.82861, -103.70749,
        spanDeg: 0.0144, loop: false, seed: 215),
  ),
  Trail(
    id: 'toadstool-geologic-park-loop-trail',
    name: 'Toadstool Geologic Park Loop Trail',
    park: 'Oglala National Grassland',
    state: 'Nebraska',
    lat: 42.85778,
    lng: -103.58394,
    lengthMiles: 1.0,
    elevationGainFt: 45,
    difficulty: Difficulty.easy,
    rating: 4.4,
    reviewCount: 11484,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free (\$3 day use in season)',
    description:
        'Nebraska\'s "badlands" showcase toadstool-shaped rock pedestals, fossil '
        'beds of ancient rhinos and saber-toothed cats, and a reconstructed sod '
        'house. The interpretive loop under dark Oglala Grassland skies is a '
        'geologic wonderland.',
    tags: ['Badlands', 'Fossils', 'Hoodoos', 'Loop'],
    routePoints: _route(42.85778, -103.58394,
        spanDeg: 0.0045, loop: true, seed: 216),
  ),
  Trail(
    id: 'black-elk-peak-loop-south-dakota-highpoint',
    name: 'Black Elk Peak Loop: South Dakota Highpoint',
    park: 'Black Elk Wilderness / Custer State Park',
    state: 'South Dakota',
    lat: 43.84659,
    lng: -103.55977,
    lengthMiles: 7.2,
    elevationGainFt: 1473,
    difficulty: Difficulty.moderate,
    rating: 4.9,
    reviewCount: 1041,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Custer State Park entrance fee',
    description:
        'Starting at Sylvan Lake, this loop climbs to 7,242 feet, the highest '
        'point between the Rockies and the Pyrenees. The historic stone fire '
        'lookout tower tops a granite summit with views into Montana, Wyoming, '
        'and Nebraska on clear days.',
    tags: ['Summit', 'Fire Tower', 'Granite', 'Views'],
    routePoints: _route(43.84659, -103.55977,
        spanDeg: 0.0324, loop: true, seed: 217),
  ),
  Trail(
    id: 'notch-trail',
    name: 'Notch Trail',
    park: 'Badlands National Park',
    state: 'South Dakota',
    lat: 43.76012,
    lng: -101.92825,
    lengthMiles: 1.5,
    elevationGainFt: 150,
    difficulty: Difficulty.moderate,
    rating: 4.9,
    reviewCount: 4672,
    dogFriendly: false,
    kidFriendly: false,
    fee: 'Badlands NP entrance fee',
    description:
        'The Badlands\' signature hike crosses a slot canyon and climbs a 50-foot '
        'log ladder to a cliff-ledge overlook with 180-degree views over the '
        'White River Valley. Short but exposed, it delivers the park\'s most '
        'dramatic payoff per mile.',
    tags: ['Badlands', 'Canyon', 'Ladder', 'Views'],
    routePoints: _route(43.76012, -101.92825,
        spanDeg: 0.0067, loop: false, seed: 218),
  ),
  Trail(
    id: 'petrified-forest-loop-trail',
    name: 'Petrified Forest Loop Trail',
    park: 'Theodore Roosevelt National Park (South Unit)',
    state: 'North Dakota',
    lat: 46.99612,
    lng: -103.60478,
    lengthMiles: 10.9,
    elevationGainFt: 961,
    difficulty: Difficulty.moderate,
    rating: 4.4,
    reviewCount: 8756,
    dogFriendly: false,
    kidFriendly: false,
    fee: '\$30/vehicle (NPS pass)',
    description:
        'Combining the North and South Petrified Forest Trails with the Maah Daah '
        'Hey, this loop crosses badlands wilderness dotted with '
        '60-million-year-old petrified tree stumps. Bison and wild horses are '
        'frequent trail companions in the park\'s remote northwest corner.',
    tags: ['Badlands', 'Petrified Forest', 'Bison', 'Loop'],
    routePoints: _route(46.99612, -103.60478,
        spanDeg: 0.049, loop: true, seed: 219),
  ),
  Trail(
    id: 'painted-canyon-nature-trail',
    name: 'Painted Canyon Nature Trail',
    park: 'Theodore Roosevelt National Park (South Unit)',
    state: 'North Dakota',
    lat: 46.88758,
    lng: -103.38338,
    lengthMiles: 1.1,
    elevationGainFt: 250,
    difficulty: Difficulty.moderate,
    rating: 4.6,
    reviewCount: 7370,
    dogFriendly: false,
    kidFriendly: true,
    fee: '\$30/vehicle (NPS pass)',
    description:
        'Starting at the Painted Canyon Visitor Center off I-94, this short loop '
        'descends into the park\'s famously striped badlands for intimate views of '
        'the painted buttes. Wildflowers blanket the canyon floor in spring, and '
        'bison often graze within sight.',
    tags: ['Overlook', 'Canyon', 'Views', 'Wildflowers'],
    routePoints: _route(46.88758, -103.38338,
        spanDeg: 0.005, loop: true, seed: 220),
  ),
  Trail(
    id: 'charons-garden-trail',
    name: 'Charons Garden Trail',
    park: 'Wichita Mountains Wildlife Refuge',
    state: 'Oklahoma',
    lat: 34.73173,
    lng: -98.72353,
    lengthMiles: 4.3,
    elevationGainFt: 465,
    difficulty: Difficulty.moderate,
    rating: 4.8,
    reviewCount: 3497,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'Oklahoma\'s most rugged hike threads the Charon\'s Garden Wilderness '
        'through granite boulder fields and narrow canyons of '
        '500-million-year-old mountains. Free-roaming bison, elk, and longhorns '
        'are common, and the trail connects to Elk Mountain\'s summit view.',
    tags: ['Boulders', 'Granite', 'Views', 'Wildlife'],
    routePoints: _route(34.73173, -98.72353,
        spanDeg: 0.0193, loop: false, seed: 221),
  ),
  Trail(
    id: 'black-mesa-trail',
    name: 'Black Mesa Trail',
    park: 'Black Mesa Nature Preserve',
    state: 'Oklahoma',
    lat: 36.95715,
    lng: -102.95721,
    lengthMiles: 8.5,
    elevationGainFt: 734,
    difficulty: Difficulty.moderate,
    rating: 4.5,
    reviewCount: 7196,
    dogFriendly: true,
    kidFriendly: false,
    fee: 'Free',
    description:
        'A flat walk across shortgrass prairie climbs switchbacks up Black Mesa '
        'to a granite obelisk marking Oklahoma\'s 4,973-foot high point. From the '
        'top you can see into New Mexico and Colorado, with dinosaur-track '
        'quarries and night-dark Bortle 1 skies nearby.',
    tags: ['Highpoint', 'Mesa', 'Views', 'Desert'],
    routePoints: _route(36.95715, -102.95721,
        spanDeg: 0.0382, loop: false, seed: 222),
  ),
  Trail(
    id: 'turkey-mountain-yellow-trail',
    name: 'Turkey Mountain Yellow Trail',
    park: 'Turkey Mountain Urban Wilderness',
    state: 'Oklahoma',
    lat: 36.06575,
    lng: -95.99270,
    lengthMiles: 4.3,
    elevationGainFt: 416,
    difficulty: Difficulty.moderate,
    rating: 4.5,
    reviewCount: 8254,
    dogFriendly: true,
    kidFriendly: true,
    fee: 'Free',
    description:
        'Tulsa\'s signature urban wilderness loop winds through oak forest to '
        'Vista Point overlooking downtown and the Arkansas River. Rocky, '
        'technical, and surprisingly rugged, it\'s the most popular trail in '
        'Oklahoma\'s biggest metro area.',
    tags: ['Forest', 'River Views', 'Loop', 'Urban Wild'],
    routePoints: _route(36.06575, -95.99270,
        spanDeg: 0.0193, loop: true, seed: 223),
  ),
  Trail(
    id: 'wheeler-peak-summit-via-williams-lake-trail',
    name: 'Wheeler Peak Summit via Williams Lake Trail',
    park: 'Carson National Forest',
    state: 'New Mexico',
    lat: 36.57933,
    lng: -105.43994,
    lengthMiles: 8.6,
    elevationGainFt: 2966,
    difficulty: Difficulty.hard,
    rating: 4.5,
    reviewCount: 9905,
    dogFriendly: true,
    kidFriendly: false,
    fee: 'Free',
    description:
        'New Mexico\'s 13,159-foot high point is reached via the alpine Williams '
        'Lake and a long switchbacking ridge through the Wheeler Peak Wilderness. '
        'Bighorn sheep, marmots, and wildflower meadows dot the route before '
        'panoramic views of the Sangre de Cristos from the summit.',
    tags: ['Summit', 'Alpine Lake', 'Highpoint', 'Views'],
    routePoints: _route(36.57933, -105.43994,
        spanDeg: 0.0387, loop: false, seed: 224),
  ),
  Trail(
    id: 'tent-rocks-slot-canyon-and-cave-loop',
    name: 'Tent Rocks Slot Canyon and Cave Loop',
    park: 'Kasha-Katuwe Tent Rocks National Monument',
    state: 'New Mexico',
    lat: 35.65670,
    lng: -106.41100,
    lengthMiles: 4.5,
    elevationGainFt: 610,
    difficulty: Difficulty.moderate,
    rating: 4.7,
    reviewCount: 8773,
    dogFriendly: false,
    kidFriendly: true,
    fee: '\$5/vehicle (reservation required)',
    description:
        'A slot canyon squeezes between cone-shaped tent rocks formed by '
        '6-to-7-million-year-old volcanic ash flows, climbing 630 feet to '
        'mesa-top overlooks. The Cave Loop passes a small cavate and hoodoos with '
        'caprocks at the base of the formations.',
    tags: ['Slot Canyon', 'Hoodoos', 'Desert', 'Views'],
    routePoints: _route(35.65670, -106.41100,
        spanDeg: 0.0202, loop: false, seed: 225),
  ),
  Trail(
    id: 'la-luz-trail',
    name: 'La Luz Trail',
    park: 'Cibola National Forest (Sandia Mountain Wilderness)',
    state: 'New Mexico',
    lat: 35.21925,
    lng: -106.48116,
    lengthMiles: 7.5,
    elevationGainFt: 3200,
    difficulty: Difficulty.hard,
    rating: 4.4,
    reviewCount: 5661,
    dogFriendly: true,
    kidFriendly: false,
    fee: 'Free',
    description:
        'New Mexico\'s most famous leg-burner climbs four life zones from desert '
        'to Canadian forest up the west face of the Sandias. Most hikers ride the '
        'Sandia Peak Tramway down after gaining 3,775 feet of sweeping '
        'Albuquerque views.',
    tags: ['Mountain', 'Views', 'Tram', 'Switchbacks'],
    routePoints: _route(35.21925, -106.48116,
        spanDeg: 0.0337, loop: false, seed: 226),
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
