import 'package:url_launcher/url_launcher.dart';

class OpenUrlUseCase {
  Future<bool> call(String? url) async {
    try{
      if(url == null || url.isEmpty){
        return false;
      } else{
        final uri = Uri.parse(url);
        if(await canLaunchUrl(uri)){
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication
          );
          return true;
        } else{
          return false;
        }
      }
    } catch(e){
      rethrow;
    }
  }
}