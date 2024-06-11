import 'package:flutter/material.dart';
import 'package:waves/core/utilities/enum.dart';

abstract class ControllerInterface<T> extends ChangeNotifier {
  List<T> items = [];
  ViewState viewState = ViewState.loading;

  @protected
  void init();

  void loadNextPage();

  void refresh();
}
