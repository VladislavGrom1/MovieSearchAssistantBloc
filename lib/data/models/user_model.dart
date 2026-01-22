
import 'package:generated/generated.dart';

class UserModel {
  String? apiKey;
  String? accountType;
  int? limitCount;
  int? useCount;

  UserModel({
    this.apiKey,
    this.accountType,
    this.limitCount,
    this.useCount
  });

  factory UserModel.fromObject(ApiKeyResponse object){
    return UserModel(
      apiKey: null,
      accountType: object.accountType.name,
      limitCount: object.dailyQuota.value,
      useCount: object.totalQuota.value,
    );
  }
}