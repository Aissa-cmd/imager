import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:images_app/data/data_shared_preferences.dart';

typedef BannerAdFinalCallbackType = void Function(BannerAd);
typedef BannerAdOnLoadedCallbackType = void Function();
typedef InterstitialAdOnLoadedCallback = void Function(InterstitialAd);
typedef InterstitialAdOnFailedCallback = void Function();

class GoogleAdmob {
  static const String bannerAdUnitId = "ca-app-pub-3940256099942544/6300978111";
  static const String interstitialAdUnitId =
      "ca-app-pub-3940256099942544/8691691433";
  bool personalizedAds = false;
  static const int maxFailedLoadAttempts = 3;
  int _interstitialLoadAttempts = 0;

  late BannerAd bottomBannerAd;

  GoogleAdmob() {
    personalizedAds = !(DataSharedPreferences.getShowPersonalizedAds());
  }

  void createBottomBannerAd(
    BannerAdOnLoadedCallbackType onLoadedCallback,
    BannerAdFinalCallbackType finalCallback,
  ) {
    bottomBannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: bannerAdUnitId,
      listener: BannerAdListener(onAdLoaded: (ad) {
        onLoadedCallback();
      }, onAdFailedToLoad: (ad, error) {
        ad.dispose();
      }),
      request: AdRequest(
        nonPersonalizedAds: personalizedAds,
      ),
    );
    bottomBannerAd.load();
    finalCallback(bottomBannerAd);
  }

  void createInterstitialAd(
    InterstitialAdOnLoadedCallback onLoadedCallback,
    InterstitialAdOnFailedCallback onFailedCallback,
  ) {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: AdRequest(
        nonPersonalizedAds: personalizedAds,
      ),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          onLoadedCallback(ad);
          _interstitialLoadAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          _interstitialLoadAttempts += 1;
          onFailedCallback();
          if (_interstitialLoadAttempts <= maxFailedLoadAttempts) {
            createInterstitialAd(onLoadedCallback, onFailedCallback);
          }
        },
      ),
    );
  }
}
