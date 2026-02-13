import 'package:provider/single_child_widget.dart';

/// ViewModel Provider
/// 라우트별로 ChangeNotifierProvider를 생성하므로 여기서는 빈 리스트 반환
/// (router.dart에서 각 화면 진입 시 ViewModel을 생성)
List<SingleChildWidget> buildViewModelProviders() {
  return [];
}
