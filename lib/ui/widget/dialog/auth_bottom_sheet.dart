// ignore_for_file: avoid_positional_boolean_parameters

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart' as sdk;
import 'package:tuple/tuple.dart';

import '../../../generated/r.dart';
import '../../../service/profile/pin_session.dart';
import '../../../util/constants.dart';
import '../../../util/extension/extension.dart';
import '../buttons.dart';
import '../mixin_bottom_sheet.dart';
import '../pin.dart';
import '../toast.dart';

const _scopes = [
  'PROFILE:READ',
  'PHONE:READ',
  'MESSAGES:REPRESENT',
  'CONTACTS:READ',
  'ASSETS:READ',
  'SNAPSHOTS:READ',
  'APPS:READ',
  'APPS:WRITE',
  'CIRCLES:READ',
  'CIRCLES:WRITE',
  'COLLECTIBLES:READ',
];

bool _isWalletScope(String scope) => {
      _scopes[0],
      _scopes[4],
    }.contains(scope);

Tuple2<String, String> generateScopeDescription(
    BuildContext context, String scope) {
  if (scope == _scopes[0]) {
    return Tuple2(
      context.l10n.readYourPublicProfile,
      context.l10n.allowBotAccessProfile,
    );
  } else if (scope == _scopes[4]) {
    return Tuple2(
      context.l10n.readYourAssets,
      context.l10n.allowBotAccessAssets,
    );
  } else if (scope == _scopes[5]) {
    return Tuple2(
      context.l10n.readYourSnapshots,
      context.l10n.allowBotAccessSnapshots,
    );
  } else if (scope == _scopes[10]) {
    return Tuple2(
      context.l10n.readYourNFTs,
      context.l10n.allowBotAccessNFTs,
    );
  } else {
    return Tuple2(scope, scope);
  }
}

Future<void> showAuthBottomSheet(
  BuildContext context, {
  required String name,
  required List<String> scopes,
  required String number,
  required String authId,
  String? iconUrl,
}) async {
  await showModalBottomSheet<String>(
    context: context,
    builder: (context) => SingleChildScrollView(
      child: Material(
        color: context.colorScheme.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(topRadius),
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 88,
          child: _AuthBottomSheet(
            name: name,
            scopes: scopes.where(_isWalletScope).toList(),
            number: number,
            authId: authId,
            iconUrl: iconUrl,
          ),
        ),
      ),
    ),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(topRadius),
      ),
    ),
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: false,
    backgroundColor: Colors.transparent,
  );
}

class _AuthBottomSheet extends HookWidget {
  const _AuthBottomSheet({
    required this.name,
    required this.scopes,
    required this.number,
    required this.authId,
    this.iconUrl,
  });

  final String name;
  final List<String> scopes;
  final String number;
  final String authId;
  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    final checkedScopes = useState(scopes.toSet());
    final inputPinMode = useState(false);

    void onCheckedChange(String scope, {required bool check}) {
      if (check) {
        checkedScopes.value = checkedScopes.value.toSet()..add(scope);
      } else {
        checkedScopes.value = checkedScopes.value.toSet()..remove(scope);
      }
    }

    if (inputPinMode.value) {
      return PinVerifyDialogScaffold(
          header: Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _AuthHeader(
                    name: name,
                    number: number,
                    iconUrl: iconUrl,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _ScopeItemList(
                      scopes: scopes,
                      checkedScopes: checkedScopes.value,
                      onChanged: (scope, check) =>
                          onCheckedChange(scope, check: check),
                    ),
                  ),
                ],
              ),
            ),
          ),
          tip: null,
          onErrorConfirmed: null,
          onVerified: (context, pin) async {
            Navigator.pop(context);
            showSuccessToast(context.l10n.authorized);
          },
          verification: (context, pin) async {
            await context.appServices.client.oauthApi.authorize(
              sdk.AuthorizeRequest(
                authorizationId: authId,
                scopes: checkedScopes.value.toList(),
                pin: encryptPin(context, pin),
              ),
            );
          });
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const MixinBottomSheetTitle(
          title: SizedBox.shrink(),
          action: BottomSheetCloseButton(),
        ),
        _AuthHeader(
          name: name,
          number: number,
          iconUrl: iconUrl,
        ),
        Expanded(
          child: _GroupScopeWidget(
            scopes: scopes,
            checkedScopes: checkedScopes.value,
            onChanged: (scope, check) => onCheckedChange(scope, check: check),
            onNextStep: () => inputPinMode.value = true,
          ),
        ),
      ],
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({
    required this.name,
    required this.number,
    this.iconUrl,
  });

  final String name;
  final String number;
  final String? iconUrl;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(
            context.l10n.requestAuthorization,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: context.colorScheme.primaryText,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconUrl != null)
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: ClipOval(
                    child: SizedBox.square(
                      dimension: 16,
                      child: Image.network(
                        iconUrl!,
                        width: 16,
                        height: 16,
                      ),
                    ),
                  ),
                ),
              Text(
                '$name($number)',
                style: TextStyle(color: context.colorScheme.secondaryText),
              ),
            ],
          ),
        ],
      );
}

