import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:waves/core/common/extensions/layout_adapter.dart';

extension PlatformNavigation on BuildContext {
  void platformPop({String? name}) {
    if (isWeb && name == null) {
      throw Exception('name is required for web platform');
    }
    if (canPop()) {
      pop();
    } else {
      goNamed(name!);
    }
  }

  void popAndPlatformPushNamed(String name) {
    pop();
    platformPushNamed(name);
  }

  void platformPushNamed(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) =>
      isMobile
          ? GoRouter.of(this).pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            )
          : GoRouter.of(this).goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );
}
