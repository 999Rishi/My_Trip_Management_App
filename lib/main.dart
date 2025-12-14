import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'models/trip.dart';
import 'models/expense.dart';
import 'models/user.dart';
import 'models/category.dart';
import 'models/settlement.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/loading_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      // Initialize Hive for web
      await Hive.initFlutter();
    } else {
      // Initialize Hive with a custom directory for mobile/desktop to avoid OneDrive issues
      try {
        final tempDir = await getTemporaryDirectory();
        final hiveDir = Directory(
          '${tempDir.path}/trip_expense_manager_hive_temp',
        );
        if (!await hiveDir.exists()) {
          await hiveDir.create(recursive: true);
        }
        Hive.init(hiveDir.path);
      } catch (e) {
        print('Error initializing Hive with temporary directory: $e');
        // Fallback to default initialization if custom directory fails
        await Hive.initFlutter();
      }
    }
  } catch (e) {
    print('Error initializing Hive: $e');
    // Final fallback to default initialization
    await Hive.initFlutter();
  }

  // Register adapters
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(TripAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(SettlementAdapter());

  // Open boxes with better error handling and reduced retry delay
  try {
    await _openHiveBoxesWithRetry();
  } catch (e) {
    print('Error opening Hive boxes after retries: $e');
  }

  runApp(ProviderScope(child: MyApp()));
}

/// Attempt to open Hive boxes with retry mechanism
Future<void> _openHiveBoxesWithRetry() async {
  int maxRetries = 2; // Reduced from 3 to 2
  int retryCount = 0;

  while (retryCount < maxRetries) {
    try {
      await Hive.openBox<User>('users');
      await Hive.openBox<Trip>('trips');
      await Hive.openBox<Expense>('expenses');
      await Hive.openBox<Category>('categories');
      await Hive.openBox<Settlement>('settlements');
      return; // Success, exit the retry loop
    } catch (e) {
      retryCount++;
      print('Attempt $retryCount failed to open Hive boxes: $e');
      if (retryCount < maxRetries) {
        // Reduced wait time from 3 seconds to 1 second
        await Future.delayed(Duration(seconds: 1));
      } else {
        rethrow; // Re-throw the error after max retries
      }
    }
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trip Expense Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeMode,
      home: FutureBuilder(
        future: Future.delayed(
          Duration(milliseconds: 500), // Reduced from 1500ms to 500ms
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return HomeScreen();
          } else {
            return LoadingScreen();
          }
        },
      ),
    );
  }
}
