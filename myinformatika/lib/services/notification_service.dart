import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  /// Initialize notifications
  Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Basic notification channel',
          defaultColor: const Color.fromARGB(255, 99, 71, 192),
          ledColor: const Color.fromARGB(255, 255, 0, 0),
          importance: NotificationImportance.High,
        ),
        NotificationChannel(
          channelKey: 'course_channel',
          channelName: 'Course Notifications',
          channelDescription: 'Notifications related to courses',
          defaultColor: const Color.fromARGB(255, 99, 71, 192),
          ledColor: const Color.fromARGB(255, 0, 255, 0),
          importance: NotificationImportance.High,
        ),
        NotificationChannel(
          channelKey: 'enrollment_channel',
          channelName: 'Enrollment Notifications',
          channelDescription: 'Notifications related to course enrollment',
          defaultColor: const Color.fromARGB(255, 99, 71, 192),
          ledColor: const Color.fromARGB(255, 255, 255, 0),
          importance: NotificationImportance.High,
        ),
      ],
      debug: true,
    );

    // Request notification permissions
    await AwesomeNotifications().requestPermissionToSendNotifications();

    // Set notification event listener
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
      onNotificationCreatedMethod: _onNotificationCreatedMethod,
      onNotificationDisplayedMethod: _onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: _onDismissActionReceivedMethod,
    );
  }

  /// Show basic notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? summary,
    String channelKey = 'basic_channel',
    NotificationLayout notificationLayout = NotificationLayout.Default,
    Map<String, String>? payload,
    int id = 0,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: channelKey,
        title: title,
        body: body,
        summary: summary,
        notificationLayout: notificationLayout,
        payload: payload,
        actionType: ActionType.Default,
      ),
    );
  }

  /// Show enrollment notification
  Future<void> showEnrollmentNotification({
    required String courseName,
    required String instructorName,
    String? payload,
  }) async {
    await showNotification(
      title: 'Course Enrollment Successful',
      body: 'You have successfully enrolled in "$courseName" by $instructorName',
      channelKey: 'enrollment_channel',
      payload: {'courseName': courseName, 'instructorName': instructorName},
      id: 1,
    );
  }

  /// Show new course notification
  Future<void> showNewCourseNotification({
    required String courseName,
    required String instructorName,
  }) async {
    await showNotification(
      title: 'New Course Available',
      body: 'A new course "$courseName" has been added by $instructorName',
      channelKey: 'course_channel',
      payload: {'courseName': courseName, 'instructorName': instructorName},
      id: 2,
    );
  }

  /// Show badge notification count
  Future<void> setBadgeCount(int count) async {
    await AwesomeNotifications().setGlobalBadgeCounter(count);
  }

  /// Cancel notification
  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  /// Notification callbacks

  /// This method is called when user interacts with notification
  @pragma("vm:entry-point")
  static Future<void> _onActionReceivedMethod(ReceivedAction receivedAction) async {
    // Handle notification action
    debugPrint('Notification action: ${receivedAction.payload}');
  }

  /// This method is called when notification is created
  @pragma("vm:entry-point")
  static Future<void> _onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    debugPrint('Notification created: ${receivedNotification.title}');
  }

  /// This method is called when notification is displayed
  @pragma("vm:entry-point")
  static Future<void> _onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    debugPrint('Notification displayed: ${receivedNotification.title}');
  }

  /// This method is called when user dismisses notification
  @pragma("vm:entry-point")
  static Future<void> _onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    debugPrint('Notification dismissed: ${receivedAction.payload}');
  }
}

// Import flutter foundation for debugPrint
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
