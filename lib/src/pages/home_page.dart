import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../widgets/reply_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const modes = [
    'Flirty',
    'Romantic',
    'Soft Boy',
    'Funny',
    'Toxic',
    'Dry Texter Recovery',
    'Late Night Chat',
    'Pickup Lines',
  ];

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<AppState>();
    if (_controller.text != state.inputText) {
      _controller.text = state.inputText;
      _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (_controller.text != state.inputText) {
      _controller.text = state.inputText;
      _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('DesiRizz'),
        actions: [
          IconButton(onPressed: state.claimRewardedAd, icon: const Icon(Icons.card_giftcard)),
          IconButton(onPressed: state.signOut, icon: const Icon(Icons.logout)),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(state),
              const SizedBox(height: 20),
              _buildInputArea(context, state),
              const SizedBox(height: 18),
              _buildModeChips(state),
              const SizedBox(height: 18),
              _buildActionButtons(state),
              if (state.errorMessage.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(state.errorMessage, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 22),
              if (state.busy) const Center(child: CircularProgressIndicator()) else ...[
                if (state.replies.isNotEmpty) ...[
                  const Text('Generated replies', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  ...state.replies.map((reply) => ReplyCard(
                        text: reply.text,
                        favorite: state.favorites.contains(reply.text),
                        onFavorite: () => state.toggleFavorite(reply.text),
                        onCopy: () {},
                        onShare: () {},
                      )),
                ] else ...[
                  const SizedBox(height: 60),
                  const Center(child: Text('Upload a chat screenshot or paste the message to generate replies.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16))),
                ],
              ],
              const SizedBox(height: 28),
              _buildPremiumCard(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppState state) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF12111B),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Coin balance', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Text('${state.coins} coins', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 6),
                Text(state.hasPremium ? 'VIP active' : 'Non-premium user', style: const TextStyle(color: Colors.white54)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1730),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(child: Icon(Icons.flash_on, color: Color(0xFFEA4FFF), size: 36)),
        ),
      ],
    );
  }

  Widget _buildInputArea(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF12111B),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chat context', style: TextStyle(fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            minLines: 4,
            maxLines: 8,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Paste conversation text or upload screenshot',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF0D0C15),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            ),
            onChanged: state.updateInput,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text('Upload screenshot'),
                  onPressed: state.busy ? null : () async {
                    await state.importScreenshot();
                    _controller.text = state.inputText;
                    _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.paste, color: Colors.white70),
                onPressed: () {
                  state.updateInput('Hey, what are you doing? 😏');
                  _controller.text = state.inputText;
                  _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeChips(AppState state) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: HomePage.modes.map((mode) {
        final active = state.activeMode == mode;
        return ChoiceChip(
          label: Text(mode),
          selected: active,
          selectedColor: const Color(0xFF9743FF),
          backgroundColor: const Color(0xFF1A162E),
          labelStyle: TextStyle(color: active ? Colors.white : Colors.white70),
          onSelected: (_) => state.chooseMode(mode),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: state.busy ? null : state.generateReplies,
          child: Text(state.hasPremium ? 'Generate unlimited replies' : 'Generate 5 replies • 10 coins'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: state.claimRewardedAd,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF9743FF)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text('Watch ad +5 coins'),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: state.dailyReward,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C43FF)),
              child: const Text('Daily streak +70'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPremiumCard(AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF9743FF), Color(0xFFEA4FFF)]),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('VIP Unlimited', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              const Text('No ads • Unlimited replies • Faster AI • Exclusive premium reply styles', style: TextStyle(color: Colors.white70, height: 1.6)),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: state.hasPremium ? null : state.activatePremium,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white24),
                child: Text(state.hasPremium ? 'VIP active' : 'Activate VIP'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF12111B),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Coin Packs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildPackButton(state, '₹10', '500 coins', 500),
                  _buildPackButton(state, '₹29', '1800 coins', 1800),
                  _buildPackButton(state, '₹49', '3500 coins', 3500),
                  _buildPackButton(state, '₹99', '8000 coins', 8000),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPackButton(AppState state, String label, String subtitle, int amount) {
    return SizedBox(
      width: 150,
      child: ElevatedButton(
        onPressed: () => state.purchaseCoinPack(amount),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1F1632),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 6),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
