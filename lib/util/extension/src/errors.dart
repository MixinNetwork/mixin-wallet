import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:mixin_bot_sdk_dart/mixin_bot_sdk_dart.dart';

import '../extension.dart';

extension MixinErrorHandle on DioException {
  MixinError? get optionMixinError {
    if (error is MixinError) {
      return error! as MixinError;
    }
    return null;
  }
}

class ErrorWithFormattedMessage implements Exception {
  ErrorWithFormattedMessage(this.message);

  final String message;

  @override
  String toString() => message;
}

extension ErrorExtenstion on Object {
  String toDisplayString(BuildContext context) {
    if (this is ErrorWithFormattedMessage) {
      return (this as ErrorWithFormattedMessage).message;
    }
    if (this is MixinError) {
      return (this as MixinError).toDisplayString(context);
    }
    if (this is DioException) {
      final mixinError = (this as DioException).optionMixinError;
      if (mixinError != null) {
        return mixinError.toDisplayString(context);
      } else {
        return context.l10n
            .errorUnknownWithMessage((this as DioException).error.toString());
      }
    }
    return context.l10n.errorUnknownWithMessage(toString());
  }
}

extension GetErrorStringByCode on BuildContext {
  String getMixinErrorStringByCode(int code, String message) {
    switch (code) {
      case transaction:
        return '$code TRANSACTION';
      case badData:
        return l10n.errorBadData;
      case phoneSmsDelivery:
        return l10n.errorPhoneSmsDelivery;
      case recaptchaIsInvalid:
        return l10n.errorRecaptchaIsInvalid;
      case oldVersion:
        return l10n.errorOldVersion(message);
      case phoneInvalidFormat:
        return l10n.errorPhoneInvalidFormat;
      case insufficientIdentityNumber:
        return '$code INSUFFICIENT_IDENTITY_NUMBER';
      case invalidInvitationCode:
        return '$code INVALID_INVITATION_CODE';
      case phoneVerificationCodeInvalid:
        return l10n.errorPhoneVerificationCodeInvalid;
      case phoneVerificationCodeExpired:
        return l10n.errorPhoneVerificationCodeExpired;
      case invalidQrCode:
        return '$code INVALID_QR_CODE';
      case notFound:
        return l10n.errorNotFound;
      case groupChatFull:
        return l10n.errorFullGroup;
      case insufficientBalance:
        return l10n.errorInsufficientBalance;
      case invalidPinFormat:
        return l10n.errorInvalidPinFormat;
      case pinIncorrect:
        return l10n.errorPinIncorrect;
      case tooSmall:
        return l10n.errorTooSmallTransferAmount;
      case tooManyRequest:
        return l10n.errorTooManyRequest;
      case usedPhone:
        return l10n.errorUsedPhone;
      case tooManyStickers:
        return l10n.errorTooManyStickers;
      case blockchainError:
        return l10n.errorBlockchain;
      case invalidAddress:
        return l10n.errorInvalidAddressPlain;
      case withdrawalAmountSmall:
        return l10n.errorTooSmallWithdrawAmount;
      case invalidCodeTooFrequent:
        return l10n.errorInvalidCodeTooFrequent;
      case invalidEmergencyContact:
        return l10n.errorInvalidEmergencyContact;
      case withdrawalMemoFormatIncorrect:
        return l10n.errorWithdrawalMemoFormatIncorrect;
      case favoriteLimit:
      case circleLimit:
        return l10n.errorNumberReachedLimit;
      case forbidden:
        return l10n.accessDenied;
      case server:
      case insufficientPool:
        return l10n.errorServer5xxCode(message);
      case timeInaccurate:
        return '$code TIME_INACCURATE';
      default:
        return '${l10n.errorUnknownWithCode(code)}: $message';
    }
  }
}

extension MixinErrorExt on MixinError {
  String toDisplayString(BuildContext context) =>
      context.getMixinErrorStringByCode(code, description);

  bool get isForbidden => code == forbidden;
}
