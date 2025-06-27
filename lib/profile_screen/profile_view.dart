import 'package:flutter/material.dart';
import 'package:my_catalog/profile_screen/profile_service.dart';
import 'package:my_catalog/profile_screen/profile_style.dart';
import 'package:my_catalog/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final TextEditingController _controllerBiography = TextEditingController();
  String _nome = "";
  String _state = "";
  String _category = "";
  String _photo = "";
  String _biography = "";
  String _typeAccount = "";

  _verifyAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nome = prefs.getString('name') ?? '';
      _photo = prefs.getString('image') ?? '';
      _state = prefs.getString('state') ?? '';
      _category = prefs.getString('category') ?? '';
      _biography = prefs.getString('biography') ?? '';
      _typeAccount = prefs.getString('typeAccount') ?? '';
    });
    _controllerBiography.text = _biography;
  }

  _saveBiography() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (_controllerBiography.text == "") {
      debugPrint("biografia vazia");
      _biography = prefs.getString('biografia') ?? '';
    } else {
      debugPrint("biografia salva");
      await ProfileService.saveBiography(_controllerBiography.text);

      setState(() {
        _biography = _controllerBiography.text;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _verifyAccount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            width: 120,
                            height: 120,
                            color: MyColors.myPrimary,
                            child: _photo == ""
                                ? Image.asset("images/Logo.png")
                                : Image.network(
                                    _photo,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                          )),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_nome,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Text("$_state - $_category",
                              style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 35),
                          GestureDetector(
                            onTap: () {
                              ProfileService.logoutUser(context);
                            },
                            child: const Text("logout",
                                style: TextStyle(color: Colors.red)),
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        "Biografia",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                          onPressed: () {
                            _biography == ""
                                ? _saveBiography()
                                : setState(() {
                                    _biography = "";
                                  });
                          },
                          child: Text(_biography == "" ? "Salvar" : "Editar",
                              style:
                                  const TextStyle(color: MyColors.myPrimary))),
                    ],
                  ),
                  _biography == ""
                      ? TextField(
                          decoration: const InputDecoration(
                              hintText: "Descreva sua Biografia"),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          controller: _controllerBiography,
                        )
                      : Text(_biography),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 60,
                    child: ElevatedButton(
                        style: profileButtonStyle,
                        onPressed: () async {},
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "PEDIDOS",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right,
                              size: 30,
                              weight: 3.5,
                              color: Colors.white,
                            )
                          ],
                        )),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Container(
                color: MyColors.myPrimary,
                padding: EdgeInsets.symmetric(vertical: 20),
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Text(
                              _typeAccount == "company"
                                  ? "Meus Catálogos"
                                  : "Catálogos Salvos",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white)),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            SizedBox(width: 20),
                            SizedBox(
                                width: 300,
                                child: Card(
                                  elevation: 4,
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: 120,
                                          color: MyColors.myTertiary,
                                          child: Image.asset("images/Logo.png"),
                                        ),
                                      ),
                                      Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.40,
                                                  child: Text(
                                                      "NOME DO CATALOGO",
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              SizedBox(
                                                height: 30,
                                                child: ElevatedButton(
                                                  onPressed: () {},
                                                  style: ButtonStyle(
                                                    shape: WidgetStateProperty
                                                        .resolveWith<
                                                            OutlinedBorder>(
                                                      (Set<WidgetState>
                                                          states) {
                                                        return RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(7),
                                                        );
                                                      },
                                                    ),
                                                    backgroundColor:
                                                        WidgetStateProperty.all<
                                                                Color>(
                                                            MyColors.myPrimary),
                                                  ),
                                                  child: Text("Editar",
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ),
                                              )
                                            ],
                                          )),
                                    ],
                                  ),
                                )),
                            const SizedBox(width: 10)
                          ],
                        ),
                      ],
                    )))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Adicionar',
        backgroundColor: MyColors.myPrimary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation
          .startFloat, // Move para o canto inferior esquerdo
    );
  }
}
