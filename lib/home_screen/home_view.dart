import 'package:flutter/material.dart';
import 'package:my_catalog/catalog_screen/catalog_view.dart';
import 'package:my_catalog/home_screen/home_service.dart';
import 'package:my_catalog/profile_screen/profile_view.dart';
import 'package:my_catalog/utils/colors.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _indexCurrent = 0;

  @override
  void initState() {
    // TODO: implement initState
    HomeService.findCollectionByUid();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [const CatalogView(), const ProfileView()];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        shadowColor: Colors.black45,
        elevation: 10,
        backgroundColor: MyColors.myPrimary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Catalogos",
                style: const TextStyle(color: Colors.white, fontSize: 25)),
            const SizedBox(width: 10),
            Image.asset('images/Logo.png', width: 100, height: 100)
          ],
        ),
      ),
      body: screens[_indexCurrent],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        fixedColor: MyColors.myPrimary,
        currentIndex: _indexCurrent,
        onTap: (index) {
          setState(() {
            _indexCurrent = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: "Home",
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: "Perfil",
            icon: Icon(Icons.person),
          ),
        ],
        unselectedItemColor: Colors.grey, // Ou a cor que preferir para os itens inativos
      ),
    );
  }
}
