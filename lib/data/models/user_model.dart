import 'package:generated/generated.dart';
import 'package:hive/hive.dart';
part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0) String? apiKey;
  @HiveField(1) String? accountType;
  @HiveField(2) int? limitCount;
  @HiveField(3) int? useCount;

  UserModel({
    this.apiKey,
    this.accountType,
    this.limitCount,
    this.useCount
  });

  factory UserModel.fromObject(ApiKeyResponse object, String apiKey){
    return UserModel(
      apiKey: apiKey,
      accountType: object.accountType.name,
      limitCount: object.dailyQuota.value,
      useCount: object.totalQuota.value,
    );
  }
}