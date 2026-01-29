import 'package:flutter_bloc/flutter_bloc.dart';
import 'language_state.dart';

import '../../../../core/translation/translation_helper.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(LanguageInitialState());
  static LanguageCubit get(context) => BlocProvider.of(context);
  bool isEnglish = true;

  void changeLanguage() {
    isEnglish = !isEnglish;
    if (isEnglish) {
      TranslationHelper.changeLanguage(false);
    } else {
      TranslationHelper.changeLanguage(true);
    }
    emit(LanguageChangeState());
  }
}
