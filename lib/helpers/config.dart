import 'dart:developer';

class Config {
  // Static default values
  static const _defaultValues = {
    "interstitial_ad": "ca-app-pub-3940256099942544/1033173712",
    "native_ad": "ca-app-pub-3940256099942544/2247696110",
    "rewarded_ad": "ca-app-pub-3940256099942544/5224354917",
    "applovin_interstitial": "88d99c231ac16c91",
    "show_ads": true
  };

  // Getters for default values
  static dynamic get nativeAd => _defaultValues['native_ad'];
  static dynamic get interstitialAd => _defaultValues['interstitial_ad'];
  static dynamic get rewardedAd => _defaultValues['rewarded_ad'];
  static bool get hideAds => _defaultValues['show_ads'] as bool;
  static dynamic get applovinInterstitial => _defaultValues['applovin_interstitial'];
}
