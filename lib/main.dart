import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
        colorScheme: ColorScheme.light(
          primary: Color(0xFF0EA5E9),
          onPrimary: Colors.white,
          secondary: Color(0xFF0284C7),
          surface: Colors.white,
          background: Color(0xFFF8FAFC),
          onBackground: Color(0xFF0F172A),
          error: Color(0xFFEF4444),
        ),
        useMaterial3: true,
        fontFamily: GoogleFonts.inter().fontFamily,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF0F172A),
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF0EA5E9), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFEF4444)),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF0EA5E9),
          onPrimary: const Color.fromARGB(255, 247, 239, 239),
          secondary: Color(0xFF38BDF8),
          surface: Color(0xFF1E293B),
          background: Color(0xFF0F172A),
          onBackground: Color(0xFFF8FAFC),
          error: Color(0xFFEF4444),
        ),
        useMaterial3: true,
        fontFamily: GoogleFonts.inter().fontFamily,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFFF8FAFC),
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF8FAFC),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1E293B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF334155)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF334155)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF0EA5E9), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFEF4444)),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      themeMode: themeMode,
      home: FutureBuilder(
        future: Future.delayed(Duration(milliseconds: 500)),
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
