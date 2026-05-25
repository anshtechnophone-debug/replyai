import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ai_service.dart';
import 'ads_service.dart';
import 'ocr_service.dart';

class ReplyResult {
  final String text;
  final String style;
  final DateTime createdAt;

  ReplyResult({
    required this.text,
    required this.style,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class AppState extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AdsService ads = AdsService();

  bool loadingUser = true;
  bool signedIn = false;
  bool isGuest = true;
  bool hasPremium = false;
  bool busy = false;
  int coins = 120;
  int generationCount = 0;
  String activeMode = 'Flirty';
  String inputText = '';
  String ocrText = '';
  List<ReplyResult> replies = [];
  List<String> favorites = [];
  String message = '';
  String errorMessage = '';
  DateTime lastDailyClaim = DateTime.fromMillisecondsSinceEpoch(0);

  AppState() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    coins = prefs.getInt('desirizz_coins') ?? 120;
    lastDailyClaim = DateTime.tryParse(prefs.getString('desirizz_daily') ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
    hasPremium = prefs.getBool('desirizz_premium') ?? false;
    _auth.authStateChanges().listen(_onAuthStateChanged);
    ads.initialize();
    loadingUser = false;
    notifyListeners();
  }

  Future<void> _onAuthStateChanged(User? user) async {
    signedIn = user != null;
    isGuest = user == null;
    if (user != null) {
      await _loadRemoteProfile(user.uid);
    }
    notifyListeners();
  }

  Future<void> signInAnonymously() async {
    try {
      busy = true;
      notifyListeners();
      final credential = await _auth.signInAnonymously();
      if (credential.user != null) {
        await _loadRemoteProfile(credential.user!.uid);
      }
    } catch (error) {
      errorMessage = 'Unable to enter guest mode.';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
  try {
    busy = true;
    notifyListeners();

    // NEW: use GoogleSignIn.instance instead of GoogleSignIn(scopes:[...])
    await GoogleSignIn.instance.initialize(scopes: ['email']);
    final googleUser = await GoogleSignIn.instance.signIn();

    if (googleUser == null) {
      busy = false;
      notifyListeners();
      return;
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    if (result.user != null) {
      await _loadRemoteProfile(result.user!.uid);
    }
  } catch (error) {
    errorMessage = 'Google sign in failed.';
  } finally {
    busy = false;
    notifyListeners();
  }
}

  Future<void> signOut() async {
    await _auth.signOut();
    signedIn = false;
    isGuest = true;
    notifyListeners();
  }

  Future<void> _loadRemoteProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        coins = data['coins'] is int ? data['coins'] : coins;
        hasPremium = data['premium'] == true;
        favorites = List<String>.from(data['favorites'] ?? []);
      } else {
        await _firestore.collection('users').doc(uid).set({
          'coins': coins,
          'premium': false,
          'favorites': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await _persistLocalState();
    } catch (error) {
      debugPrint('Failed loading profile: $error');
    }
  }

  Future<void> _persistLocalState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('desirizz_coins', coins);
    await prefs.setString('desirizz_daily', lastDailyClaim.toIso8601String());
    await prefs.setBool('desirizz_premium', hasPremium);
  }

  Future<void> purchaseCoinPack(int amount) async {
    coins += amount;
    await _persistLocalState();
    notifyListeners();
    await _saveActivity();
  }

  Future<void> activatePremium() async {
    hasPremium = true;
    await _persistLocalState();
    await _saveActivity();
    notifyListeners();
  }

  void updateInput(String value) {
    inputText = value;
    notifyListeners();
  }

  void chooseMode(String mode) {
    activeMode = mode;
    notifyListeners();
  }

  Future<void> importScreenshot() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, maxHeight: 2400);
    if (image != null) {
      ocrText = await OcrService.extractText(File(image.path));
      inputText = ocrText;
      notifyListeners();
      await _deleteTempFile(image.path);
    }
  }

  Future<void> _deleteTempFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  Future<void> dailyReward() async {
    final now = DateTime.now();
    if (now.difference(lastDailyClaim).inHours >= 24) {
      coins += 70;
      lastDailyClaim = now;
      await _persistLocalState();
      notifyListeners();
    }
  }

  Future<void> claimRewardedAd() async {
    final success = await ads.showRewardedAd();
    if (success) {
      coins += 5;
      await _persistLocalState();
      notifyListeners();
    }
  }

  Future<void> generateReplies() async {
    if (busy) return;
    final context = inputText.trim();
    if (context.isEmpty) {
      errorMessage = 'Paste chat text or upload a screenshot first.';
      notifyListeners();
      return;
    }

    if (!hasPremium && coins < 10) {
      errorMessage = 'Not enough coins. Watch an ad or buy a pack.';
      notifyListeners();
      return;
    }

    busy = true;
    errorMessage = '';
    notifyListeners();

    try {
      if (!hasPremium) {
        coins -= 10;
        await _persistLocalState();
      }
      final rawReplies = await AiService.generateReplies(context, activeMode, hasPremium);
      replies = rawReplies
          .map((text) => ReplyResult(text: text.trim(), style: activeMode))
          .toList();
      generationCount++;
      if (generationCount % 3 == 0) {
        ads.showInterstitial();
      }
      await _saveActivity();
    } catch (error) {
      errorMessage = 'AI failed. Please try again.';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> _saveActivity() async {
    if (!signedIn) return;
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).set({
      'coins': coins,
      'premium': hasPremium,
      'favorites': favorites,
      'lastActivity': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void toggleFavorite(String text) {
    if (favorites.contains(text)) {
      favorites.remove(text);
    } else {
      favorites.add(text);
    }
    notifyListeners();
    _saveActivity();
  }
}
