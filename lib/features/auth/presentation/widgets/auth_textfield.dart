import 'package:flutter/material.dart';
import 'package:waves/core/common/widgets/images/user_profile_image.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({super.key, required this.textEditingController});

  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 45,
      decoration: BoxDecoration(
          color: theme.colorScheme.tertiary,
          borderRadius: const BorderRadius.all(Radius.circular(40))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
            ),
            child: ValueListenableBuilder(
              valueListenable: textEditingController,
              builder: (context, value, child) {
                return UserProfileImage(
                  key: ValueKey(textEditingController.text),
                  verticalPadding: 4,
                  fillColor: theme.colorScheme.tertiaryContainer,
                  url: value.text,
                  radius: 17,
                );
              },
            ),
          ),
          Expanded(
            child: TextField(
                controller: textEditingController,
                autofocus: true,
                decoration: InputDecoration(
                    fillColor: theme.colorScheme.tertiary,
                    border: border,
                    errorBorder: border,
                    enabledBorder: border,
                    focusedBorder: border,
                    disabledBorder: border,
                    focusedErrorBorder: border,
                    contentPadding:
                        const EdgeInsets.only(right: 15, top: 10, left: 15),
                    hintText: "Enter your username",
                    filled: true,
                    isDense: true,
                    suffixIcon: _clearIcon())),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder get border => OutlineInputBorder(
        borderRadius: BorderRadius.circular(60.0),
        borderSide: const BorderSide(
          color: Colors.transparent,
          width: 0.0,
        ),
      );

  Widget _clearIcon() {
    return ValueListenableBuilder(
      valueListenable: textEditingController,
      builder: (context, value, child) {
        return Visibility(
            visible: textEditingController.text.isNotEmpty, child: child!);
      },
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: () {
          textEditingController.clear();
        },
        icon: const Icon(
          Icons.cancel,
          size: 25,
        ),
      ),
    );
  }
}
