// ignore_for_file: avoid_shadowing_type_parameters

import 'package:get_storage/get_storage.dart';
import 'package:localstore/localstore.dart';
import 'package:waves/core/dependency_injection/dependency_injection.dart';
import 'package:waves/core/utilities/enum.dart';
import 'package:waves/features/threads/models/thread_feeds/thread_bookmark_model.dart';

class BookmarkProvider<T> {
  final db = Localstore.instance;
  final BookmarkType type;
  late final String key;

  BookmarkProvider({required this.type}) {
    key = enumToString(type);
  }

  final storage = getIt<GetStorage>();

  Future<List<T>> getBookmarks<T>() async {
    final map = await db.collection(key).get();
    if (map != null && map.isNotEmpty) {
      List<T> items = [];
      map.forEach((key, value) {
        items.add(fromJson(value));
      });
      return items;
    }
    return [];
  }

  // List<T> getBookmarks(T Function(Map<String, dynamic>) fromJson) {
  //   if (storage.read(key) != null) {
  //     List json = storage.read(key);
  //     List<T> items = json.map((e) => fromJson(e)).toList();
  //     return items;
  //   } else {
  //     return [];
  //   }
  // }

  // bool isBookmarkPresent(String id, String idKey) {
  //   if (storage.read(key) != null) {
  //     List json = storage.read(key);
  //     int index = json.indexWhere((element) => id == element[idKey]);
  //     return index != -1;
  //   } else {
  //     return false;
  //   }
  // }

  Future<bool> isBookmarkPresent(
    String id,
  ) async {
    final map = await db.collection(key).doc(id).get();
    return map != null && map.isNotEmpty;
  }

  Future<void> addBookmark(String id, dynamic item) async {
    await db.collection(key).doc(id).set(toJson(item));
  }

  Future<void> removeBookmark(
    String id,
  ) async {
    await db.collection(key).doc(id).delete();
  }

  void addRemoveBookmark(String id, String idKey, Map<String, dynamic> json,
      {bool forceRemove = false}) {
    if (storage.read(key) != null) {
      List json = storage.read(key);
      int index = json.indexWhere((element) => id == element[idKey]);
      if (index == -1 && !forceRemove) {
        json.add(json);
        storage.write(key, json);
      } else {
        json.removeWhere((element) => id == element[idKey]);
        storage.write(key, json);
      }
    } else {
      storage.write(key, [json]);
    }
  }

  dynamic fromJson(Map<String, dynamic> json) {
    if (type == BookmarkType.thread) {
      return ThreadBookmarkModel.fromJson(json);
    } else {
      throw UnimplementedError();
    }
  }

  Map<String, dynamic> toJson(dynamic item) {
    if (type == BookmarkType.thread) {
      return ThreadBookmarkModel.toJson(item);
    }
    throw UnimplementedError();
  }
}
