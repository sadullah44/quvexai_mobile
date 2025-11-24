import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';

class AppStartListener extends StatefulWidget {
  final Widget child;
  const AppStartListener({super.key, required this.child});

  @override
  State<AppStartListener> createState() => _AppStartListenerState();
}

class _AppStartListenerState extends State<AppStartListener> {
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // App tamamen kapalıyken bildirime tıklama
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        final type = message.data["type"];

        if (type == "daily_reminder") {
          context.push("/tests");
        } else if (type == "test_result") {
          final sessionId = message.data["sessionId"];
          context.push("/test-results/$sessionId");
        } else if (type == "sync") {
          context.push("/dashboard");
        }
      }
    });

    // foreground
    FirebaseMessaging.onMessage.listen((message) {});

    // background → app açıkken tıklama
    FirebaseMessaging.onMessageOpenedApp.listen((message) {});

    // 🔥 Foreground mesaj listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Foreground bildirim geldi: ${message.notification?.title}");
      print("📄 Body: ${message.notification?.body}");
    });

    // 🔥 Bildirim tıklama (app açıkken)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("👉 Bildirim tıklandı. Payload:");
      print(message.data);

      final type = message.data["type"];

      if (type == "daily_reminder") {
        context.push("/tests");
      } else if (type == "test_result") {
        final sessionId = message.data["sessionId"];
        context.push("/test-results/$sessionId");
      } else if (type == "sync") {
        context.push("/dashboard");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
