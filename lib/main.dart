import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/data/model/User.dart';
import 'app/data/provider/localDatabase.dart';
import 'app/data/services/FirebaseHelper.dart';
import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';
import 'app/translations/app_translations.dart';
import 'app/translations/languageController.dart';
import 'app/translations/local_storge.dart';
import 'app/userPrefrence.dart';
import 'app/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(ThemeController());

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  await UserPreference.init();
  /* mycontroller.langCode = await mycontroller.getSavedLanguageCode();
  print('lang main : ${mycontroller.langCode!.value}');*/
  mycontroller.langCode = await mycontroller.getSavedLanguageCode();
  print('lang main : ${mycontroller.langCode?.value ?? "la lang est null"}');

  runApp(MultiProvider(providers: [
    Provider<CartDatabase>(
      create: (_) => CartDatabase(),
    )
  ], child: MyApp()));
  /* if (code_lang != null) {
    runApp(MultiProvider(
        providers: [
          Provider<CartDatabase>(
            create: (_) => CartDatabase(),
          )
        ],
        child: MyApp(
          code_lang: code_lang,
        )));
  } else {
    // Handle the case where code_lang is null
    runApp(MultiProvider(
        providers: [
          Provider<CartDatabase>(
            create: (_) => CartDatabase(),
          )
        ],
        child: MyApp(
          code_lang: 'ar',
        )));
  }*/
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class MyApp extends StatefulWidget {
  //final String code_lang;
  //MyApp({required this.code_lang});
  static User? currentUser;

  /* static Position selectedPosotion =
      Position.fromMap({'latitude': 0.0, 'longitude': 0.0});*/
  static Position selectedPosotion = Position.fromMap({
    'latitude': 0.0,
    'longitude': 0.0,
    'timestamp': DateTime.now().millisecondsSinceEpoch
  });
  bool isLogin = false;

  @override
  State<MyApp> createState() => _MyAppState();

  Future<bool> getFinishedOnBoarding() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(FINISHED_ON_BOARDING) ?? false;
  }
}

Mycontroll mycontroller = Get.put(Mycontroll());

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late StreamSubscription tokenStream;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter e-commerce app',
      theme: Themes.lightTheme,
      translations: AppTranslation(),
      //locale: Get.deviceLocale,
      locale: mycontroller.langCode != null
          ? Locale(mycontroller.langCode!.value)
          : Locale('ar', 'PS'),
      navigatorKey: Get.key,
      fallbackLocale: mycontroller.langCode != null
          ? Locale(mycontroller.langCode!.value)
          : Locale('ar', 'PS'),
      darkTheme: Themes.lightTheme,
      // themeMode: ThemeMode.system,
      //  themeMode: getThemeMode(themeController.theme),
      getPages: AppPages.pages,
      initialRoute: Routes.SPLASH,
    );
  }

  void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
        "01",
        "Super Talab",
        importance: Importance.max,
        icon: '@mipmap/ic_launcher',
        priority: Priority.high,
        enableVibration: true,
      ));

      await FlutterLocalNotificationsPlugin().show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: jsonEncode(message.data),
      );
    } on Exception catch (e) {}
  }

  @override
  void dispose() {
    tokenStream.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> initialize(BuildContext context) async {
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.high,
    );

    await FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void initializeFlutterFire() async {
    try {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

      final FlutterExceptionHandler? originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails errorDetails) async {
        await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
        originalOnError!(errorDetails);
        // Forward to original handler.
      };

      tokenStream =
          FireStoreUtils.firebaseMessaging.onTokenRefresh.listen((event) {
        if (MyApp.currentUser != null) {
          MyApp.currentUser!.fcmToken = event;
          FireStoreUtils.updateCurrentUser(MyApp.currentUser!);
        }
      });
    } catch (e) {
      // Set `_error` state to true if Firebase initialization fails
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    setupInteractedMessage(context);
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  // This widget is the root of your application.
  Future<void> setupInteractedMessage(BuildContext context) async {
    initialize(context);
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
          'Message also contained a notification: ${initialMessage.notification!.body}');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        display(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.notification != null) {
        display(message);
      }
    });
  }

  static Future<User> getUserModelFromSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userModelJson = prefs.getString('userModel');
    if (userModelJson != null) {
      final userModelMap = json.decode(userModelJson);
      return User.fromJson(userModelMap);
    } else {
      return User(); // Return a default UserModel if not found in SharedPreferences
    }
  }
}
