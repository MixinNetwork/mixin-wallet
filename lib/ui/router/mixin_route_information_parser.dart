import 'package:flutter/widgets.dart';

import '../../util/logger.dart';
import 'mixin_router_delegate.dart';

class MixinRouteInformationParser extends RouteInformationParser<Uri> {
  @override
  Future<Uri> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = Uri.tryParse(routeInformation.location!);
    i('parseRouteInformation: ${routeInformation.location}');
    return uri ?? MixinRouterDelegate.notFoundUri;
  }

  @override
  RouteInformation? restoreRouteInformation(Uri configuration) {
    i('restoreRouteInformation: $configuration');
    return RouteInformation(location: configuration.toString());
  }
}
