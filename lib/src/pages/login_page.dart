import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'terms_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text('DesiRizz', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              const Text('Gen-Z Hindi/Hinglish reply assistant for chat, flirting, and reel-ready texts.', style: TextStyle(fontSize: 16, color: Colors.white70)),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Continue as Guest'),
                onPressed: state.busy ? null : () => state.signInAnonymously(),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.person),
                label: const Text('Sign in with Google'),
                onPressed: state.busy ? null : () => state.signInWithGoogle(),
              ),
              const SizedBox(height: 28),
              const Text('Features included', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              const Text(
                '• AI chat reply generator\n'
                '• Screenshot OCR\n'
                '• Coins, rewards, and VIP\n'
                '• Save favorite replies\n'
                '• Dark Gen-Z UI',
                style: TextStyle(fontSize: 15, height: 1.6, color: Colors.white70),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, TermsPage.routeName),
                    child: const Text('Privacy Policy / Terms'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
