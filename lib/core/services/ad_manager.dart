import 'package:firebase_database/firebase_database.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';

class AdManager {
  static final AdManager instance = AdManager._internal();
  AdManager._internal();

  String? bannerAdUnitId;
  String? interstitialAdUnitId;
  String? appOpenAdUnitId;

  InterstitialAd? _interstitialAd;
  AppOpenAd? _appOpenAd;
  bool _isAppOpenAdAvailable = false;

  Future<void> init() async {
    debugPrint('CogniVia AdManager.init() called');

    // Use Google test ad unit IDs for development
    bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Test banner ID
    interstitialAdUnitId =
        'ca-app-pub-3940256099942544/1033173712'; // Test interstitial ID
    appOpenAdUnitId =
        'ca-app-pub-3940256099942544/9257395921'; // Test App open ID

    debugPrint('CogniVia Ad Unit IDs:');
    debugPrint('Banner: $bannerAdUnitId');
    debugPrint('Interstitial: $interstitialAdUnitId');
    debugPrint('App Open: $appOpenAdUnitId');

    try {
      // Try to load from Firebase, but don't block if it fails
      final db = FirebaseDatabase.instance.ref('cognivia_admob');
      final snapshot = await db.get().timeout(const Duration(seconds: 3));
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        bannerAdUnitId = data['banner'] as String? ?? bannerAdUnitId;
        interstitialAdUnitId =
            data['interstitial'] as String? ?? interstitialAdUnitId;
        appOpenAdUnitId = data['app_open'] as String? ?? appOpenAdUnitId;
        debugPrint('CogniVia: Updated ad IDs from Firebase');
      }
    } catch (e) {
      debugPrint('CogniVia: Firebase failed, using test ad IDs: $e');
    }

    try {
      debugPrint('CogniVia: Starting ad preloading...');
      _preloadInterstitial();
      _preloadAppOpen();
      debugPrint('CogniVia: Ad preloading initiated');
    } catch (e) {
      debugPrint('CogniVia: Error during ad preloading: $e');
    }
  }

  BannerAd? createBannerAd({BannerAdListener? listener}) {
    if (bannerAdUnitId == null) return null;
    return BannerAd(
      adUnitId: bannerAdUnitId!,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: listener ?? const BannerAdListener(),
    );
  }

  void _preloadInterstitial() {
    debugPrint('CogniVia: _preloadInterstitial called');
    if (interstitialAdUnitId == null) {
      debugPrint('CogniVia: interstitialAdUnitId is null, cannot load ad');
      return;
    }
    debugPrint(
      'CogniVia: Loading interstitial ad with ID: $interstitialAdUnitId',
    );
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('CogniVia: Interstitial ad loaded successfully');
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('CogniVia: Interstitial ad failed to load: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  void _preloadAppOpen() {
    debugPrint('CogniVia: _preloadAppOpen called');
    if (appOpenAdUnitId == null) {
      debugPrint('CogniVia: appOpenAdUnitId is null, cannot load ad');
      return;
    }
    debugPrint('CogniVia: Loading app open ad with ID: $appOpenAdUnitId');
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId!,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('CogniVia: App open ad loaded successfully');
          _appOpenAd = ad;
          _isAppOpenAdAvailable = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('CogniVia: App open ad failed to load: $error');
          _appOpenAd = null;
          _isAppOpenAdAvailable = false;
        },
      ),
    );
  }

  void showInterstitialAd({
    required VoidCallback onAdClosed,
    required VoidCallback onAdFailed,
  }) {
    debugPrint('CogniVia: showInterstitialAd called');
    debugPrint('CogniVia: _interstitialAd is null: ${_interstitialAd == null}');

    if (_interstitialAd != null) {
      debugPrint('CogniVia: Showing interstitial ad...');
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('CogniVia: Interstitial ad dismissed');
          ad.dispose();
          _preloadInterstitial();
          onAdClosed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('CogniVia: Interstitial ad failed to show: $error');
          ad.dispose();
          _preloadInterstitial();
          onAdFailed();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      debugPrint(
        'CogniVia: No interstitial ad available, calling onAdFailed...',
      );
      onAdFailed();
      _preloadInterstitial();
    }
  }

  void showInterstitialBeforeNavigate(VoidCallback onNavigate) {
    debugPrint('CogniVia: showInterstitialBeforeNavigate called');
    debugPrint('CogniVia: _interstitialAd is null: ${_interstitialAd == null}');

    if (_interstitialAd != null) {
      debugPrint('CogniVia: Showing interstitial ad...');
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('CogniVia: Interstitial ad dismissed');
          ad.dispose();
          _preloadInterstitial();
          onNavigate();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('CogniVia: Interstitial ad failed to show: $error');
          ad.dispose();
          _preloadInterstitial();
          onNavigate();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      debugPrint(
        'CogniVia: No interstitial ad available, navigating directly...',
      );
      onNavigate();
      _preloadInterstitial();
    }
  }

  void showAppOpenIfAvailable(VoidCallback onContinue) {
    debugPrint('CogniVia: showAppOpenIfAvailable called');
    if (_isAppOpenAdAvailable && _appOpenAd != null) {
      debugPrint('CogniVia: Showing app open ad...');
      _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('CogniVia: App open ad dismissed');
          ad.dispose();
          _isAppOpenAdAvailable = false;
          _preloadAppOpen();
          onContinue();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('CogniVia: App open ad failed to show: $error');
          ad.dispose();
          _isAppOpenAdAvailable = false;
          _preloadAppOpen();
          onContinue();
        },
      );
      _appOpenAd!.show();
      _appOpenAd = null;
      _isAppOpenAdAvailable = false;
    } else {
      debugPrint('CogniVia: No app open ad available, continuing...');
      onContinue();
      _preloadAppOpen();
    }
  }

  // Additional method for showing rewarded ads (for premium features)
  void showRewardedAd(Function(int rewardAmount) onRewarded) {
    debugPrint('CogniVia: Rewarded ads feature coming soon!');
    // Implementation for rewarded ads can be added here
  }

  // Method for native ads (for in-content placement)
  Widget? createNativeAd() {
    debugPrint('CogniVia: Native ads feature coming soon!');
    // Implementation for native ads can be added here
    return null;
  }
}
