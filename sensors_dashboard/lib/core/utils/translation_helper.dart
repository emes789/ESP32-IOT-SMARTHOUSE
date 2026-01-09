import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../../services/translation_service.dart';
import 'package:provider/provider.dart';
class TranslationHelper {
  static String getCurrentLanguage(BuildContext context) {
    return Provider.of<TranslationService>(context, listen: false).currentLanguage;
  }
  static String getCurrentLanguageDisplayName(BuildContext context) {
    final currentLang = getCurrentLanguage(context);
    return AppConstants.languageNames[currentLang] ?? 'Polski';
  }
  static String translateText(BuildContext context, String text) {
    return Provider.of<TranslationService>(context, listen: false).translateTextSync(text);
  }
  static String translateWithEllipsis(BuildContext context, String text, int maxLength) {
    final translated = translateText(context, text);
    if (translated.length <= maxLength) return translated;
    return '${translated.substring(0, maxLength)}...';
  }
}
