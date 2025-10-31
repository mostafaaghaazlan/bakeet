// import 'package:flutter/material.dart';
// import 'package:bakeet/core/constant/app_images/app_images.dart';

// class SimpleDayNightSwitch extends StatefulWidget {
//   final bool value;
//   final ValueChanged<bool> onChanged;

//   const SimpleDayNightSwitch({
//     super.key,
//     required this.value,
//     required this.onChanged,
//   });

//   @override
//   SimpleDayNightSwitchState createState() => SimpleDayNightSwitchState();
// }

// class SimpleDayNightSwitchState extends State<SimpleDayNightSwitch>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   bool value = false;

//   @override
//   void initState() {
//     super.initState();
//     value = widget.value;
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//       value: value ? 1.0 : 0.0,
//     );
//   }

//   @override
//   void didUpdateWidget(SimpleDayNightSwitch oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.value != widget.value) {
//       setState(() {
//         value = widget.value;
//       });
//       widget.value ? _controller.forward() : _controller.reverse();
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           value = !value;
//         });
//         widget.onChanged(value);
//       },
//       child: AnimatedBuilder(
//         animation: _controller,
//         builder: (context, child) {
//           return Container(
//             width: 80,
//             height: 40,
//             decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
//             child: Stack(
//               children: [
//                 Opacity(
//                   opacity: 1.0 - _controller.value,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//                       image: const DecorationImage(
//                         image: AssetImage(sunBackImage),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Opacity(
//                   opacity: _controller.value,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//                       image: const DecorationImage(
//                         image: AssetImage(moonBackImage),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   left: 4 + (_controller.value * (80 - 32 - 8)),
//                   child: CircleAvatar(
//                     radius: 16,
//                     backgroundColor: Colors.transparent,
//                     child: Image.asset(
//                       _controller.value < 0.5 ? sunImage : moonImage,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
