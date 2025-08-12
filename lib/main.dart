import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:map/src/presentation/screens/history_screen.dart';
import 'package:provider/provider.dart';
import 'src/presentation/providers/pose_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ChangeNotifierProvider(
      create: (context) => PoseProvider(),
      child: MaterialApp(
        title: 'Kinetiq', 
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
          primaryColor: const Color(0xFFBB86FC),
          fontFamily: GoogleFonts.inter().fontFamily,
          
          textTheme: textTheme,
          
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF1F1F1F),
            elevation: 0,
            titleTextStyle: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),

          cardTheme: CardThemeData(
            color: const Color(0xFF1E1E1E),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFBB86FC),
            foregroundColor: Colors.black,
          ),

          dialogTheme: DialogThemeData(
            backgroundColor: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)
            ),
            titleTextStyle: GoogleFonts.inter(
              fontSize: 20, 
              fontWeight: FontWeight.bold,
            ),
          )
        ),
        home: const HistoryScreen(),
      ),
    );
  }
}