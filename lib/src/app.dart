import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/terms_page.dart';

class DesiRizzApp extends StatelessWidget {
  const DesiRizzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DesiRizz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF07070D),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF120A20),
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9743FF),
          brightness: Brightness.dark,
          primary: const Color(0xFF9743FF),
          secondary: const Color(0xFFEA4FFF),
          background: const Color(0xFF07070D),
          surface: const Color(0xFF12111B),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.dark().textTheme,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9743FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            minimumSize: const Size.fromHeight(50),
          ),
        ),
      ),
      home: Consumer<AppState>(builder: (context, state, child) {
        if (state.loadingUser) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return state.signedIn ? const HomePage() : const LoginPage();
      }),
      routes: {
        TermsPage.routeName: (_) => const TermsPage(),
      },
    );
  }
}
