import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_catalog/route_generator.dart';
import 'package:my_catalog/utils/colors.dart';

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
        toolbarHeight: 80,
        shadowColor: Colors.black45,
        elevation: 10,
        backgroundColor: MyColors.myPrimary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Catalogos", style: const TextStyle(color: Colors.white, fontSize: 25)),
            const SizedBox(width: 10),
             Image.asset('images/Logo.png', width: 100, height: 100)
          ],
        ),
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
      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          fixedColor: MyColors.myPrimary,
          items: const [
            BottomNavigationBarItem(
                label: "Home", icon: Icon(Icons.home)),
            BottomNavigationBarItem(
                label: "Perfil", icon: Icon(Icons.person)),
          ]),
    );
  }
}
