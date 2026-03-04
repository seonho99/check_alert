import 'package:flutter/foundation.dart';
import '../../core/services/app_open_ad_service.dart';
import '../../domain/repository/auth_repository.dart';

class SplashViewModel extends ChangeNotifier {
  final AppOpenAdService _appOpenAdService;
  final AuthRepository _authRepository;

  bool _isLoading = true;
  bool _isAuthenticated = false;
  bool _hasNavigated = false;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get hasNavigated => _hasNavigated;

  SplashViewModel({
    required AppOpenAdService appOpenAdService,
    required AuthRepository authRepository,
  })  : _appOpenAdService = appOpenAdService,
        _authRepository = authRepository {
    // 생성 즉시 광고 미리 로드
    _appOpenAdService.loadAd();
  }

  Future<void> initializeApp() async {
    try {
      // 스플래시 최소 노출 시간
      await Future.delayed(const Duration(seconds: 2));

      _isAuthenticated = _authRepository.currentUserId != null;
    } catch (e) {
      debugPrint('[SplashViewModel] 초기화 오류: $e');
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> showAd() async {
    try {
      return await _appOpenAdService.showAdIfAvailable();
    } catch (e) {
      debugPrint('[SplashViewModel] 광고 표시 오류: $e');
      return false;
    }
  }

  void setNavigated() {
    _hasNavigated = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _appOpenAdService.dispose();
    super.dispose();
  }
}
