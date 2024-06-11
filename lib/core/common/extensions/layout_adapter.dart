import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

extension LayoutAdapter on BuildContext {
  bool get isMobileSize => MediaQuery.of(this).size.width < mobileBreakPoint;

  bool get isTabletSize =>
      MediaQuery.of(this).size.width >= mobileBreakPoint &&
      MediaQuery.of(this).size.width < tabletBreakPoint;

  bool get isDesktopSize => MediaQuery.of(this).size.width >= tabletBreakPoint;

  bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;
  bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  bool get isMobile => isAndroid || isIOS;

  bool get isTablet => isMobile && isTabletSize;

  bool get isDesktopWeb => !isMobile && kIsWeb;

  bool get isWeb => kIsWeb;

  bool get isTouchScreen => isMobile || isTablet;

  double get mobileBreakPoint => 600;
  double get tabletBreakPoint => 950;
}
