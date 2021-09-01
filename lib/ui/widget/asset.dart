import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../router/mixin_routes.dart';
import 'symbol.dart';

class AssetWidget extends StatelessWidget {
  const AssetWidget({
    Key? key,
    required this.data,
  }) : super(key: key);

  final AssetResult data;

  @override
  Widget build(BuildContext context) {
    void onTap() {
      context.push(assetDetailPath.toUri({'id': data.assetId}));
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        height: 72,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SymbolIconWithBorder(
              symbolUrl: data.iconUrl,
              chainUrl: data.chainIconUrl,
              size: 40,
              chainSize: 14,
              chainBorder: BorderSide(
                color: context.colorScheme.background,
                width: 1.5,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: LayoutBuilder(
                          builder: (context, constraints) =>
                              _SingleLineEllipsisText(
                            data.balance.numberFormat().overflow,
                            constraints: constraints,
                            onTap: onTap,
                            style: TextStyle(
                              color: context.colorScheme.primaryText,
                              fontSize: 16,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        ' ${data.symbol}'.overflow,
                        style: TextStyle(
                          color: context.colorScheme.primaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    data.amountOfCurrentCurrency.currencyFormat,
                    style: TextStyle(
                      color: context.colorScheme.thirdText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            AssetPrice(data: data),
          ],
        ),
      ),
    );
  }
}

class AssetPrice extends StatelessWidget {
  const AssetPrice({
    Key? key,
    required this.data,
  }) : super(key: key);

  final AssetResult data;

  @override
  Widget build(BuildContext context) {
    final valid = !data.priceUsd.isZero;
    if (!valid) {
      return Text(
        context.l10n.none,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: context.colorScheme.thirdText,
          fontSize: 14,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        PercentageChange(
          changeUsd: data.changeUsd,
        ),
        Text(
          data.usdUnitPrice.currencyFormat,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: context.colorScheme.thirdText,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

/// A text wrapper for ellipsis, because text ellipsis do not work
/// on Android Webview.
/// Remove when https://github.com/flutter/flutter/issues/86776 has been fixed.
class _SingleLineEllipsisText extends HookWidget {
  const _SingleLineEllipsisText(
    this.text, {
    Key? key,
    this.style,
    required this.constraints,
    required this.onTap,
  }) : super(key: key);

  final String text;
  final TextStyle? style;
  final BoxConstraints constraints;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);

    final endIndex = useMemoized(() {
      final maxWidth = constraints.maxWidth;
      final textSpan = TextSpan(
        text: text,
        style: style,
      );

      final textPainter = TextPainter(
        text: TextSpan(text: '...', style: style),
        textDirection: direction,
        maxLines: 1,
      )..layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
      final overflowTextSpanSize = textPainter.size;

      textPainter
        ..text = textSpan
        ..layout(
            minWidth: math.max(
              constraints.minWidth - overflowTextSpanSize.width,
              0,
            ),
            maxWidth: math.max(
              maxWidth - overflowTextSpanSize.width,
              0,
            ));

      // TextPainter.didExceedMaxLines did not work on Web
      // https://github.com/flutter/flutter/issues/65940
      // So we use a fixed value to avoid overflow.
      final pos = textPainter.getPositionForOffset(Offset(
        maxWidth - 50,
        0,
      ));
      return pos.offset;
    }, [text, style, direction]);

    final resultText = useMemoized(
      () {
        if (endIndex == -1 || endIndex == text.length) {
          return text;
        }
        return '${text.substring(0, endIndex)}...';
      },
      [text, endIndex],
    );

    return SelectableText(
      resultText,
      style: style,
      maxLines: 1,
      enableInteractiveSelection: false,
      onTap: onTap,
    );
  }
}
