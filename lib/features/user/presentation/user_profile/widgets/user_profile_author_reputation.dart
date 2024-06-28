import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waves/features/user/presentation/user_profile/controller/user_profile_controller.dart';

class UserProfileAuthorReputation extends StatelessWidget {
  const UserProfileAuthorReputation({super.key, this.isFilled = true});

  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.read<UserProfileController>();
    return SizedBox();
    // FutureBuilder<int>(
    //   future: controller.getUserReputation(),
    //   builder: (context, snapshot) {
    //     if (snapshot.hasData &&
    //         snapshot.connectionState == ConnectionState.done) {
    //       return Tooltip(
    //         message: "Author's Reputation",
    //         child: Container(
    //             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    //             decoration: BoxDecoration(
    //                 color: isFilled ? theme.primaryColor : null,
    //                 border: Border.all(color: isFilled ? theme.primaryColorLight : theme.primaryColor, width: 2),
    //                 borderRadius: const BorderRadius.all(Radius.circular(40))),
    //             child: Text(
    //               snapshot.data.toString(),
    //               style: theme.textTheme.bodyMedium!
    //                   .copyWith(color:isFilled ? theme.colorScheme.onPrimary : null),
    //             )),
    //       );
    //     } else {
    //       return const SizedBox.shrink();
    //     }
    //   },
    // );
  }
}
