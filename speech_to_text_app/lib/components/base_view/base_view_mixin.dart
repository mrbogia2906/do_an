import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text_app/resources/gen/colors.gen.dart';

mixin BaseViewMixin {
  bool get resizeToAvoidBottomInset => false;

  bool get tapOutsideToDismissKeyBoard => false;

  bool get extendBodyBehindAppBar => false;

  Color? get backgroundColor => ColorName.white;

  bool get ignoreSafeAreaTop => true;

  bool get ignoreSafeAreaBottom => true;

  String get screenName;

  bool get canPop => true;

  Widget buildBody(BuildContext context);

  PreferredSizeWidget? buildAppBar(BuildContext context);

  Widget? buildBottomNavigatorBar(BuildContext context) => null;

  Widget? buildBottomSheet(BuildContext context) => null;

  Widget buildView(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: buildAppBar(context),
      body: SafeArea(
        top: ignoreSafeAreaTop,
        bottom: ignoreSafeAreaBottom,
        child: PopScope(
          canPop: canPop,
          onPopInvoked: onPopInvoked,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (tapOutsideToDismissKeyBoard) {
                dismissKeyBoard(context);
              }
            },
            child: tapOutsideToDismissKeyBoard
                ? SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: buildBody(context),
                  )
                : buildBody(context),
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigatorBar(context),
      bottomSheet: buildBottomSheet(context),
    );
  }

  void dismissKeyBoard(BuildContext context) {
    if (FocusScope.of(context).hasFocus) {
      FocusScope.of(context).unfocus();
    } else {
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }

  void onPopInvoked(bool didPop) {}
}
