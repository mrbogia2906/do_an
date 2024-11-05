import 'package:firebase_messaging/firebase_messaging.dart';

abstract class NotificationRepository {
  Future<void> addNotifi(String userId, String notifi);
  Future<List<String>> getNotifi(String userId);
  Future<void> deleteNotifi(String userId, String notifi);
  Future<void> initNotifications();
  Future<void> handleBackgroundMessage(RemoteMessage message);
}

class NotifiRepositoryImpl implements NotificationRepository {
  final _firebaseMessaging = FirebaseMessaging.instance;

  @override
  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print('FCM Token: $fCMToken');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  @override
  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('Handling a background message ${message.notification?.title}');
  }

  @override
  Future<void> addNotifi(String userId, String notifi) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteNotifi(String userId, String notifi) {
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getNotifi(String userId) {
    throw UnimplementedError();
  }
}
