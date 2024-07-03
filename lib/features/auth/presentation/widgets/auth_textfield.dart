import 'package:flutter/material.dart';
import 'package:waves/core/common/widgets/images/user_profile_image.dart';

class AuthTextField extends StatefulWidget {
  const AuthTextField(
      {super.key,
      required this.textEditingController,
      this.leading,
      this.isPassword = false,
      required this.hintText});

  final TextEditingController textEditingController;
  final Widget? leading;
  final bool isPassword;
  final String hintText;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool isPassword;

  @override
  void initState() {
    isPassword = widget.isPassword;
    super.initState();
  }

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
            child: widget.leading ??
                ValueListenableBuilder(
                  valueListenable: widget.textEditingController,
                  builder: (context, value, child) {
                    return UserProfileImage(
                      key: ValueKey(widget.textEditingController.text),
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
                obscureText: isPassword,
                controller: widget.textEditingController,
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
                  hintText: widget.hintText,
                  filled: true,
                  isDense: true,
                  suffixIcon: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _eyeVisibilityIcon(theme),
                      _clearIcon(),
                    ],
                  ),
                )),
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
      valueListenable: widget.textEditingController,
      builder: (context, value, child) {
        return Visibility(
            visible: widget.textEditingController.text.isNotEmpty,
            child: child!);
      },
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        visualDensity: VisualDensity.compact,
        onPressed: () {
          widget.textEditingController.clear();
        },
        icon: const Icon(
          Icons.cancel,
          size: 25,
        ),
      ),
    );
  }

  Widget _eyeVisibilityIcon(ThemeData theme) {
    return Visibility(
      visible: widget.isPassword,
      child: IconButton(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(),
        onPressed: () {
          setState(() {
            isPassword = !isPassword;
          });
        },
        icon: Icon(
          isPassword ? Icons.visibility : Icons.visibility_off,
        ),
      ),
    );
  }
}
