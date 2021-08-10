import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../db/mixin_database.dart';
import '../../generated/r.dart';
import '../../service/env.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import 'address_selection_widget.dart';
import 'avatar.dart';
import 'mixin_bottom_sheet.dart';
import 'search_header_widget.dart';

Future<User?> showContactSelectionBottomSheet({
  required BuildContext context,
  User? selectedUser,
}) =>
    showMixinBottomSheet<User>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ContactSelectionBottomSheet(
        selectedUser: selectedUser,
      ),
    );

class _ContactSelectionBottomSheet extends HookWidget {
  const _ContactSelectionBottomSheet({
    Key? key,
    required this.selectedUser,
  }) : super(key: key);

  final User? selectedUser;

  @override
  Widget build(BuildContext context) {
    final friends =
        useMemoizedStream(() => context.appServices.friends().watch()).data ??
            const [];

    final updateResult =
        useMemoizedFuture(() => context.appServices.updateFriends());

    final filterKeywords = useState('');
    final filterList = useMemoized(() {
      if (filterKeywords.value.isEmpty) {
        return friends;
      }
      return friends
          .where((e) =>
              e.identityNumber.containsIgnoreCase(filterKeywords.value) ||
              (e.fullName?.containsIgnoreCase(filterKeywords.value) == true))
          .toList();
    }, [filterKeywords.value, friends]);

    final Widget body;
    if (updateResult.hasError) {
      body = const _UnauthorizedWidget();
    } else {
      body = ListView.builder(
        itemCount: filterList.length,
        itemBuilder: (BuildContext context, int index) => _UserItem(
          user: filterList[index],
          selectedUserId: selectedUser?.userId,
        ),
      );
    }
    return SizedBox(
      height: MediaQuery.of(context).size.height - 100,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              const SizedBox(width: 20),
              Expanded(
                child: SearchHeaderWidget(
                  hintText: context.l10n.contactSearchHint,
                  onChanged: (k) {
                    filterKeywords.value = k.trim();
                  },
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _UserItem extends StatelessWidget {
  const _UserItem({
    Key? key,
    required this.selectedUserId,
    required this.user,
  }) : super(key: key);

  final String? selectedUserId;
  final User user;

  @override
  Widget build(BuildContext context) => AddressSelectionItemTile(
        onTap: () => Navigator.pop(context, user),
        title: Text(user.fullName?.overflow ?? ''),
        subtitle: Text(user.identityNumber),
        selected: user.userId == selectedUserId,
        leading: Avatar(
            size: 44,
            borderWidth: 0,
            avatarUrl: user.avatarUrl,
            userId: user.userId,
            name: user.fullName ?? '?'),
      );
}

class _UnauthorizedWidget extends StatelessWidget {
  const _UnauthorizedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              R.resourcesUnauthorizedContactSvg,
              width: 58,
              height: 58,
            ),
            const SizedBox(height: 26),
            Text(
              context.l10n.contactReadFailed,
              style: TextStyle(
                color: context.theme.text,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () {
                final uri = Uri.https('mixin.one', 'oauth/authorize', {
                  'client_id': Env.clientId,
                  'scope':
                      'PROFILE:READ+ASSETS:READ+CONTACTS:READ+SNAPSHOTS:READ',
                  'response_type': 'code',
                });
                context.toExternal(uri);
              },
              child: Text(
                context.l10n.reauthorize,
                style: const TextStyle(
                  color: Color(0xff3D75E3),
                  fontSize: 14,
                ),
              ),
            )
          ],
        ),
      );
}
