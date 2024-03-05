import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../db/mixin_database.dart';
import '../../../util/extension/extension.dart';
import '../../../util/hook.dart';
import '../../../util/r.dart';
import '../../router/mixin_routes.dart';
import '../asset.dart';
import '../avatar.dart';
import '../text.dart';

const kTransactionItemHeight = 72.0;

class TransactionItem extends HookWidget {
  const TransactionItem({
    required this.item,
    super.key,
    this.onTap,
  });

  final SnapshotItem item;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final item = useMemoizedStream(
            () => context.mixinDatabase.snapshotDao
                .snapshotsById(this.item.snapshotId)
                .watchSingle(),
            keys: [this.item.snapshotId]).data ??
        this.item;

    void onTap() {
      if (this.onTap != null) {
        this.onTap!();
        return;
      }
      context.push(snapshotDetailPath.toUri({'id': item.snapshotId}));
    }

    final isPositive = item.isPositive;
    return InkWell(
      onTap: onTap,
      child: Container(
          height: kTransactionItemHeight,
          padding: const EdgeInsets.only(top: 16, bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 16),
              _TransactionIcon(item: item),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle.merge(
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 16,
                      color: context.colorScheme.primaryText,
                    ),
                    child: TransactionTypeWidget(item: item),
                  ),
                  const Spacer(),
                  Text(
                    item.type == SnapshotType.pending
                        ? context.l10n.pendingConfirmations(
                            item.confirmations ?? 0,
                            item.assetConfirmations ?? 0)
                        : DateFormat.yMMMMd().format(item.createdAt.toLocal()),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colorScheme.thirdText,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleLineEllipsisText(
                      '${isPositive ? '+' : ''}${item.amount.numberFormat()}',
                      constraints: constraints,
                      style: TextStyle(
                        fontSize: 14,
                        color: item.type == SnapshotType.pending
                            ? context.colorScheme.thirdText
                            : isPositive
                                ? context.colorScheme.green
                                : context.colorScheme.red,
                        fontWeight: FontWeight.w600,
                      ),
                      onTap: onTap,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              MixinText(
                item.assetSymbol ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: context.colorScheme.primaryText,
                ),
              ),
              const SizedBox(width: 16),
            ],
          )),
    );
  }
}

class TransactionTypeWidget extends StatelessWidget {
  const TransactionTypeWidget({
    required this.item,
    super.key,
    this.selectable = false,
  });

  final SnapshotItem item;

  final bool selectable;

  @override
  Widget build(BuildContext context) {
    String title;
    switch (item.type) {
      case SnapshotType.pending:
        title = context.l10n.depositing;
      case SnapshotType.deposit:
        title = context.l10n.deposit;
      case SnapshotType.transfer:
        title = context.l10n.transfer;
      case SnapshotType.withdrawal:
        title = context.l10n.withdrawal;
      case SnapshotType.fee:
        title = context.l10n.fee;
      case SnapshotType.rebate:
        title = context.l10n.rebate;
      case SnapshotType.raw:
        title = context.l10n.raw;
      default:
        title = item.type;
        break;
    }

    return SelectableText(
      title,
      enableInteractiveSelection: selectable,
    );
  }
}

class _TransactionIcon extends StatelessWidget {
  const _TransactionIcon({required this.item});

  final SnapshotItem item;

  @override
  Widget build(BuildContext context) {
    Widget? child;

    if (item.type == SnapshotType.transfer) {
      child = InkResponse(
        onTap: () {
          assert(item.opponentId != null);
          launchUrlString('mixin://users/${item.opponentId}');
        },
        child: Avatar(
          avatarUrl: item.avatarUrl,
          userId: item.opponentId ?? '',
          name: item.opponentFulName ?? '',
          size: 40,
          borderWidth: 0,
        ),
      );
    } else if (item.type == SnapshotType.deposit) {
      child = SvgPicture.asset(
        R.resourcesTransactionDepositSvg,
        height: 40,
        width: 40,
        fit: BoxFit.cover,
        allowDrawingOutsideViewBox: true,
      );
    } else if (item.type == SnapshotType.pending) {
      final progress =
          (item.confirmations ?? 0) / (item.assetConfirmations ?? 1);
      child = Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            R.resourcesTransactionPendingSvg,
            height: 40,
            width: 40,
          ),
          Positioned.fill(
              child: ColoredBox(color: Colors.black.withOpacity(0.5))),
          Text(
            '${(progress * 100).round()}%',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          Transform.rotate(
            angle: 4.5 * 2 * math.pi / 12.0,
            child: CircularProgressIndicator(
              value: progress,
              color: Colors.white,
              strokeWidth: 2,
            ),
          ),
        ],
      );
    } else if (item.type == SnapshotType.withdrawal) {
      child = SvgPicture.asset(
        R.resourcesTransactionWithdrawalSvg,
        height: 40,
        width: 40,
      );
    } else {
      child = SvgPicture.asset(
        R.resourcesTransactionNetSvg,
        height: 40,
        width: 40,
      );
    }

    return SizedBox(
      width: 40,
      height: 40,
      child: ClipOval(child: child),
    );
  }
}
