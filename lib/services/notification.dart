import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

final notificationsServices = ChangeNotifierProvider<NotificationsServices>(
  (ref) => NotificationsServices(),
);

class NotificationsServices extends ChangeNotifier {
  //global
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //divice base settings
  final AndroidInitializationSettings androidInitializationSettings =
      const AndroidInitializationSettings("bell");

  final DarwinInitializationSettings initializationSettingsDarwin =
      const DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );

  Future<void> initialiseNotifications() async {
    // final token = await firebaseMessaging.getToken();
    // log(token.toString());
    log("notificaion init...");
    await firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      sound: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        // Handle when the app is opened from a notification
        String? imageUrl = message.notification?.android?.imageUrl;

        if (imageUrl != null && imageUrl.isNotEmpty) {
          String imagePath = await downloadImage(imageUrl);
          if (imagePath.isNotEmpty) {
            sendNotificationImage(
              imagePath,
              message.notification?.title,
              message.notification?.body,
            );
          }
        } else {
          sendNotification(
            message.notification?.title,
            message.notification?.body,
          );
        }
      });

      FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage message) async {
        // Handle when the app is opened from a notification
        String? imageUrl = message.notification?.android?.imageUrl;

        if (imageUrl != null && imageUrl.isNotEmpty) {
          String imagePath = await downloadImage(imageUrl);
          if (imagePath.isNotEmpty) {
            sendNotificationImage(
              imagePath,
              message.notification?.title,
              message.notification?.body,
            );
          }
        } else {
          sendNotification(
            message.notification?.title,
            message.notification?.body,
          );
        }
      });

      // FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
      //   return true;
      // });
    } catch (e) {
      log(e.toString());
    }
  }

  void sendNotification(String? title, String? body) {
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      "channelId",
      "channelName",
      importance: Importance.max,
      priority: Priority.high,
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
  }

  void sendNotificationImage(String imagePath, String? title, String? body) {
    // If the image was downloaded successfully, create a BigPictureStyle
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
      FilePathAndroidBitmap(imagePath),
      largeIcon: FilePathAndroidBitmap(imagePath),
      contentTitle: title,
      summaryText: body,
    );

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channelId',
      'channelName',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: bigPictureStyleInformation,
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
  }

  Future<String> downloadImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      // Get the temporary directory to save the downloaded image
      final directory = await getTemporaryDirectory();
      // Generate a unique file name for the image
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      // Create the file path by combining the directory and file name
      final filePath = '${directory.path}/$fileName';

      // Write the image data to the file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // Return the local path of the downloaded image
      return filePath;
    } else {
      // Return an empty string if the image download fails
      return '';
    }
  }

  Future<void> sustotopic(String topic) async {
    await firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> ussustotopic(String topic) async {
    await firebaseMessaging.unsubscribeFromTopic(topic);
  }
}
