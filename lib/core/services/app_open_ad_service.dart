import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppOpenAdService {
  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  bool _isAdLoaded = false;

  String get _adUnitId {
    if (Platform.isAndroid) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/9257395921'
          : 'ca-app-pub-5926712271716610/2606023868';
    } else if (Platform.isIOS) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/5575463023'
          : 'ca-app-pub-5926712271716610/2634419387';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  bool get isAdLoaded => _isAdLoaded;

  Future<void> loadAd() async {
    if (_isAdLoaded && _appOpenAd != null) return;

    final completer = Completer<void>();

    try {
      await AppOpenAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _appOpenAd = ad;
            _isAdLoaded = true;
            debugPrint('[AppOpenAd] 로드 성공');
            if (!completer.isCompleted) completer.complete();
          },
          onAdFailedToLoad: (error) {
            _isAdLoaded = false;
            debugPrint('[AppOpenAd] 로드 실패: $error');
            if (!completer.isCompleted) completer.complete();
          },
        ),
      );
    } catch (e) {
      _isAdLoaded = false;
      debugPrint('[AppOpenAd] 로드 중 오류: $e');
      if (!completer.isCompleted) completer.complete();
    }

    return completer.future;
  }

  Future<bool> showAdIfAvailable() async {
    if (_isShowingAd) return false;
    if (!_isAdLoaded || _appOpenAd == null) return false;

    _isShowingAd = true;
    final completer = Completer<bool>();

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[AppOpenAd] 광고 표시됨');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AppOpenAd] 표시 실패: $error');
        _isShowingAd = false;
        _isAdLoaded = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd();
        if (!completer.isCompleted) completer.complete(false);
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AppOpenAd] 광고 닫힘');
        _isShowingAd = false;
        _isAdLoaded = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd();
        if (!completer.isCompleted) completer.complete(true);
      },
    );

    await _appOpenAd!.show();
    return completer.future;
  }

  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _isAdLoaded = false;
    _isShowingAd = false;
  }
}
