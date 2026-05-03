import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'bloc/habit_bloc.dart';
import 'bloc/mood_bloc.dart';
import 'bloc/expense_bloc.dart';
import 'bloc/settings_bloc.dart';
import 'bloc/auth_bloc.dart';
import 'utils/database_helper.dart';
import 'utils/notification_helper.dart';
import 'screens/dashboard_screen.dart';
import 'firebase/firebase_service.dart';
import 'package:firebase_core/firebase_core.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize database
  await DatabaseHelper.instance.database;
  
  // Initialize notifications
  // await NotificationHelper.initialize(flutterLocalNotificationsPlugin);
  
  // Initialize localization
  await EasyLocalization.ensureInitialized();
  
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('tr', 'TR'),
        Locale('uz', 'UZ'),
        Locale('ru', 'RU'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HabitBloc()..add(const LoadHabits())),
        BlocProvider(create: (_) => MoodBloc()..add(const LoadMoods())),
        BlocProvider(create: (_) => ExpenseBloc()..add(const LoadExpenses())),
        BlocProvider(create: (_) => SettingsBloc()..add(const LoadSettings())),
        BlocProvider(create: (_) => AuthBloc()..add(CheckAuthStatus())),
      ],
      child: MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: 'HabitGenius',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFF2196F3),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2196F3),
            secondary: Color(0xFF7C4DFF),
            surface: Colors.white,
          ),
          scaffoldBackgroundColor: Colors.white,
          useMaterial3: true,
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}