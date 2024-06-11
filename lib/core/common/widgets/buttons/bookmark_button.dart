import 'package:flutter/material.dart';
import 'package:waves/core/common/extensions/ui.dart';
import 'package:waves/core/common/widgets/icon_with_text.dart';
import 'package:waves/core/locales/locale_text.dart';

class BookmarkButton extends StatefulWidget {
  const BookmarkButton(
      {super.key,
      required this.isBookmarked,
      required this.onAdd,
      required this.onRemove,
      this.iconColor,
      required this.toastType,
      this.borderRadius});

  final Future<bool> isBookmarked;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final Color? iconColor;
  final String toastType;
  final BorderRadius? borderRadius;

  @override
  State<BookmarkButton> createState() => _FavouriteWidgetState();
}

class _FavouriteWidgetState extends State<BookmarkButton> {
  bool isBookmarked = false;
  @override
  void initState() {
    setBookmarkValue();
    super.initState();
  }

  Future<void> setBookmarkValue() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      isBookmarked = await widget.isBookmarked;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didUpdateWidget(covariant BookmarkButton oldWidget) {
    setBookmarkValue();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconWithText(
      onTap: () {
        if (isBookmarked) {
          widget.onRemove();
          setState(() {
            isBookmarked = false;
          });
          showSnackBar(false, theme);
        } else {
          widget.onAdd();
          setState(() {
            isBookmarked = true;
          });
          showSnackBar(true, theme);
        }
      },
      borderRadius: widget.borderRadius,
      icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
      iconColor: widget.iconColor,
    );
  }

  void showSnackBar(bool isAdding, ThemeData theme) {
    if(isAdding){
      context.showSnackBar(LocaleText.isAddedToYourBookmarks(widget.toastType));
    }else{
      context.showSnackBar(LocaleText.isRemovedToYourBookmarks(widget.toastType));
    }
  }
}
