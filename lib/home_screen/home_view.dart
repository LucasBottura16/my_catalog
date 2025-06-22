import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_catalog/route_generator.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("teste de home"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text("TEla de home"),
            TextButton(onPressed: (){
              FirebaseAuth auth = FirebaseAuth.instance;
              auth.signOut().then((value) =>
                  Navigator.pushNamedAndRemoveUntil(
                      context, RouteGenerator.routeLogin, (_) => false));
            }, child: Text("Sair"))
          ],
        ),
      ),
    );
  }
}
