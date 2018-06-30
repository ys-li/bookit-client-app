import 'package:flutter/material.dart';
import 'lang.dart';
import 'UI/MainScreen.dart';
import 'Utils/Accounts.dart';
import 'dart:async';
import 'UI/SplashScreen.dart';
import 'Utils/HelperFunctions.dart';
import 'Utils/Preferences.dart';
import 'Utils/DataVersion.dart';
import 'lang.dart';
import 'Structures/Book.dart';
import 'Utils/FirebaseUtils.dart';

GlobalKey<SplashScreenState> splashKey = new GlobalKey<SplashScreenState>();

void main() {


  runApp(new SplashScreen(key: splashKey));

  Future initAll() async {
    await utilsInit();
    await DataVersion.synchronise();
  }

  Preferences.load().then((c) async {
    BKLocale.setLanguage(c);
    await initAll();
    if (DataVersion.serverUp){

      Account.login(true).then((success){
        if (success == 200){
          fullBookList.init().then((b){
            if (b) {
              runApp(new MyApp());
            }
            else{
              splashKey.currentState.loading = false;
              splashKey.currentState.setHelpText(BKLocale.LOGIN_FAILED);
            }
          });
        }else{
          splashKey.currentState.loading = false;
          splashKey.currentState.setHelpText(BKLocale.WELCOME_SIGNIN);
        }
      });
    }else {
      splashKey.currentState.loading = false;
      splashKey.currentState.setHelpText(BKLocale.SERVER_DOWN);
    }
  });
}
