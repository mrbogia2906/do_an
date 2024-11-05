import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text_app/components/loading/loading_view_model.dart';
import 'package:speech_to_text_app/resources/gen/colors.gen.dart';

class ContainerWithLoading extends ConsumerWidget {
  const ContainerWithLoading({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loadingStateProvider);
    return Stack(
      children: [
        child,
        state.isLoading ? _buildLoading() : const SizedBox(),
      ],
    );
  }

  Widget _buildLoading() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.transparent,
      child: const IgnorePointer(
        ignoring: true,
        child: Center(
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ColorName.blueFF5FC1C7),
            ),
          ),
        ),
      ),
    );
  }
}
