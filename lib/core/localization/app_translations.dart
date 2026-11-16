import 'package:get/get.dart';
import 'bn_bd.dart';
import 'en_us.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'bn_BD': bnBD,
        'en_US': enUS,
      };
}
