import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});
  static const routeName = '/terms';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Terms')),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Privacy Policy', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('DesiRizz values your privacy. Uploaded screenshots are used only for OCR extraction and are deleted after processing. We save minimal user profile data, coins, and favorite replies.', style: TextStyle(fontSize: 16, height: 1.6)),
              SizedBox(height: 18),
              Text('Terms of Use', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text('This app is a chat assistant to generate conversational Hindi/Hinglish replies. The replies are suggestions and may be edited before sharing.', style: TextStyle(fontSize: 16, height: 1.6)),
            ],
          ),
        ),
      ),
    );
  }
}
