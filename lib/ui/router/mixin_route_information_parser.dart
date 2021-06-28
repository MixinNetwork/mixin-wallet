import 'package:flutter/widgets.dart';

import 'mixin_router_delegate.dart';

class MixinRouteInformationParser extends RouteInformationParser<Uri> {
  @override
  Future<Uri> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = Uri.tryParse(routeInformation.location!);
    return uri ?? notFoundUri;
  }

  @override
  RouteInformation? restoreRouteInformation(Uri configuration) =>
      RouteInformation(location: configuration.toString());
}
