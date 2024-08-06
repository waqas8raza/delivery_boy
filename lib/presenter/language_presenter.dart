
import 'package:active_flutter_delivery_app/helpers/shared_value_helper.dart';
import 'package:flutter/material.dart';
class LanguagePresenter with ChangeNotifier{
  LanguagePresenter(){
    app_mobile_language.load().then((value){
      app_language.load();
      setLocale( app_mobile_language.$!);
    });
  }
  Locale _locale =Locale(app_mobile_language.$==''?"en":app_mobile_language.$!,'');
  Locale get locale {
    return _locale;
  }

  void setLocale(String code){
    _locale = Locale(code,'');
    notifyListeners();
  }
}