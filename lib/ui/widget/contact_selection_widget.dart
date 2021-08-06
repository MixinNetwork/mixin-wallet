import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../db/mixin_database.dart';
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

    useMemoized(() {
      context.appServices.updateFriends();
    });

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
          Expanded(
            child: ListView.builder(
              itemCount: filterList.length,
              itemBuilder: (BuildContext context, int index) => _UserItem(
                user: filterList[index],
                selectedUserId: selectedUser?.userId,
              ),
            ),
          ),
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
