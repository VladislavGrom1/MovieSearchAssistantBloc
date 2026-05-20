import 'dart:developer';

import 'package:package_info_plus/package_info_plus.dart';

class GetAppInfoUseCase {
  Future<Map<String, String>> call() async{
    try{
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      final appName = packageInfo.appName;
      final appVersion = packageInfo.version;
      final appBuild = packageInfo.buildNumber;

      final appInfo = {
        "appName": appName,
        "appVersion": appVersion,
        "appBuild": appBuild
      };

      return appInfo;
    } catch(e){
      log(e.toString());
      rethrow;
    }
  }
}