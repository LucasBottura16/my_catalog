import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_catalog/login_screen/components/login_error_modal.dart';
import 'package:my_catalog/route_generator.dart';

class LoginService {
  static FirebaseAuth auth = FirebaseAuth.instance;

  static Future<void> login(
      String email, String password, BuildContext context) async {
    if (email.isEmpty || password.isEmpty) {
      LoginModalError.showErrorDialog(
          context, 'Por favor, preencha todos os campos.');
      return;
    }

    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushNamedAndRemoveUntil(
          context, RouteGenerator.routeLogin, (_) => false);
    } on FirebaseAuthException catch (e) {
      String errorMessage = LoginModalError.getErrorMessage(e);
      LoginModalError.showErrorDialog(context, errorMessage);
    } catch (e) {
      LoginModalError.showErrorDialog(
          context, 'Ocorreu um erro inesperado. Tente novamente mais tarde.');
    }
  }


  void openInstagram() {
    debugPrint('Abrindo Instagram...');
    // launchUrl(Uri.parse('https://instagram.com/yourprofile'));
  }

  void openWhatsApp() {
    debugPrint('Abrindo WhatsApp...');
    //launchUrl(Uri.parse('https://wa.me/yournumber'));
  }

  void openWebsite() {
    debugPrint('Abrindo Site...');
    //launchUrl(Uri.parse('https://yourwebsite.com'));
  }
}