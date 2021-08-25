// ignore_for_file: avoid_setters_without_getters

import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../util/extension/extension.dart';

abstract class PieChartItem extends Equatable {
  const PieChartItem();

  double get amount;

  Color get color;

  @override
  List<Object?> get props => [amount, color];
}

class PieChart extends StatelessWidget {
  const PieChart({
    Key? key,
    required this.items,
    this.dividerColor,
    this.centerCircleColor,
  }) : super(key: key);

  final List<PieChartItem> items;

  final Color? dividerColor;

  /// Do not support Transparent color yet.
  final Color? centerCircleColor;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: _RawPieChart(
          items: items,
          dividerColor: dividerColor ?? Colors.transparent,
          centerCircleColor:
              centerCircleColor ?? context.colorScheme.background,
        ),
      );
}

class _RawPieChart extends LeafRenderObjectWidget {
  const _RawPieChart({
    Key? key,
    required this.items,
    required this.dividerColor,
    required this.centerCircleColor,
  }) : super(key: key);

  final List<PieChartItem> items;

  final Color dividerColor;

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
  _AssetsPieChartRender({List<PieChartItem>? items}) : _items = items;

  List<PieChartItem>? _items;

  set items(List<PieChartItem>? items) {
    if (_items == items) {
      return;
    }
    _items = items;
    markNeedsPaint();
  }

  Color _centerCircleColor = Colors.white;

  set dividerColor(Color color) {
    if (_dividerPainter.color == color) {
      return;
    }
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
    if (_centerCircleColor == color) {
      return;
    }
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
    List<PieChartItem> items,
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
