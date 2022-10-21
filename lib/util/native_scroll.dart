// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../main.dart';
import 'logger.dart';

/// https://github.com/tomgilder/native_scroll/blob/main/lib/src/native_scroll_web.dart
class NativeScrollBuilder extends StatefulWidget {
  const NativeScrollBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final Widget Function(BuildContext context, ScrollController controller)
      builder;

  @override
  State<NativeScrollBuilder> createState() => _NativeScrollBuilderState();
}

class _NativeScrollBuilderState extends State<NativeScrollBuilder>
    with RouteAware {
  static int _globalId = 0;

  late String _viewId;
  late ScrollController _scrollController;

  final _heightDiv = DivElement();
  final _scrollDiv = DivElement();

  var _isForeground = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _globalId++;
    _viewId = 'native-scroll-view-$_globalId';

    // ignore: undefined_prefixed_name, avoid_dynamic_calls
    ui.platformViewRegistry.registerViewFactory(
      _viewId,
      // Create a scroll container - this is a <div> with scrolling overflow.
      // When it scroll, the Flutter ScrollController gets updated.
      (_) => _scrollDiv
        ..id = _viewId
        ..style.overflow = 'scroll'
        ..style.width = '100%'
        ..style.height = '100%'
        // We need to cancel scroll events to stop them getting to Flutter
        ..onWheel.listen((event) => event.stopPropagation())
        ..onMouseWheel.listen((event) => event.stopPropagation())
        ..onScroll.listen((event) {
          debugPrint('scroll: ${event.target}');
          final target = event.target! as DivElement;
          _onNativeScroll(target.scrollTop);
        })
        ..append(_heightDiv),
    );

    _scrollController.addListener(_onFlutterScroll);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _setScrollHeight();
      _scrollController.position.addListener(_setScrollHeight);
    });
  }

  void _onFlutterScroll() {
    // There was a scroll in Flutter (e.g. scrollController.jumpTo called)
    // We need to update our shadow HTML scrolling elements
    _setScrollHeight();

    _heightDiv.scrollTop = _scrollController.position.pixels.toInt();
  }

  void _onNativeScroll(int scrollTop) {
    // There was a scroll in HTML land, update Flutter
    _scrollController.jumpTo(scrollTop.toDouble());
  }

  double? _lastScrollHeight;

  void _setScrollHeight() {
    // This updates a child <div> to have the same height
    // as the scroll contents from Flutter

    var extent = _scrollController.position.maxScrollExtent;
    if (extent == 0) {
      extent = 1;
    }
    final scrollContentsHeight =
        _scrollController.position.viewportDimension + extent;

    if (scrollContentsHeight != _lastScrollHeight) {
      _lastScrollHeight = scrollContentsHeight;
      _heightDiv.style.height = '${scrollContentsHeight}px';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      navigatorObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    navigatorObserver.unsubscribe(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {
      _isForeground = true;
    });
  }

  @override
  void didPushNext() {
    setState(() {
      _isForeground = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isForeground) {
      _scrollDiv.style.display = 'none';
    } else {
      _scrollDiv.style.display = null;
    }
    return Stack(
      children: [
        HtmlElementView(viewType: _viewId),
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: widget.builder(context, _scrollController),
        ),
      ],
    );
  }
}
