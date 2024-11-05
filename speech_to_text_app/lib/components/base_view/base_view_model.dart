import 'package:flutter_riverpod/flutter_riverpod.dart';

class BaseViewModel<T> extends StateNotifier<T> {
  BaseViewModel(super.state);
}
