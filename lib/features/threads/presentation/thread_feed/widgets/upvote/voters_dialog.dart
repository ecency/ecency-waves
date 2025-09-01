import 'package:flutter/material.dart';
import 'package:waves/core/common/widgets/images/user_profile_image.dart';
import 'package:waves/features/threads/models/post_detail/upvote_model.dart';

class VotersDialog extends StatelessWidget {
  const VotersDialog({super.key, required this.voters});

  final List<ActiveVoteModel> voters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiary,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _appBar(context),
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: voters.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final voter = voters[index];
                    return ListTile(
                      leading: UserProfileImage(
                        url: voter.voter,
                        radius: 20,
                      ),
                      title: Text('@${voter.voter}'),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: theme.colorScheme.tertiary,
      automaticallyImplyLeading: false,
      title: Text(
        'Voters',
        style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      actions: [
        IconButton(
          splashRadius: 30,
          icon: const Icon(
            Icons.cancel,
            size: 28,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
