import 'package:dio/dio.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';

extension MixinErrorHandle on DioError {
  MixinError? get optionMixinError {
    if (error is MixinError) {
      return error as MixinError;
    }
    return null;
  }
}

extension MixinErrorExtenstion on MixinError {
  bool get isForbidden => code == forbidden;
}
