import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
// Bildirim Servisimizi import ediyoruz
import 'package:quvexai_mobile/core/notifications/notification_service.dart';

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

    // 1. iOS için ön planda bildirim gösterme ayarı (Android için aşağıda manuel yapıyoruz)
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Uygulama KAPALIYKEN bildirime tıklanırsa
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleRedirect(message);
      }
    });

    // 3. Uygulama ARKA PLANDAYKEN (ama açıkken) bildirime tıklanırsa
    // DÜZELTME: .instance kaldırıldı, onMessageOpenedApp statik bir üyedir.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleRedirect(message);
    });

    // 4. 🔥 UYGULAMA AÇIKKEN (FOREGROUND) BİLDİRİM GELDİĞİNDE 🔥
    // Sorunun çözümü burasıdır.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Foreground bildirim geldi: ${message.notification?.title}");

      // Eğer gelen mesajın bir "Notification" başlığı varsa
      if (message.notification != null) {
        // Firebase mesajını alıp, kendi Local Notification servisimizle gösteriyoruz
        NotificationService.instance.showNotification(
          title: message.notification!.title ?? "Bildirim",
          body: message.notification!.body ?? "",
          payload: message.data
              .toString(), // Veriyi payload olarak saklayabiliriz
        );
      }
    });
  }

  // Yönlendirme Mantığı (Kod tekrarını önlemek için ayırdık)
  void _handleRedirect(RemoteMessage message) {
    print("👉 Bildirim yönlendirmesi: ${message.data}");
    final type = message.data["type"];

    if (type == "daily_reminder") {
      context.push("/tests");
    } else if (type == "test_result") {
      final sessionId = message.data["sessionId"];
      if (sessionId != null) {
        context.push("/test-results/$sessionId");
      }
    } else if (type == "sync") {
      context.push("/dashboard");
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
