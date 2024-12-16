// // lib/models/toss_scenario.dart
// import 'package:flutter/material.dart';

// class TossScenario {
//   final String name;
//   final String description;
//   final IconData icon;
//   final Color backgroundColor;
//   final List<String> details;

//   const TossScenario({
//     required this.name,
//     required this.description,
//     required this.icon,
//     required this.backgroundColor,
//     required this.details,
//   });

//   static final Map<String, TossScenario> scenarios = {
//     'Cricket Toss': const TossScenario(
//       name: 'Cricket Toss',
//       description: 'Determine who bats or bowls first',
//       icon: Icons.sports_cricket,
//       backgroundColor: Color(0xFF2C5E1A),
//       details: [
//         'Winner chooses: Bat or Bowl',
//         'Critical decision in match strategy',
//         'Luck plays a crucial role'
//       ],
//     ),
//     'Bill Splitter': const TossScenario(
//       name: 'Bill Splitter',
//       description: 'Decide who pays the restaurant bill',
//       icon: Icons.restaurant,
//       backgroundColor: Color(0xFF4A4A4A),
//       details: [
//         'Fair way to split expenses',
//         'No hard feelings',
//         'Quick decision maker'
//       ],
//     ),
//   };
// }