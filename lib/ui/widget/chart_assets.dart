// ignore_for_file: avoid_setters_without_getters

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../db/mixin_database.dart';
import '../../util/extension/extension.dart';
import '../brightness_theme_data.dart';

@immutable
class _AssetChartItem {
  const _AssetChartItem({
    required this.color,
    required this.name,
    required this.amount,
    this.isOther = false,
  });

  factory _AssetChartItem.fromAsset(AssetResult asset, Color color) =>
      _AssetChartItem(
        color: color,
        name: asset.name,
        amount: asset.amountOfUsd.toDouble(),
      );

  final Color color;
  final String name;
  final double amount;
  final bool isOther;
}

class AssetsAnalysisChartLayout extends HookWidget {
  const AssetsAnalysisChartLayout({
    Key? key,
    required this.assets,
  })  : assert(assets.length >= 4),
        super(key: key);

  final List<AssetResult> assets;

  @override
  Widget build(BuildContext context) {
    final assetChartItems = useMemoized(() {
      if (assets.isEmpty) {
        return const <_AssetChartItem>[];
      }
      final sorted = assets.toList()
        ..sort((a, b) => b.amountOfUsd.compareTo(a.amountOfUsd));
      assert(sorted.length >= 4);

      final items = <_AssetChartItem>[];

      var otherAmount = 0.0;
      for (var i = 0; i < sorted.length; i++) {
        if (i < 3) {
          items.add(_AssetChartItem.fromAsset(sorted[i], assetColors[i]));
        } else {
          otherAmount += sorted[i].amountOfUsd.toDouble();
        }
      }
      items.add(
        _AssetChartItem(
          color: assetColors[3],
          name: '',
          amount: otherAmount,
          isOther: true,
        ),
      );
      return items;
    }, [assets]);

    assert(assetChartItems.length == 4);

    final percents = useMemoized(() {
      final totalAmount = assetChartItems.fold<double>(
          0, (previousValue, e) => previousValue + e.amount);

      final percents = List.filled(4, 0);

      var remainPercent = 10000;
      for (var i = 0; i < assetChartItems.length; i++) {
        final item = assetChartItems[i];
        if (item.amount == 0) {
          percents[i] = 0;
        } else {
          final percent = ((item.amount / totalAmount) * 10000).round();
          remainPercent -= percent;
          percents[i] = percent;
        }
      }

      if (remainPercent > 0) {
        for (var i = assetChartItems.length - 1; i >= 0; i--) {
          if (percents[i] != 0) {
            percents[i] += remainPercent;
          }
        }
      } else if (remainPercent < 0) {
        for (var i = assetChartItems.length - 1; i >= 0; i--) {
          if (percents[i] > remainPercent) {
            percents[i] -= remainPercent;
          }
        }
      }
      return percents;
    }, [assetChartItems]);

    assert(percents.length == 4);

    return SizedBox(
      height: 64,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: RepaintBoundary(
              child: _AssetsPieChart(
                items: assetChartItems,
                dividerColor: Colors.transparent,
                centerCircleColor: context.colorScheme.background,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              _ChartDescriptionTile(
                item: assetChartItems[0],
                percent: percents[0],
              ),
              _ChartDescriptionTile(
                item: assetChartItems[2],
                percent: percents[2],
              ),
            ],
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: [
              _ChartDescriptionTile(
                item: assetChartItems[1],
                percent: percents[1],
              ),
              _ChartDescriptionTile(
                item: assetChartItems[3],
                percent: percents[3],
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _ChartDescriptionTile extends StatelessWidget {
  const _ChartDescriptionTile({
    Key? key,
    required this.item,
    required this.percent,
  }) : super(key: key);

  final _AssetChartItem item;

  /// The percent of total. The value has been magnified by 10000 times
  final int percent;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
            ),
            width: 10,
            height: 10,
          ),
          const SizedBox(width: 8),
          Text(
            item.isOther ? context.l10n.other : item.name,
            style: TextStyle(
              fontSize: 12,
              color: context.colorScheme.primaryText,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${percent / 100}%',
            style: TextStyle(
              fontSize: 12,
              color: context.colorScheme.thirdText,
            ),
          )
        ],
      );
}

class _AssetsPieChart extends LeafRenderObjectWidget {
  const _AssetsPieChart({
    Key? key,
    required this.items,
    required this.dividerColor,
    required this.centerCircleColor,
  }) : super(key: key);

  final List<_AssetChartItem> items;

  final Color dividerColor;

  /// Do not support Transparent color yet.
  final Color centerCircleColor;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _AssetsPieChartRender(items: items)
        ..dividerColor = dividerColor
        ..centerCircleColor = centerCircleColor;

  @override
  void updateRenderObject(
      BuildContext context, covariant _AssetsPieChartRender renderObject) {
    renderObject
      .._items = items
      ..dividerColor = dividerColor
      ..centerCircleColor = centerCircleColor;
  }
}

class _AssetsPieChartRender extends RenderBox {
  _AssetsPieChartRender({List<_AssetChartItem>? items}) : _items = items;

  List<_AssetChartItem>? _items;

  set items(List<_AssetChartItem>? items) {
    if (_items == items) {
      return;
    }
    _items = items;
    markNeedsPaint();
  }

  Color _centerCircleColor = Colors.white;

  set dividerColor(Color color) {
    _dividerPainter.color = color;
    markNeedsPaint();
  }

  final _dataPainter = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  final _dividerPainter = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.white
    ..isAntiAlias = true;

  set centerCircleColor(Color color) {
    _centerCircleColor = color;
    markNeedsPaint();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final size = math.min(constraints.maxWidth, constraints.maxHeight);
    return Size.square(size);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final items = _items;
    if (items == null || items.isEmpty || size == Size.zero) {
      return;
    }
    context.canvas.save();
    context.canvas.translate(offset.dx, offset.dy);
    _paintPieCharts(
      context.canvas,
      items.where((e) => e.amount > 0).toList(),
      size,
    );
    context.canvas.restore();
  }

  void _paintPieCharts(
    Canvas canvas,
    List<_AssetChartItem> items,
    Size size, {
    double itemDivider = 2.0,
    double? centerCircleRadius,
  }) {
    assert(items.isNotEmpty);

    final pieRadius = size.width / 2;
    final centerRadius = centerCircleRadius ?? pieRadius / 2;

    final dividerAngle =
        items.length == 1 ? 0.0 : itemDivider / (pieRadius + centerRadius) * 2;

    final total = items.fold<double>(
        0.0, (previousValue, element) => previousValue + element.amount);

    final dataTotalAngel = 2 * math.pi - items.length * dividerAngle;

    var startAngle = -1 / 2 * math.pi;
    final rect = Offset.zero & size;
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final sweepAngle = (item.amount / total) * dataTotalAngel;
      _dataPainter.color = item.color;
      canvas
        ..drawArc(rect, startAngle, sweepAngle, true, _dataPainter)
        ..drawArc(
            rect, startAngle + sweepAngle, dividerAngle, true, _dividerPainter);
      startAngle += sweepAngle + dividerAngle;
    }

    if (centerRadius != 0) {
      final centerPaint = Paint()
        ..color = _centerCircleColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
          Offset(pieRadius, pieRadius), centerRadius, centerPaint);
    }
  }
}
