import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_catalog/home_screen/home_view.dart';
import 'package:my_catalog/login_screens/login_view.dart';
import 'package:my_catalog/route_generator.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MaterialApp(
    home: Routes(),
    initialRoute: "/",
    onGenerateRoute: RouteGenerator.generateRoute,
    debugShowCheckedModeBanner: false,
  ));
}

class Routes extends StatefulWidget {
  const Routes({super.key});

  @override
  State<Routes> createState() => _RoutesState();
}

class _RoutesState extends State<Routes> {
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return auth.currentUser != null ? const HomeView() : const LoginView();
  }
}