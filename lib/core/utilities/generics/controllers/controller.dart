import 'package:flutter/material.dart';
import 'package:waves/core/models/action_response.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/core/utilities/generics/controllers/controller_interface.dart';
import 'package:waves/core/utilities/generics/mixins/pagination_mixin.dart';

class Controller<T> extends ChangeNotifier
    with PaginationMixin
    implements ControllerInterface<T> {
  @override
  List<T> items = [];
  @override
  ViewState viewState = ViewState.loading;
  bool reverseData = false;

  Future<ActionListDataResponse<T>> Function()? initCallBack;
  Future<ActionListDataResponse<T>> Function()? paginationCallBack;

  @override
  @protected
  void init() async {
    if (initCallBack == null) throw UnimplementedError('init api is not set');
    ActionListDataResponse<T> response = await initCallBack!();
    if (response.isSuccess) {
      if (response.data!.isNotEmpty) {
        if (!reverseData) {
          items = response.data!;
        } else {
          items = response.data!.reversed.toList();
        }

        viewState = ViewState.data;
        if (items.length < super.pageLimit) {
          super.isPageEnded = true;
        }
      } else {
        viewState = ViewState.empty;
      }
    } else {
      viewState = ViewState.error;
    }
    notifyListeners();
  }

  @required
  @protected
  void setInitApi(Future<ActionListDataResponse<T>> Function() initApi) {
    initCallBack = initApi;
  }

  @required
  @protected
  void setPaginationApi(
      Future<ActionListDataResponse<T>> Function() paginationApi) {
    paginationCallBack = paginationApi;
  }

  @override
  void loadNextPage() async {
    if (paginationCallBack == null) {
      throw UnimplementedError('Pagination Api is not set');
    }
    if (viewState == ViewState.data) {
      ActionListDataResponse<T>? newData = await loadMore<T>(
          apiCall: () => paginationCallBack!(),
          notifyListeners: notifyListeners);
      if (newData != null) {
        if (newData.isSuccess) {
          addItems(newData.data!);
        }
      }
    }
  }

  @override
  void refresh() {
    viewState = ViewState.loading;
    initCallBack!();
  }

  @protected
  void addItems(List<T> newItems) {
    if (!reverseData) {
      items = [...items, ...newItems];
    } else {
      items = [...items, ...newItems.reversed];
    }
    items = items.toSet().toList();
    notifyListeners();
  }
}
