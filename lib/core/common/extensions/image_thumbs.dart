import 'package:flutter/material.dart';

extension ImageThumb on BuildContext {
  String userOwnerThumb(String value, {String size = 'small'}) {
    return "https://images.ecency.com/u/$value/avatar/$size";
  }

  String resizedImage(String value, {int? width, int? height}) {
    return "https://images.ecency.com/${width ?? 320}x${height ?? 160}/$value";
  }

  String proxyImage(String value) {
    return "https://images.ecency.com/1000x0/$value";
  }
}
