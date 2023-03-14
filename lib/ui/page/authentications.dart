import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';

import '../../generated/r.dart';
import '../../util/extension/extension.dart';
import '../../util/hook.dart';
import '../widget/avatar.dart';
import '../widget/buttons.dart';
import '../widget/dialog/auth_bottom_sheet.dart';
import '../widget/menu.dart';
import '../widget/mixin_appbar.dart';
import '../widget/text.dart';
import '../widget/toast.dart';

class Authentications extends StatelessWidget {
  const Authentications({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: MixinAppBar(
          title: Text(
            context.l10n.authorizations,
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          backgroundColor: context.colorScheme.background,
        ),
        backgroundColor: context.colorScheme.background,
        body: const _AuthorizationsPageBody(),
      );
}

class _AuthorizationsPageBody extends HookWidget {
  const _AuthorizationsPageBody();

  @override
  Widget build(BuildContext context) {
    final snapshot = useMemoizedFuture(() async {
      final response =
          await context.appServices.client.oauthApi.authorizations(null);
      return response.data;
    });

    useEffect(() {
      if (snapshot.hasError) {
        showErrorToast(snapshot.error!.toDisplayString(context));
      }
    }, [snapshot]);

    if (snapshot.isNoneOrWaiting) {
      return Center(
        child: CircularProgressIndicator(
          color: context.colorScheme.surface,
        ),
      );
    }

    return _AuthorizationsList(items: snapshot.data ?? const []);
  }
}

class _EmptyLayout extends StatelessWidget {
  const _EmptyLayout();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 42),
            SvgPicture.asset(
              R.resourcesIcAuthenticationSvg,
              width: 42,
              height: 42,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.noAuthorizations,
              style: TextStyle(
                fontSize: 16,
                color: context.theme.secondaryText,
              ),
            ),
          ],
        ),
      );
}

class _AuthorizationsList extends HookWidget {
  const _AuthorizationsList({required this.items});

  final List<AuthorizationResponse> items;

  @override
  Widget build(BuildContext context) {
    final items = useState(this.items);
    if (items.value.isEmpty) {
      return const _EmptyLayout();
    }
    return ListView.builder(
      itemCount: items.value.length,
      itemBuilder: (context, index) => _AuthorizationItem(
        item: items.value[index],
        onDeAuth: () {
          items.value = items.value.toList()..removeAt(index);
        },
      ),
    );
  }
}

class _AuthorizationItem extends StatelessWidget {
  const _AuthorizationItem({
    required this.item,
    required this.onDeAuth,
  });

  final AuthorizationResponse item;
  final VoidCallback onDeAuth;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 80,
        child: Material(
          color: context.colorScheme.background,
          child: InkWell(
            onTap: () async {
              final deAuth =
                  await _showAuthenticationDetailBottomSheet(context, item);
              if (deAuth) {
                onDeAuth();
              }
            },
            child: Row(
              children: [
                const SizedBox(width: 30),
                Avatar(
                  avatarUrl: item.app.iconUrl,
                  userId: item.app.appId,
                  name: item.app.name,
                  size: 50,
                  borderWidth: 0,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MixinText(
                        item.app.name,
                        style: TextStyle(
                          fontSize: 16,
                          color: context.colorScheme.primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      MixinText(
                        item.app.appNumber,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.colorScheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
      );
}

// return true if de-auth success
Future<bool> _showAuthenticationDetailBottomSheet(
  BuildContext context,
  AuthorizationResponse item,
) async {
  final ret = await showModalBottomSheet<bool>(
    context: context,
    builder: (context) => _AuthenticationDetailBottomSheet(item: item),
    isScrollControlled: true,
    isDismissible: true,
  );
  return ret ?? false;
}

class _AuthenticationDetailBottomSheet extends StatelessWidget {
  const _AuthenticationDetailBottomSheet({
    required this.item,
  });

  final AuthorizationResponse item;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: MixinAppBar(
          backgroundColor: context.colorScheme.background,
          leading: MixinBackButton(
            onTap: () => Navigator.of(context).pop(false),
          ),
          centerTitle: true,
          title: Text(
            context.l10n.permissions,
            style: TextStyle(
              color: context.colorScheme.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: context.colorScheme.background,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              for (var i = 0; i < item.scopes.length; i++)
                _PermissionScopeItem(
                  scope: item.scopes[i],
                  isFirst: i == 0,
                  isLast: i == item.scopes.length - 1,
                ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: MixinText(
                  context.l10n.authApprovedAccessDate(
                    DateFormat.yMMMMd()
                        .add_Hms()
                        .format(DateTime.parse(item.createdAt).toLocal()),
                    DateFormat.yMMMMd()
                        .add_Hms()
                        .format(DateTime.parse(item.accessedAt).toLocal()),
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colorScheme.secondaryText,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              MenuItemWidget(
                topRounded: true,
                bottomRounded: true,
                title: Text(
                  context.l10n.revokeAccess,
                  style: TextStyle(
                    color: context.colorScheme.red,
                  ),
                ),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      content:
                          Text(context.l10n.revokeConfirmation(item.app.name)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(context.l10n.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(context.l10n.confirm),
                        ),
                      ],
                    ),
                  );
                  if (!(confirm ?? false)) {
                    return;
                  }
                  final success = await runWithLoading(
                    () => context.appServices.client.oauthApi
                        .deAuthorize(item.app.appId),
                  );
                  if (success) {
                    Navigator.of(context).pop(true);
                  }
                },
              ),
            ],
          ),
        ),
      );
}

class _PermissionScopeItem extends StatelessWidget {
  const _PermissionScopeItem({
    required this.scope,
    required this.isFirst,
    required this.isLast,
  });

  final String scope;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final description = generateScopeDescription(context, scope);
    return MenuItemWidget(
      title: MixinText(description.item1),
      subtitle: MixinText(description.item2),
      topRounded: isFirst,
      bottomRounded: isLast,
    );
  }
}
