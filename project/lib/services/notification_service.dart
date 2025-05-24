// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';


// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print("Handling a background message: ${message.messageId}");
//   print('Message data: ${message.data}');
//   if (message.notification != null) {
//     print(
//       'Message notification: ${message.notification?.title} - ${message.notification?.body}',
//     );
//   }
// }

// class NotificationService {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'travel_plan_reminders_channel',
//     'Travel Plan Reminders',
//     description:
//         'Channel for travel plan reminder notifications.',
//     importance: Importance.max,
//     playSound: true,
//   );

//   Future<void> initialize() async {
//     print("NotificationService: Initializing...");
//     NotificationSettings settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );

//     print(
//       'NotificationService: User granted notification permission: ${settings.authorizationStatus}',
//     );

//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings(
//           '@mipmap/ic_launcher',
//         );

//     const DarwinInitializationSettings initializationSettingsIOS =
//         DarwinInitializationSettings(
//           requestAlertPermission: true,
//           requestBadgePermission: true,
//           requestSoundPermission: true,
//         );

//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//           android: initializationSettingsAndroid,
//           iOS: initializationSettingsIOS,
//         );

//     try {
//       await _flutterLocalNotificationsPlugin.initialize(
//         initializationSettings,
//         onDidReceiveNotificationResponse: (
//           NotificationResponse notificationResponse,
//         ) async {
//           print('Notification tapped: ${notificationResponse.payload}');
//           if (notificationResponse.payload != null &&
//               notificationResponse.payload!.isNotEmpty) {
//           }
//         },
//       );
//       print(
//         "NotificationService: FlutterLocalNotificationsPlugin initialized.",
//       );
//     } catch (e) {
//       print(
//         "NotificationService: Error initializing FlutterLocalNotificationsPlugin: $e",
//       );
//     }

//     try {
//       await _flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin
//           >()
//           ?.createNotificationChannel(channel);
//       print(
//         "NotificationService: Android notification channel created/ensured.",
//       );
//     } catch (e) {
//       print(
//         "NotificationService: Error creating Android notification channel: $e",
//       );
//     }

//     await _getAndStoreFCMToken();

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('NotificationService: Got a message whilst in the foreground!');
//       print('Message data: ${message.data}');

//       if (message.notification != null) {
//         print('Message also contained a notification: ${message.notification}');
//         _showLocalNotification(message);
//       }
//     });

//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//     FirebaseMessaging.instance.getInitialMessage().then((
//       RemoteMessage? message,
//     ) {
//       if (message != null) {
//         print(
//           "NotificationService: App opened from terminated state by notification: ${message.data}",
//         );
//       }
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print(
//         'NotificationService: App opened from background by notification: ${message.data}',
//       );
//     });
//     print("NotificationService: Initialization complete.");
//   }

//   Future<void> _getAndStoreFCMToken() async {
//     try {
//       String? token = await _firebaseMessaging.getToken();
//       print("NotificationService: Firebase Messaging Token: $token");

//       _firebaseMessaging.onTokenRefresh.listen((newToken) {
//         print(
//           "NotificationService: Firebase Messaging Token Refresh: $newToken",
//         );
//       });
//     } catch (e) {
//       print("NotificationService: Error getting FCM token: $e");
//     }
//   }

//   Future<void> _showLocalNotification(RemoteMessage message) async {
//     RemoteNotification? notification = message.notification;
//     AndroidNotification? androidSpecifics = message.notification?.android;

//     if (notification != null) {
//       try {
//         _flutterLocalNotificationsPlugin.show(
//           notification.hashCode,
//           notification.title,
//           notification.body,
//           NotificationDetails(
//             android: AndroidNotificationDetails(
//               channel.id,
//               channel.name,
//               channelDescription: channel.description,
//               icon: androidSpecifics?.smallIcon ?? '@mipmap/ic_launcher',
//               importance: Importance.max,
//               priority: Priority.high,
//               playSound: true,
//             ),
//             iOS: const DarwinNotificationDetails(
//               presentAlert: true,
//               presentBadge: true,
//               presentSound: true,
//             ),
//           ),
//           payload: message.data['payload'] as String?,
//         );
//         print("NotificationService: Local notification shown.");
//       } catch (e) {
//         print("NotificationService: Error showing local notification: $e");
//       }
//     }
//   }
// }