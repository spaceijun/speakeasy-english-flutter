import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  // Test Ad Unit IDs (ganti dengan ID asli untuk production)
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test Banner Android
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test Banner iOS
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test Interstitial Android
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test Interstitial iOS
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test Rewarded Android
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test Rewarded iOS
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}

// Widget Banner Ad yang bisa digunakan di mana saja
class BannerAdWidget extends StatefulWidget {
  final AdSize adSize;

  const BannerAdWidget({Key? key, this.adSize = AdSize.banner})
    : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      request: const AdRequest(),
      size: widget.adSize,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Banner ad loaded.');
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('Banner ad failed to load: $err');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd != null && _isLoaded) {
      return Container(
        alignment: Alignment.center,
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    } else {
      return const SizedBox(
        height: 50,
        child: Center(child: Text('Loading ad...')),
      );
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}

// Manager untuk Interstitial Ad
class InterstitialAdManager {
  InterstitialAd? _interstitialAd;
  bool _isLoaded = false;

  void loadAd() {
    InterstitialAd.load(
      adUnitId: AdManager.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          debugPrint('Interstitial ad loaded.');
          _interstitialAd = ad;
          _isLoaded = true;

          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('Interstitial ad failed to load: $error');
          _isLoaded = false;
        },
      ),
    );
  }

  void showAd({VoidCallback? onAdClosed}) {
    if (_isLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent:
            (InterstitialAd ad) =>
                debugPrint('Interstitial ad showed fullscreen content.'),
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          debugPrint('Interstitial ad dismissed fullscreen content.');
          ad.dispose();
          onAdClosed?.call();
          loadAd(); // Load iklan berikutnya
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          debugPrint(
            'Interstitial ad failed to show fullscreen content: $error',
          );
          ad.dispose();
          loadAd(); // Load iklan berikutnya
        },
      );

      _interstitialAd!.show();
      _interstitialAd = null;
      _isLoaded = false;
    } else {
      debugPrint('Interstitial ad is not ready yet.');
    }
  }

  bool get isLoaded => _isLoaded;

  void dispose() {
    _interstitialAd?.dispose();
  }
}

// Manager untuk Rewarded Ad
class RewardedAdManager {
  RewardedAd? _rewardedAd;
  bool _isLoaded = false;

  void loadAd() {
    RewardedAd.load(
      adUnitId: AdManager.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint('Rewarded ad loaded.');
          _rewardedAd = ad;
          _isLoaded = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('Rewarded ad failed to load: $error');
          _isLoaded = false;
        },
      ),
    );
  }

  void showAd({
    required void Function(AdWithoutView, RewardItem) onUserEarnedReward,
    VoidCallback? onAdClosed,
  }) {
    if (_isLoaded && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent:
            (RewardedAd ad) =>
                debugPrint('Rewarded ad showed fullscreen content.'),
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          debugPrint('Rewarded ad dismissed fullscreen content.');
          ad.dispose();
          onAdClosed?.call();
          loadAd(); // Load iklan berikutnya
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          debugPrint('Rewarded ad failed to show fullscreen content: $error');
          ad.dispose();
          loadAd(); // Load iklan berikutnya
        },
      );

      _rewardedAd!.setImmersiveMode(true);
      _rewardedAd!.show(onUserEarnedReward: onUserEarnedReward);
      _rewardedAd = null;
      _isLoaded = false;
    } else {
      debugPrint('Rewarded ad is not ready yet.');
    }
  }

  bool get isLoaded => _isLoaded;

  void dispose() {
    _rewardedAd?.dispose();
  }
}
