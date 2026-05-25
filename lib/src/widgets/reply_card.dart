import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ReplyCard extends StatelessWidget {
  final String text;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const ReplyCard({
    super.key,
    required this.text,
    required this.favorite,
    required this.onFavorite,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151523),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3A2F5D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(text, style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white)),
          const SizedBox(height: 14),
          Row(
            children: [
              IconButton(
                icon: Icon(favorite ? Icons.favorite : Icons.favorite_border, color: Colors.pinkAccent),
                onPressed: onFavorite,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.white70),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
                  onCopy();
                },
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white70),
                onPressed: () {
                  SharePlus.instance.share(text);
                  onShare();
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
