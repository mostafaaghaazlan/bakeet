// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:bakeet/core/ui/screens/splash_screen.dart';
// import 'keys.dart';

// class FireBaseNotification {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   Future<void> initNotification() async {
//     await _requestNotificationPermission();

//     final String? token = await _firebaseMessaging.getToken();
//     if (kDebugMode) {
//       print("FCM Token: $token");
//     }
//     // CacheHelper.setDeviceToken(token);

//     await _firebaseMessaging.subscribeToTopic("all");

//     // if (defaultTargetPlatform == TargetPlatform.iOS) {
//     final String? apnsToken = await _firebaseMessaging.getAPNSToken();
//     if (kDebugMode) {
//       print("APNs Token: $apnsToken");
//     }
//     // }

//     await _requestIOSPermissions();
//     _initializeForegroundNotifications();
//   }

//   Future<void> _requestNotificationPermission() async {
//     NotificationSettings settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//           alert: true,
//           badge: true,
//           sound: true,
//         );

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       if (kDebugMode) {
//         print('Notification permission granted');
//       }
//     } else if (settings.authorizationStatus ==
//         AuthorizationStatus.provisional) {
//       if (kDebugMode) {
//         print('Provisional notification permission granted');
//       }
//     } else {
//       if (kDebugMode) {
//         print('Notification permission denied');
//       }
//     }
//   }

//   Future<void> _requestIOSPermissions() async {
//     final bool? result = await _localNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//           IOSFlutterLocalNotificationsPlugin
//         >()
//         ?.requestPermissions(alert: true, badge: true, sound: true);

//     if (result == true) {
//       if (kDebugMode) {
//         print('iOS Notification permissions granted');
//       }
//     } else {
//       if (kDebugMode) {
//         print('iOS Notification permissions denied');
//       }
//     }
//   }

//   void _initializeForegroundNotifications() {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       if (kDebugMode) {
//         print(
//           "Foreground notification received: ${message.notification?.title}",
//         );
//       }
//       _handleForegroundNotification(message);
//     });
//   }

//   void handleBackgroundNotifications() {
//     FirebaseMessaging.instance.getInitialMessage().then(
//       _navigateToSplashScreen,
//     );
//     FirebaseMessaging.onMessageOpenedApp.listen(_navigateToSplashScreen);
//   }

//   void _handleForegroundNotification(RemoteMessage message) async {
//     if (message.notification == null) return;

//     final String title = message.notification!.title ?? "No Title";
//     final String body = message.notification!.body ?? "No Body";
//     final String? imageUrl =
//         message.notification!.android?.imageUrl ??
//         message.notification!.apple?.imageUrl;

//     if (imageUrl != null) {
//       final notificationDetails = await _createImageNotificationDetails(
//         imageUrl,
//         title,
//         body,
//       );
//       await _localNotificationsPlugin.show(
//         message.hashCode,
//         title,
//         body,
//         notificationDetails,
//         payload: jsonEncode(message.data),
//       );
//     } else if (message.data.containsKey('progress')) {
//       await _showProgressNotification(message, title, body);
//     } else {
//       final notificationDetails = _createDefaultNotificationDetails();
//       await _localNotificationsPlugin.show(
//         message.hashCode,
//         title,
//         body,
//         notificationDetails,
//         payload: jsonEncode(message.data),
//       );
//     }
//   }

//   Future<NotificationDetails> _createImageNotificationDetails(
//     String imageUrl,
//     String title,
//     String body,
//   ) async {
//     try {
//       final String base64Image = await _downloadAndConvertImage(imageUrl);
//       final bigPictureStyleInformation = BigPictureStyleInformation(
//         ByteArrayAndroidBitmap.fromBase64String(base64Image),
//         contentTitle: title,
//         summaryText: body,
//       );

//       final androidDetails = AndroidNotificationDetails(
//         'image_channel_id',
//         'Image Notifications',
//         channelDescription: 'Notifications with images',
//         importance: Importance.max,
//         priority: Priority.high,
//         styleInformation: bigPictureStyleInformation,
//         icon: "@mipmap/ic_launcher",
//         playSound: true,
//       );

//       const iosDetails = DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       );

//       return NotificationDetails(android: androidDetails, iOS: iosDetails);
//     } catch (e) {
//       debugPrint("Failed to create image notification: $e");
//       return _createDefaultNotificationDetails();
//     }
//   }

//   Future<void> _showProgressNotification(
//     RemoteMessage message,
//     String title,
//     String body,
//   ) async {
//     final int progress = int.tryParse(message.data['progress'] ?? '0') ?? 0;

//     for (int i = progress; i <= 100; i += 10) {
//       final androidNotificationDetails = AndroidNotificationDetails(
//         icon: "@mipmap/ic_launcher",
//         'progress_channel_id',
//         'Progress Notifications',
//         channelDescription: 'Notifications with progress updates',
//         importance: Importance.max,
//         priority: Priority.high,
//         showProgress: true,
//         maxProgress: 100,
//         progress: i,
//       );

//       const iosNotificationDetails = DarwinNotificationDetails(
//         presentSound: true,
//         presentAlert: true,
//       );

//       final notificationDetails = NotificationDetails(
//         android: androidNotificationDetails,
//         iOS: iosNotificationDetails,
//       );

//       await _localNotificationsPlugin.show(
//         message.hashCode,
//         title,
//         '$body ($i%)',
//         notificationDetails,
//       );

//       await Future.delayed(const Duration(milliseconds: 500));
//     }
//   }

//   NotificationDetails _createDefaultNotificationDetails() {
//     const AndroidNotificationDetails androidNotificationDetails =
//         AndroidNotificationDetails(
//           'default_channel_id',
//           'Default Notifications',
//           channelDescription: 'Simple notifications',
//           importance: Importance.max,
//           priority: Priority.high,
//           playSound: true,
//           icon: "@mipmap/ic_launcher",
//         );

//     const DarwinNotificationDetails iosNotificationDetails =
//         DarwinNotificationDetails(
//           presentAlert: true,
//           presentBadge: true,
//           presentSound: true,
//         );

//     return const NotificationDetails(
//       android: androidNotificationDetails,
//       iOS: iosNotificationDetails,
//     );
//   }

//   Future<String> _downloadAndConvertImage(String imageUrl) async {
//     try {
//       final response = await NetworkAssetBundle(Uri.parse(imageUrl)).load("");
//       final bytes = response.buffer.asUint8List();
//       return base64Encode(bytes);
//     } catch (e) {
//       debugPrint("Failed to download image: $e");
//       return "";
//     }
//   }

//   void _navigateToSplashScreen(RemoteMessage? message) {
//     if (message == null) return;

//     Keys.navigatorKey.currentState?.push(
//       MaterialPageRoute(builder: (context) => const SplashScreen()),
//     );
//   }
// }
