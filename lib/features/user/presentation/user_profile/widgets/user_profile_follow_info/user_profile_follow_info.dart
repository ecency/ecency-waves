// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:go_router/go_router.dart';
// import 'package:waves/features/user/presentation/user_profile/controller/user_profile_controller.dart';
// import 'package:waves/features/user/presentation/user_profile/widgets/user_profile_follow_info/user_profile_follow_info_list_dialog.dart';
// iimport 'package:provider/provider.dart';

// class FollowInfo extends StatelessWidget {
//   const FollowInfo({
//     super.key,
//     required this.direction,
//     required this.accountName,
//   });

//   final Axis direction;
//   final String accountName;

//   @override
//   Widget build(BuildContext context) {
//     final controller = context.read<UserProfileController>();
//     return FutureBuilder<FollowCountModel>(
//       future: controller.getFollowCount(),
//       builder: (context, snapshot) {
//         FollowCountModel? data = snapshot.data;
//         return direction == Axis.vertical
//             ? Column(
//                 children: children(data, context),
//               )
//             : Row(
//                 children: children(data, context),
//               );
//       },
//     );
//   }

//   List<Widget> children(FollowCountModel? data, BuildContext context) {
//     return [
//       TextBox(
//         onTap: () {
//           if (data != null) {
//             openDialog(context, FollowType.followers, data.followerCount);
//           }
//         },
//         showBorder: true,
//         mainAxisAlignment: MainAxisAlignment.center,
//         borderRadius: 40,
//         padding: const EdgeInsets.symmetric(
//             horizontal: kScreenHorizontalPaddingDigit, vertical: 6),
//         backgroundColor: Colors.transparent,
//         text: "Followers - ${data?.followerCount ?? 0}",
//       ),
//       const Gap(10),
//       TextBox(
//         onTap: () {
//           if (data != null) {
//             openDialog(context, FollowType.following, data.followingCount);
//           }
//         },
//         showBorder: true,
//         mainAxisAlignment: MainAxisAlignment.center,
//         borderRadius: 40,
//         padding: const EdgeInsets.symmetric(
//             horizontal: kScreenHorizontalPaddingDigit, vertical: 6),
//         backgroundColor: Colors.transparent,
//         text: "Following - ${data?.followingCount ?? 0}",
//       ),
//       const Padding(
//         padding: EdgeInsets.symmetric(vertical: 15),
//         child: Divider(),
//       ),
//     ];
//   }

//   void openDialog(BuildContext context, FollowType type, int? count) {
//     if (context.isMobile) {
//       context.pushNamed(
//         Routes.userFollowInfoListView,
//         extra: UserFollowInfoListNavigationModel(
//             type: type,
//             accountName: accountName,
//             removeScaffold: false,
//             count: count ?? 0),
//       );
//     } else {
//       showDialog(
//         barrierDismissible: true,
//         context: context,
//         builder: (context) {
//           return UserProfileFollowInfoListDialog(
//             accountName: accountName,
//             type: type,
//             count: count ?? 0,
//           );
//         },
//       );
//     }
//   }
// }
