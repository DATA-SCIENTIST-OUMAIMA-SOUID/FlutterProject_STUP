/*import 'package:get_storage/get_storage.dart';
import 'package:super_talab_user/app/data/model/Language.dart';

class LocalStorage {
  //Read
  static Future<Language?> get languageSelected async {
    return await GetStorage().read('lang');
  }

  //write
  static void saveLanguageToDisk(Language language) async {
    await GetStorage().write('lang', language);
  }
}
*/
import 'package:get_storage/get_storage.dart';
import '../data/model/Language.dart';
/*
class LocalStorage {
  // Read
  static Future<Language?> get languageSelected async {
    Map<String, dynamic>? languageMap = await GetStorage().read('lang');
    return languageMap != null
        ? Language(
            languageMap['id'],
            languageMap['flag'],
            languageMap['name'],
            languageMap['languageCode'],
          )
        : null;
  }

  // Write
  static void saveLanguageToDisk(Language language) async {
    await GetStorage().write('lang', {
      'id': language.id,
      'flag': language.flag,
      'name': language.name,
      'languageCode': language.languageCode,
    });
  }
}
*/