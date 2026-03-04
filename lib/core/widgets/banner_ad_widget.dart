import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../services/banner_ad_service.dart';

class _BannerAdViewModel extends ChangeNotifier {
  final BannerAdService _service;
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  BannerAd? get bannerAd => _bannerAd;
  bool get isAdLoaded => _isAdLoaded;

  _BannerAdViewModel(this._service) {
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: _service.adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          _isAdLoaded = false;
          ad.dispose();
          _bannerAd = null;
          notifyListeners();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}

class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => _BannerAdViewModel(ctx.read<BannerAdService>()),
      child: Consumer<_BannerAdViewModel>(
        builder: (context, viewModel, _) {
          if (!viewModel.isAdLoaded || viewModel.bannerAd == null) {
            return const SizedBox.shrink();
          }

          return SafeArea(
            top: false,
            child: Container(
              alignment: Alignment.center,
              width: viewModel.bannerAd!.size.width.toDouble(),
              height: viewModel.bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: viewModel.bannerAd!),
            ),
          );
        },
      ),
    );
  }
}
