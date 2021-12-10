import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../db/mixin_database.dart';
import '../../../generated/r.dart';
import '../../../service/env.dart';
import '../../../util/extension/extension.dart';
import '../../../util/hook.dart';
import '../avatar.dart';
import '../search_header_widget.dart';

class ContactSelectionBottomSheet extends HookWidget {
  const ContactSelectionBottomSheet({
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
    return Column(
      children: [
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
  Widget build(BuildContext context) => _ContactSelectionItemTile(
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

class _ContactSelectionItemTile extends StatelessWidget {
  const _ContactSelectionItemTile({
    Key? key,
    required this.leading,
    required this.onTap,
    required this.title,
    required this.subtitle,
    required this.selected,
  }) : super(key: key);

  final Widget? leading;
  final VoidCallback onTap;
  final Widget title;
  final Widget subtitle;

  final bool selected;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 72),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox.square(
              dimension: 40,
              child: ClipOval(
                child: leading,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DefaultTextStyle(
                    style: TextStyle(
                      color: context.colorScheme.primaryText,
                      fontSize: 16,
                      height: 1.2,
                    ),
                    child: title,
                  ),
                  const SizedBox(height: 2),
                  DefaultTextStyle(
                    softWrap: true,
                    style: TextStyle(
                      color: context.colorScheme.thirdText,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                    child: subtitle,
                  ),
                ],
              ),
            ),
            if (selected)
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 2),
                child: SvgPicture.asset(
                  R.resourcesIcCheckSvg,
                  width: 24,
                  height: 24,
                ),
              )
            else
              const SizedBox(width: 51),
          ],
        ),
      ),
    ),
  );
}


class _UnauthorizedWidget extends StatelessWidget {
  const _UnauthorizedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 100),
          SvgPicture.asset(
            R.resourcesUnauthorizedContactSvg,
            width: 80,
            height: 80,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.contactReadFailed,
            style: TextStyle(
              color: context.colorScheme.thirdText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () {
              final uri =
                  Uri.https('mixin-www.zeromesh.net', 'oauth/authorize', {
                'client_id': Env.clientId,
                'scope':
                    'PROFILE:READ+ASSETS:READ+CONTACTS:READ+SNAPSHOTS:READ',
                'response_type': 'code',
              });
              context.toExternal(uri.toString());
            },
            child: Text(
              context.l10n.reauthorize,
              style: TextStyle(
                color: context.colorScheme.primaryText,
                fontSize: 14,
              ),
            ),
          ),
          const Spacer(flex: 164),
        ],
      );
}
