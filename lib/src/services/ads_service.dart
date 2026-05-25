import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  bool _loadingRewarded = false;
  bool _loadingInterstitial = false;

  void initialize() {
    _loadRewardedAd();
    _loadInterstitialAd();
  }

  void _loadRewardedAd() {
    if (_loadingRewarded || _rewardedAd != null) return;
    _loadingRewarded = true;
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/5224354917',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _loadingRewarded = false;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _loadingRewarded = false;
        },
      ),
    );
  }

  void _loadInterstitialAd() {
    if (_loadingInterstitial || _interstitialAd != null) return;
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _loadingInterstitial = false;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _loadingInterstitial = false;
        },
      ),
    );
  }

  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) {
      _loadRewardedAd();
      return false;
    }
    final completer = Completer<bool>();
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
        if (!completer.isCompleted) completer.complete(false);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
      if (!completer.isCompleted) completer.complete(true);
    });
    return completer.future;
  }

  void showInterstitial() {
    if (_interstitialAd == null) {
      _loadInterstitialAd();
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
      },
    );
    _interstitialAd!.show();
  }
}
