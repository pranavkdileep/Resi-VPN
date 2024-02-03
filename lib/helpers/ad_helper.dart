import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../controllers/native_ad_controller.dart';
import 'config.dart';
import 'my_dialogs.dart';
import 'package:applovin_max/applovin_max.dart';

class AdHelper {
  static String get className => "MyClassName";
  // for initializing ads sdk
  static Future<void> initAds() async {
    await MobileAds.instance.initialize();
    MaxConfiguration? sdkConfiguration = await AppLovinMAX.initialize('2Uh4sB1VpcPP0e9t9IRv9PF404UZ0tK0wOJflaUfzkHnd05m6t01JXXs28DK1h68R1hFU5bVelNOxFpBvabASN');
  }

  static InterstitialAd? _interstitialAd;
  static bool _interstitialAdLoaded = false;

  static NativeAd? _nativeAd;
  static bool _nativeAdLoaded = false;

  //*****************Interstitial Ad******************
  static int _maxExponentialRetryCount = 6;

  static var _interstitialRetryAttempt = 0;
  static bool isReady = false;

  static void initializeInterstitialAds() {

    AppLovinMAX.setInterstitialListener(InterstitialListener(
        onAdLoadedCallback: (ad) {
            // Interstitial ad is ready to show. AppLovinMAX.isInterstitialReady(_interstitial_ad_unit_id) now returns 'true'
            print('Interstitial ad loaded from ' + ad.networkName);

            // Reset retry attempt
            _interstitialRetryAttempt = 0;
        },
        onAdLoadFailedCallback: (adUnitId, error) {
            // Interstitial ad failed to load
            // AppLovin recommends that you retry with exponentially higher delays up to a maximum delay (in this case 64 seconds)
            _interstitialRetryAttempt = _interstitialRetryAttempt + 1;

            if (_interstitialRetryAttempt > _maxExponentialRetryCount) return;
            int retryDelay = 1 << (_maxExponentialRetryCount < _interstitialRetryAttempt ? _maxExponentialRetryCount : _interstitialRetryAttempt);

            print('Interstitial ad failed to load with code ' + error.code.toString() + ' - retrying in ' + retryDelay.toString() + 's');

            Future.delayed(Duration(milliseconds: retryDelay * 1000), () {
                AppLovinMAX.loadInterstitial(Config.applovinInterstitial);
            });
        },
        onAdDisplayedCallback: (ad) {
        },
        onAdDisplayFailedCallback: (ad, error) {
        },
        onAdClickedCallback: (ad) {
        },
        onAdHiddenCallback: (ad) {
        },
    ));

    // Load the first interstitial
    AppLovinMAX.loadInterstitial(Config.applovinInterstitial);
}

  static void precacheInterstitialAd() {
    log('Precache Interstitial Ad - Id: ${Config.interstitialAd}');

    if (Config.hideAds) return;

    InterstitialAd.load(
      adUnitId: Config.interstitialAd,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          //ad listener
          ad.fullScreenContentCallback =
              FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
            _resetInterstitialAd();
            precacheInterstitialAd();
          });
          _interstitialAd = ad;
          _interstitialAdLoaded = true;
        },
        onAdFailedToLoad: (err) {
          _resetInterstitialAd();
          log('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  static void _resetInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _interstitialAdLoaded = false;
  }
  static Future<void> showapplovinInterstitialAd({required VoidCallback onComplete}) async {
    
    isReady = (await AppLovinMAX.isInterstitialReady(Config.applovinInterstitial))!;
if (isReady) {
   AppLovinMAX.showInterstitial(Config.applovinInterstitial);
}
  }

  static void showInterstitialAd({required VoidCallback onComplete}) {
    log('Interstitial Ad Id: ${Config.interstitialAd}');

    if (Config.hideAds) {
      onComplete();
      return;
    }

    if (_interstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd?.show();
      onComplete();
      return;
    }

    MyDialogs.showProgress();

    InterstitialAd.load(
      adUnitId: Config.interstitialAd,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          //ad listener
          ad.fullScreenContentCallback =
              FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
            onComplete();
            _resetInterstitialAd();
            precacheInterstitialAd();
          });
          Get.back();
          ad.show();
        },
        onAdFailedToLoad: (err) {
          Get.back();
          log('Failed to load an interstitial ad: ${err.message}');
          onComplete();
        },
      ),
    );
  }

  //*****************Native Ad******************

  static void precacheNativeAd() {
    log('Precache Native Ad - Id: ${Config.nativeAd}');

    if (Config.hideAds) return;

    // _nativeAd = NativeAd(
    //     adUnitId: Config.nativeAd,
    //     listener: NativeAdListener(
    //       onAdLoaded: (ad) {
    //         log('$NativeAd loaded.');
    //         _nativeAdLoaded = true;
    //       },
    //       onAdFailedToLoad: (ad, error) {
    //         _resetNativeAd();
    //         log('$NativeAd failed to load: $error');
    //       },
    //     ),
    //     request: const AdRequest(),
    //     // Styling
    //     nativeTemplateStyle:
    //         NativeTemplateStyle(templateType: TemplateType.small))
    //   ..load();
  }

  static void _resetNativeAd() {
    _nativeAd?.dispose();
    _nativeAd = null;
    _nativeAdLoaded = false;
  }

  static NativeAd? loadNativeAd({required NativeAdController adController}) {
    log('Native Ad Id: ${Config.nativeAd}');

    if (Config.hideAds) return null;

    // if (_nativeAdLoaded && _nativeAd != null) {
    //   adController.adLoaded.value = true;
    //   return _nativeAd;
    // }

    // return NativeAd(
    //     adUnitId: Config.nativeAd,
    //     listener: NativeAdListener(
    //       onAdLoaded: (ad) {
    //         log('$NativeAd loaded.');
    //         adController.adLoaded.value = true;
    //         _resetNativeAd();
    //         precacheNativeAd();
    //       },
    //       onAdFailedToLoad: (ad, error) {
    //         _resetNativeAd();
    //         log('$NativeAd failed to load: $error');
    //       },
    //     ),
    //     request: const AdRequest(),
    //     // Styling
    //     nativeTemplateStyle:
    //         NativeTemplateStyle(templateType: TemplateType.small))
    //   ..load();
  }

  //*****************Rewarded Ad******************

  static void showRewardedAd({required VoidCallback onComplete}) {
    log('Rewarded Ad Id: ${Config.rewardedAd}');

    if (Config.hideAds) {
      onComplete();
      return;
    }

    MyDialogs.showProgress();

    RewardedAd.load(
      adUnitId: Config.rewardedAd,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          Get.back();

          //reward listener
          ad.show(
              onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
            onComplete();
          });
        },
        onAdFailedToLoad: (err) {
          Get.back();
          log('Failed to load an interstitial ad: ${err.message}');
          // onComplete();
        },
      ),
    );
  }
}