class _GroupScopeWidget extends StatelessWidget {
  const _GroupScopeWidget({
    required this.scopes,
    required this.onChanged,
    required this.checkedScopes,
    required this.onNextStep,
  });

  final List<String> scopes;
  final void Function(String scope, bool checked) onChanged;
  final Set<String> checkedScopes;
  final VoidCallback onNextStep;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            SvgPicture.asset(
              R.resourcesAuthWalletSvg,
              width: 60,
              height: 60,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.wallet,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.colorScheme.primaryText,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _ScopeItemList(
                scopes: scopes,
                checkedScopes: checkedScopes,
                onChanged: onChanged,
              ),
            ),
            const SizedBox(height: 32),
            MixinPrimaryTextButton(
              onTap: onNextStep,
              text: context.l10n.next,
            ),
            const SizedBox(height: 70),
          ],
        ),
      );
}

class _ScopeItemList extends StatelessWidget {
  const _ScopeItemList({
    required this.scopes,
    required this.checkedScopes,
    required this.onChanged,
  });

  final List<String> scopes;
  final Set<String> checkedScopes;
  final void Function(String scope, bool checked) onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < scopes.length; i++) {
      final scope = scopes[i];
      final checked = checkedScopes.contains(scope);
      final topRounded = i == 0;
      final bottomRounded = i == scopes.length - 1;
      items.add(_ScopeCheckItem(
        scope: scope,
        checked: checked,
        onChanged: onChanged,
        topRounded: topRounded,
        bottomRounded: bottomRounded,
      ));
    }
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: items,
    );
  }
}

class _ScopeCheckItem extends StatelessWidget {
  const _ScopeCheckItem({
    required this.scope,
    required this.checked,
    required this.onChanged,
    this.topRounded = false,
    this.bottomRounded = false,
  });

  final String scope;
  final bool checked;
  final void Function(String scope, bool checked) onChanged;
  final bool topRounded;
  final bool bottomRounded;

  @override
  Widget build(BuildContext context) {
    final isProfileScope = scope == _scopes[0];
    final description = generateScopeDescription(context, scope);
    final borderRadius = BorderRadius.vertical(
      top: topRounded ? const Radius.circular(12) : Radius.zero,
      bottom: bottomRounded ? const Radius.circular(12) : Radius.zero,
    );
    return Material(
      borderRadius: borderRadius,
      color: const Color(0xFFF6F7FA),
      child: InkWell(
        borderRadius: borderRadius,
        onTap: isProfileScope
            ? null
            : () {
                onChanged(scope, !checked);
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: _IconCheck(selected: isProfileScope ? null : checked),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description.item1,
                      style: TextStyle(
                        fontSize: 16,
                        color: context.colorScheme.primaryText,
                      ),
                    ),
                    Text(
                      description.item2,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.colorScheme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconCheck extends StatelessWidget {
  const _IconCheck({this.selected});

  final bool? selected;

  @override
  Widget build(BuildContext context) => ClipOval(
        child: Container(
          color: selected ?? true
              ? const Color(0xFF4B7CDD)
              : context.theme.secondaryText,
          height: 16,
          width: 16,
          alignment: const Alignment(0, -0.2),
          child: selected == null
              ? const SizedBox.shrink()
              : SvgPicture.asset(
                  R.resourcesSelectedSvg,
                  height: 10,
                  width: 10,
                ),
        ),
      );
}
