import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';
import 'package:tuple/tuple.dart';

import '../../util/extension/extension.dart';
import '../../util/logger.dart';
import '../../util/native_scroll.dart';
import '../widget/buttons.dart';
import '../widget/mixin_appbar.dart';
import '../widget/text.dart';
import '../widget/toast.dart';
import 'home/empty.dart';

class PinLogs extends HookWidget {
  const PinLogs({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = useState(<LogResponse>[]);

    final isLoading = useState(false);
    final hasMore = useState(true);

    Future<void> loadMore() async {
      if (isLoading.value || !hasMore.value) {
        return;
      }
      isLoading.value = true;
      try {
        final response = await context.appServices.client.accountApi.pinLogs(
          offset: logs.value.lastOrNull?.createdAt,
        );
        logs.value += response.data;
        hasMore.value = response.data.isNotEmpty;
      } catch (error, stacktrace) {
        e('loadMore $error $stacktrace');
        showErrorToast(error.toDisplayString(context));
        hasMore.value = false;
      } finally {
        isLoading.value = false;
      }
    }

    useMemoized(loadMore);

    final Widget body;

    if (logs.value.isEmpty) {
      if (isLoading.value) {
        body = const _LoadingLayout();
      } else {
        body = Center(
          child: EmptyLayout(content: context.l10n.noLogs),
        );
      }
    } else {
      body = _LogsList(
        logs: logs.value,
        loadMore: loadMore,
      );
    }

    return Scaffold(
      appBar: MixinAppBar(
        leading: const MixinBackButton2(),
        title: SelectableText(
          context.l10n.logs,
          style: TextStyle(
            color: context.colorScheme.primaryText,
            fontSize: 18,
          ),
          enableInteractiveSelection: false,
        ),
        backgroundColor: context.colorScheme.background,
      ),
      backgroundColor: context.colorScheme.background,
      body: body,
    );
  }
}

class _LoadingLayout extends StatelessWidget {
  const _LoadingLayout();

  @override
  Widget build(BuildContext context) => Center(
        child: CircularProgressIndicator(
          color: context.colorScheme.captionIcon,
        ),
      );
}

class _LogsList extends StatelessWidget {
  const _LogsList({
    required this.logs,
    required this.loadMore,
  });

  final List<LogResponse> logs;

  final VoidCallback loadMore;

  @override
  Widget build(BuildContext context) => NativeScrollBuilder(
        builder: (context, controller) =>
            NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is! ScrollUpdateNotification) return false;
            if (notification.scrollDelta == null) return false;
            if (notification.scrollDelta! < 0) return false;

            final dimension = notification.metrics.viewportDimension / 2;
            if (notification.metrics.maxScrollExtent -
                    notification.metrics.pixels <
                dimension) {
              loadMore();
            }
            return false;
          },
          child: ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) => _LogItem(log: logs[index]),
            controller: controller,
          ),
        ),
      );
}

Tuple2<String, String> _getCodeDescription(BuildContext context, String code) {
  switch (code) {
    case 'VERIFICATION':
      return Tuple2(context.l10n.pinIncorrect, context.l10n.verify);
    case 'RAW_TRANSFER':
      return Tuple2(context.l10n.pinIncorrect, context.l10n.rawTransfer);
    case 'USER_TRANSFER':
      return Tuple2(context.l10n.pinIncorrect, context.l10n.transfer);
    case 'WITHDRAWAL':
      return Tuple2(context.l10n.pinIncorrect, context.l10n.withdrawal);
    case 'ADD_ADDRESS':
      return Tuple2(context.l10n.pinIncorrect, context.l10n.addAddress);
    case 'DELETE_ADDRESS':
      return Tuple2(context.l10n.pinIncorrect, context.l10n.deleteAddress);
    case 'ADD_EMERGENCY':
      return Tuple2(
          context.l10n.pinIncorrect, context.l10n.addEmergencyContact);
    case 'DELETE_EMERGENCY':
      return Tuple2(
          context.l10n.pinIncorrect, context.l10n.deleteEmergencyContact);
    case 'READ_EMERGENCY':
      return Tuple2(
          context.l10n.pinIncorrect, context.l10n.viewEmergencyContact);
    case 'UPDATE_PHONE':
      return Tuple2(context.l10n.pinIncorrect, context.l10n.changePhoneNumber);
    case 'UPDATE_PIN':
      return Tuple2(context.l10n.pinIncorrect, context.l10n.pinChange);
    case 'MULTISIG_SIGN':
      return Tuple2(
          context.l10n.pinIncorrect, context.l10n.multisigTransaction);
    case 'MULTISIG_UNLOCK':
      return Tuple2(
          context.l10n.pinIncorrect, context.l10n.revokeMultisigTransaction);
    case 'ACTIVITY_PIN_CREATION':
      return Tuple2(
          context.l10n.pinCreation, context.l10n.youPinHasBeenCreated);
    case 'ACTIVITY_PIN_MODIFICATION':
      return Tuple2(context.l10n.pinChange, context.l10n.pinChange);
    case 'ACTIVITY_EMERGENCY_CONTACT_MODIFICATION':
      return Tuple2(
          context.l10n.emergencyContact, context.l10n.changeEmergencyContact);
    case 'ACTIVITY_PHONE_MODIFICATION':
      return Tuple2(
          context.l10n.phoneNumberChange, context.l10n.phoneNumberChange);
    case 'ACTIVITY_LOGIN_BY_PHONE':
      return Tuple2(context.l10n.signIn, context.l10n.signInWithPhoneNumber);
    case 'ACTIVITY_LOGIN_BY_EMERGENCY_CONTACT':
      return Tuple2(
          context.l10n.signIn, context.l10n.signInWithEmergencyContact);
    case 'ACTIVITY_LOGIN_FROM_DESKTOP':
      return Tuple2(context.l10n.signIn, context.l10n.signInDesktopApp);
    default:
      return Tuple2(code, code);
  }
}

class _LogItem extends HookWidget {
  const _LogItem({required this.log});

  final LogResponse log;

  @override
  Widget build(BuildContext context) {
    final description = useMemoized(
      () => _getCodeDescription(context, log.code),
      [log.code],
    );
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MixinText(
                description.item1,
                style: TextStyle(
                  fontSize: 16,
                  color: context.colorScheme.primaryText,
                ),
                maxLines: 1,
              ),
              const Spacer(),
              MixinText(
                DateFormat.yMMMMd()
                    .add_Hms()
                    .format(DateTime.parse(log.createdAt).toLocal()),
                style: TextStyle(
                  fontSize: 12,
                  color: context.colorScheme.thirdText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          MixinText(
            description.item2,
            style: TextStyle(
              color: context.colorScheme.thirdText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          MixinText(
            log.ipAddress,
            style: TextStyle(
              color: context.colorScheme.thirdText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
