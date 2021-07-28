import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../db/mixin_database.dart';
import '../../../util/extension/extension.dart';
import '../../../util/hook.dart';
import '../../../util/r.dart';
import '../../router/mixin_routes.dart';
import '../avatar.dart';
import '../brightness_observer.dart';

const kTransactionItemHeight = 70.0;

class TransactionItem extends HookWidget {
  const TransactionItem({Key? key, required this.item}) : super(key: key);

  final SnapshotItem item;

  @override
  Widget build(BuildContext context) {
    final item = useMemoizedStream(
            () => context.mixinDatabase.snapshotDao
                .snapshotsById(this.item.snapshotId)
                .watchSingle(),
            keys: [this.item.snapshotId]).data ??
        this.item;
    final isPositive = item.isPositive;
    return InkWell(
      onTap: () =>
          context.push(snapshotDetailPath.toUri({'id': item.snapshotId})),
      child: Container(
          height: kTransactionItemHeight,
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 20),
              _TransactionIcon(item: item),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 14,
                          color: context.theme.text,
                        ),
                        child: TransactionTypeWidget(item: item),
                      ),
                      const Spacer(),
                      Text(
                        '${isPositive ? '+' : ''}${item.amount.numberFormat()}',
                        style: TextStyle(
                          fontSize: 14,
                          color: item.type == SnapshotType.pending
                              ? context.theme.secondaryText
                              : isPositive
                                  ? context.theme.green
                                  : context.theme.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        item.type == SnapshotType.pending
                            ? context.l10n.pendingConfirmations(
                                item.confirmations ?? 0,
                                item.assetConfirmations)
                            : DateFormat.yMMMMd().format(item.createdAt),
                        style: TextStyle(
                          fontSize: 14,
                          color: BrightnessData.themeOf(context).secondaryText,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.assetSymbol,
                        style: TextStyle(
                          fontSize: 12,
                          color: BrightnessData.themeOf(context).text,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                ],
              )),
              const SizedBox(width: 20),
            ],
          )),
    );
  }
}

class TransactionTypeWidget extends StatelessWidget {
  const TransactionTypeWidget({Key? key, required this.item}) : super(key: key);

  final SnapshotItem item;

  @override
  Widget build(BuildContext context) {
    String title;
    switch (item.type) {
      case SnapshotType.pending:
        title = context.l10n.depositing;
        break;
      case SnapshotType.deposit:
        title = context.l10n.deposit;
        break;
      case SnapshotType.transfer:
        title = context.l10n.transfer;
        break;
      case SnapshotType.withdrawal:
        title = context.l10n.withdrawal;
        break;
      case SnapshotType.fee:
        title = context.l10n.fee;
        break;
      case SnapshotType.rebate:
        title = context.l10n.rebate;
        break;
      case SnapshotType.raw:
        title = context.l10n.raw;
        break;
      default:
        title = item.type;
        break;
    }

    return Text(title);
  }
}

class _TransactionIcon extends StatelessWidget {
  const _TransactionIcon({Key? key, required this.item}) : super(key: key);

  final SnapshotItem item;

  @override
  Widget build(BuildContext context) {
    Widget? child;

    if (item.type == SnapshotType.transfer) {
      child = InkResponse(
        onTap: () {
          assert(item.opponentId != null);
          launch('mixin://users/${item.opponentId}');
        },
        child: Avatar(
          avatarUrl: item.avatarUrl,
          userId: item.opponentId ?? '',
          name: item.opponentFulName ?? '',
          size: 44,
          borderWidth: 0,
        ),
      );
    } else if (item.type == SnapshotType.deposit) {
      child = SvgPicture.asset(
        R.resourcesTransactionDepositSvg,
        height: 55,
        width: 55,
        fit: BoxFit.cover,
        allowDrawingOutsideViewBox: true,
      );
    } else if (item.type == SnapshotType.pending) {
      final progress = (item.confirmations ?? 0) / item.assetConfirmations;
      child = Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.asset(
            R.resourcesTransactionPendingSvg,
            height: 44,
            width: 44,
          ),
          Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.5))),
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
        height: 44,
        width: 44,
      );
    } else {
      child = SvgPicture.asset(
        R.resourcesTransactionNetSvg,
        height: 44,
        width: 44,
      );
    }

    return SizedBox(
      width: 44,
      height: 44,
      child: ClipOval(child: child),
    );
  }
}
