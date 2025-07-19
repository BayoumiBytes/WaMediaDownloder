import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdManager {
  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;
  int _downloadCount = 0;
  int _adShowCount = 0;

  // Test ad unit IDs (replace with your real IDs for production)
  final String _adUnitId = 'ca-app-pub-3940256099942544/1033173712'; // test api
  // final String _adUnitId = 'ca-app-pub-1124767398147895/5638697224';

  // Singleton pattern
  static final InterstitialAdManager _instance =
      InterstitialAdManager._internal();
  factory InterstitialAdManager() => _instance;
  InterstitialAdManager._internal();

  // Initialize and load the first ad
  void initialize() {
    loadInterstitialAd();
  }

  // Load interstitial ad
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          debugPrint('Interstitial ad loaded successfully');
          _interstitialAd = ad;
          _isAdLoaded = true;
          _setFullScreenContentCallback();
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('Interstitial ad failed to load: $error');
          _interstitialAd = null;
          _isAdLoaded = false;
          // Retry loading after a delay
          Future.delayed(Duration(seconds: 30), () {
            loadInterstitialAd();
          });
        },
      ),
    );
  }

  // Set up ad event callbacks
  void _setFullScreenContentCallback() {
    if (_interstitialAd == null) return;

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        print('Interstitial ad showed full screen content');
        _adShowCount++;
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('Interstitial ad dismissed');
        ad.dispose();
        _interstitialAd = null;
        _isAdLoaded = false;

        // Load next ad immediately
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('Interstitial ad failed to show: $error');
        ad.dispose();
        _interstitialAd = null;
        _isAdLoaded = false;

        // Load next ad
        loadInterstitialAd();
      },
      onAdImpression: (InterstitialAd ad) {
        print('Interstitial ad impression recorded');
      },
      onAdClicked: (InterstitialAd ad) {
        print('Interstitial ad clicked');
      },
    );
  }

  // Show interstitial ad
  void showInterstitialAd({VoidCallback? onAdClosed}) {
    if (_interstitialAd != null && _isAdLoaded) {
      // Add custom callback for when ad is closed
      if (onAdClosed != null) {
        final originalCallback = _interstitialAd!.fullScreenContentCallback;
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent:
              originalCallback?.onAdShowedFullScreenContent,
          onAdDismissedFullScreenContent: (InterstitialAd ad) {
            originalCallback?.onAdDismissedFullScreenContent?.call(ad);
            onAdClosed();
          },
          onAdFailedToShowFullScreenContent:
              originalCallback?.onAdFailedToShowFullScreenContent,
          onAdImpression: originalCallback?.onAdImpression,
          onAdClicked: originalCallback?.onAdClicked,
        );
      }

      _interstitialAd!.show();
    } else {
      print('Interstitial ad not ready to show');
      // If ad is not loaded, call the callback immediately
      onAdClosed?.call();
    }
  }

  // Smart ad showing based on download count
  void onDownloadStarted({VoidCallback? onAdClosed}) {
    _downloadCount++;
    print(_downloadCount);
    // Show ad after every 3 downloads
    if (_downloadCount % 3 == 0) {
      showInterstitialAd();
    }
  }

  // Show ad with delay (for better UX)
  void showInterstitialAfterDelay({
    Duration delay = const Duration(seconds: 1),
    VoidCallback? onAdClosed,
  }) {
    Future.delayed(delay, () {
      showInterstitialAd(onAdClosed: onAdClosed);
    });
  }

  // Check if ad is ready
  bool isAdReady() {
    return _interstitialAd != null && _isAdLoaded;
  }

  // Get ad statistics
  Map<String, int> getAdStats() {
    return {'downloadCount': _downloadCount, 'adShowCount': _adShowCount};
  }

  // Force show ad (for testing)
  void forceShowAd({VoidCallback? onAdClosed}) {
    showInterstitialAd(onAdClosed: onAdClosed);
  }

  // Dispose resources
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
  }
}
