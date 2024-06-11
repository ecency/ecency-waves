import 'package:waves/core/models/action_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

mixin PaginationMixin {
  int pageLimit = 20;
  bool isPageEnded = false;
  bool isNextPageLoading = false;

  @protected
  Future<ActionListDataResponse<T>?> loadMore<T>(
      {required Future<ActionListDataResponse<T>> Function() apiCall,
      required VoidCallback notifyListeners}) async {
    if (!isPageEnded && !isNextPageLoading) {
      isNextPageLoading = true;
      notifyListeners();
      ActionListDataResponse<T> response = await apiCall();
      if (response.isSuccess) {
        if (response.data!.length < pageLimit) {
          isPageEnded = true;
        }
      }
      isNextPageLoading = false;
      notifyListeners();
      return response;
    }
    return null;
  }
}
