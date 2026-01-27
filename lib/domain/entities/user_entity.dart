
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable{
  final String? apiKey;
  final String? accountType;
  final int? limitCount;
  final int? useCount;

  const UserEntity({
    this.apiKey, 
    this.accountType,
    this.limitCount,
    this.useCount
    });
  
  @override
  List<Object?> get props => [apiKey, accountType, limitCount, useCount];
}