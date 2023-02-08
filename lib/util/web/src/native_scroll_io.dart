import 'package:flutter/material.dart';

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

class _NativeScrollBuilderState extends State<NativeScrollBuilder> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _scrollController);

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }
}
