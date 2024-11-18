import 'package:speech_to_text_app/screen/splash/splash_state.dart';

import '../../../components/base_view/base_view_model.dart';

class SplashViewModel extends BaseViewModel<SplashState> {
  SplashViewModel() : super(SplashState());

  void updateNavigated(bool navigated) {
    state = state.copyWith(navigated: navigated);
  }
}
