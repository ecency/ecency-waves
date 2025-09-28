import 'package:flutter/material.dart';

enum DeviceSizeClass { mobile, tablet, desktop }

class ResponsiveLayoutData {
  const ResponsiveLayoutData._({
    required this.width,
    required this.deviceSize,
  });

  factory ResponsiveLayoutData.fromMediaQuery(MediaQueryData mediaQuery) {
    final width = mediaQuery.size.width;
    return ResponsiveLayoutData._(
      width: width,
      deviceSize: _resolveDeviceSize(width),
    );
  }

  const ResponsiveLayoutData.fallback()
      : width = 375,
        deviceSize = DeviceSizeClass.mobile;

  final double width;
  final DeviceSizeClass deviceSize;

  bool get isMobile => deviceSize == DeviceSizeClass.mobile;
  bool get isTablet => deviceSize == DeviceSizeClass.tablet;
  bool get isDesktop => deviceSize == DeviceSizeClass.desktop;

  double get textScaleFactor => isDesktop
      ? 1.28
      : isTablet
          ? 1.12
          : 1.0;

  double get iconScaleFactor => isDesktop
      ? 1.22
      : isTablet
          ? 1.08
          : 1.0;

  double get avatarScaleFactor => isDesktop
      ? 1.3
      : isTablet
          ? 1.15
          : 1.0;

  double get componentScaleFactor => isDesktop
      ? 1.18
      : isTablet
          ? 1.08
          : 1.0;

  double scaleComponent(double base) => base * componentScaleFactor;

  double scaleIcon(double base) => base * iconScaleFactor;

  double scaleAvatar(double base) => base * avatarScaleFactor;

  double scaleText(double base) => base * textScaleFactor;

  double value({
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop) {
      return desktop ?? tablet ?? mobile;
    }
    if (isTablet) {
      return tablet ?? mobile;
    }
    return mobile;
  }

  static DeviceSizeClass _resolveDeviceSize(double width) {
    if (width >= 1024) {
      return DeviceSizeClass.desktop;
    }
    if (width >= 600) {
      return DeviceSizeClass.tablet;
    }
    return DeviceSizeClass.mobile;
  }
}

class ResponsiveLayout extends InheritedWidget {
  const ResponsiveLayout({
    super.key,
    required this.data,
    required super.child,
  });

  final ResponsiveLayoutData data;

  static ResponsiveLayoutData of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<ResponsiveLayout>();
    if (inherited != null) {
      return inherited.data;
    }
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) {
      return const ResponsiveLayoutData.fallback();
    }
    return ResponsiveLayoutData.fromMediaQuery(mediaQuery);
  }

  @override
  bool updateShouldNotify(covariant ResponsiveLayout oldWidget) {
    return data.deviceSize != oldWidget.data.deviceSize ||
        data.width != oldWidget.data.width;
  }
}
