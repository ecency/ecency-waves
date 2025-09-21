import 'package:flutter/material.dart';
import 'package:waves/core/locales/locale_text.dart';
import 'package:waves/features/bookmarks/views/thread_bookmark/thread_bookmark_widget.dart';

class BookmarksView extends StatelessWidget {
  const BookmarksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleText.bookmarks),
      ),
      body: const SafeArea(child: ThreadBookmarkWidget()),
    );
  }
}
