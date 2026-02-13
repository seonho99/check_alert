import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions: $defaultTargetPlatform는 지원하지 않습니다.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAMCcL1jpoHks8YIwwqCTkZMzjJKD719Ew',
    appId: '1:92105577038:android:7b036854408bc2a874a91f',
    messagingSenderId: '92105577038',
    projectId: 'check-alert',
    storageBucket: 'check-alert.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyANxVGbvFivxuzBiiTtrWhEZkOaOwhC8bk',
    appId: '1:92105577038:ios:0a4718a66c5f73fa74a91f',
    messagingSenderId: '92105577038',
    projectId: 'check-alert',
    storageBucket: 'check-alert.firebasestorage.app',
    iosBundleId: 'com.checkalert.checkAlert',
  );
}
