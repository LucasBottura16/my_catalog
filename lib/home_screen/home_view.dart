import 'package:flutter/material.dart';

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
            const Text("TEla de home")
          ],
        ),
      ),
    );
  }
}
