// File: lib/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart'; // Required for background handler if using other Firebase services

// Function to handle background messages (must be a top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, like Firestore,
  // make sure you call `initializeApp` before using them.
  // IMPORTANT: The line below might cause issues if Firebase is already initialized.
  // It's generally recommended to ensure Firebase is initialized once at the app's entry point.
  // Consider removing this if main.dart already handles initialization thoroughly.
  // await Firebase.initializeApp(); // This might be problematic if called multiple times.

  print("Handling a background message: ${message.messageId}");
  print('Message data: ${message.data}');
  if (message.notification != null) {
    print(
      'Message notification: ${message.notification?.title} - ${message.notification?.body}',
    );
    // You could potentially show a local notification here if needed,
    // but often FCM handles this for background/terminated apps.
  }
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Define channel (Android 8.0+)
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'travel_plan_reminders_channel', // id
    'Travel Plan Reminders', // title
    description:
        'Channel for travel plan reminder notifications.', // description
    importance: Importance.max,
    playSound: true,
  );

  Future<void> initialize() async {
    print("NotificationService: Initializing...");
    // Request permission for iOS and web
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print(
      'NotificationService: User granted notification permission: ${settings.authorizationStatus}',
    );

    // Initialize FlutterLocalNotificationsPlugin
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        ); // Ensure you have this icon

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    try {
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (
          NotificationResponse notificationResponse,
        ) async {
          // Handle notification tap
          print('Notification tapped: ${notificationResponse.payload}');
          if (notificationResponse.payload != null &&
              notificationResponse.payload!.isNotEmpty) {
            // TODO: Handle payload for navigation or other actions
            // Example: _handleMessageNavigation({'payload': notificationResponse.payload});
          }
        },
      );
      print(
        "NotificationService: FlutterLocalNotificationsPlugin initialized.",
      );
    } catch (e) {
      print(
        "NotificationService: Error initializing FlutterLocalNotificationsPlugin: $e",
      );
    }

    // Create the Android Notification Channel
    try {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
      print(
        "NotificationService: Android notification channel created/ensured.",
      );
    } catch (e) {
      print(
        "NotificationService: Error creating Android notification channel: $e",
      );
    }

    // Get the FCM token
    await _getAndStoreFCMToken();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('NotificationService: Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message);
      }
    });

    // Handle background messages (setup the handler)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle when the app is opened from a terminated state via a notification
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        print(
          "NotificationService: App opened from terminated state by notification: ${message.data}",
        );
        // TODO: Navigate to a specific screen if needed based on message.data
        // Example: _handleMessageNavigation(message.data, isAppLaunch: true);
      }
    });

    // Handle when the app is opened from a background state via a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
        'NotificationService: App opened from background by notification: ${message.data}',
      );
      // TODO: Navigate to a specific screen
      // Example: _handleMessageNavigation(message.data);
    });
    print("NotificationService: Initialization complete.");
  }

  Future<void> _getAndStoreFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print("NotificationService: Firebase Messaging Token: $token");
      // TODO: Send this token to your server and associate it with the current user.
      // This is crucial for sending targeted notifications from your backend.
      // You would typically call an API in your UserApi to save/update this token.
      // Example:
      // final userId = FirebaseAuth.instance.currentUser?.uid;
      // if (userId != null && token != null) {
      //   await UserApi().storeUserFCMToken(userId, token);
      // }

      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print(
          "NotificationService: Firebase Messaging Token Refresh: $newToken",
        );
        // TODO: Update the token on your server for the current user.
        // Example:
        // final userId = FirebaseAuth.instance.currentUser?.uid;
        // if (userId != null && newToken != null) {
        //   await UserApi().storeUserFCMToken(userId, newToken); // Or an update method
        // }
      });
    } catch (e) {
      print("NotificationService: Error getting FCM token: $e");
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? androidSpecifics = message.notification?.android;

    if (notification != null) {
      try {
        _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: androidSpecifics?.smallIcon ?? '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: message.data['payload'] as String?,
        );
        print("NotificationService: Local notification shown.");
      } catch (e) {
        print("NotificationService: Error showing local notification: $e");
      }
    }
  }

  // TODO for User:
  // 1. Implement `_handleMessageNavigation` if you want to navigate when a notification is tapped.
  //    This will require a way to access your app's Navigator (e.g., a global key).
  // 2. Implement the server-side logic to send FCM tokens to your backend and for your backend
  //    to send push notifications (e.g., for travel plan reminders).
  //    The client is now set up to receive them.
  // 3. For travel plan reminders specifically:
  //    - User needs a UI to set their reminder preference (e.g., "1 day before", "3 days before").
  //    - This preference needs to be stored (e.g., in the User's Firestore document).
  //    - Your backend (e.g., Firebase Cloud Function running on a schedule) would:
  //        - Query for travel plans.
  //        - Check user reminder preferences.
  //        - If a reminder is due, send an FCM message to the user's device token.
}
