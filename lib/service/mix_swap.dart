import 'package:mixswap_sdk_dart/mixswap_sdk_dart.dart';

class MixSwap {
  MixSwap._() {
    _client = Client(null);
  }

  static MixSwap? _instance;

  static Client get client => (_instance ??= MixSwap._())._client;

  late Client _client;
}
