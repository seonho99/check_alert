import 'dart:io';
import 'package:flutter/foundation.dart';

class BannerAdService {
  String get adUnitId {
    if (Platform.isAndroid) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-5926712271716610/9414974794';
    } else if (Platform.isIOS) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/2934735716'
          : 'ca-app-pub-5926712271716610/8920626134';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
