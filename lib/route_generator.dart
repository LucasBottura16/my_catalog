import 'package:flutter/material.dart';
import 'package:my_catalog/catalog_screen/add_catalog_screen/add_catalog_view.dart';
import 'package:my_catalog/create_account_screen/create_account_view.dart';
import 'package:my_catalog/home_screen/home_view.dart';
import 'package:my_catalog/main.dart';

class RouteGenerator {
  static const String routeLogin = "/routes";
  static const String home = "/home";
  static const String createAccount = "/createAccount";
  static const String addCatalog = "/addCatalog";

  static var args;

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    args = settings.arguments;

    switch (settings.name) {
      case routeLogin:
        return MaterialPageRoute(builder: (_) => const Routes());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeView());
        case createAccount:
          return MaterialPageRoute(builder: (_) => const CreateAccountView());
          case addCatalog:
            return MaterialPageRoute(builder: (_) => const AddCatalogView());
      default:
        _errorRoute();
    }
    return null;
  }

  static Route<dynamic>? _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Tela não encontrada"),
        ),
        body: const Center(
          child: Text("Tela não encontrada"),
        ),
      );
    });
  }
}
