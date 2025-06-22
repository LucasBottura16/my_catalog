import 'package:flutter/material.dart';
import 'package:my_catalog/login_screen/login_service.dart';
import 'package:my_catalog/login_screen/login_styles.dart';
import 'package:my_catalog/route_generator.dart';
import 'package:my_catalog/utils/colors.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: MyColors.myPrimary,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          TextButton(
                              onPressed: () {},
                              child: Text(
                                "Instagem",
                                style: TextStyle(color: Colors.white),
                              )),
                          SizedBox(
                            width: 10,
                          ),
                          TextButton(
                              onPressed: () {},
                              child: Text("WhatsApp",
                                  style: TextStyle(color: Colors.white))),
                          SizedBox(
                            width: 10,
                          ),
                          TextButton(
                              onPressed: () {},
                              child: Text("Site",
                                  style: TextStyle(color: Colors.white)))
                        ],
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                      Image.asset("images/Logo.png"),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "LOGIN",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        autofocus: true,
                        style: const TextStyle(fontSize: 20, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: TextStyle(color: Colors.white), // Cor do placeholder
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white), // Cor da linha quando não está em foco
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 2.0), // Cor e espessura da linha quando está em foco
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                        ),
                        controller: _usernameController,
                      ),
                      TextField(
                        obscureText: true,
                        style: const TextStyle(fontSize: 20, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Senha",
                          hintStyle: TextStyle(color: Colors.white), // Cor do placeholder
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white), // Cor da linha quando não está em foco
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 2.0), // Cor e espessura da linha quando está em foco
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                        ),
                        controller: _passwordController,
                      ),
                      const SizedBox(height: 25),
                    _isLoading == true ? const Center(child: CircularProgressIndicator(color: Colors.white,)) :
                      ElevatedButton(
                          style: loginButtonStyle,
                          onPressed: () async {
                            setState(() {
                              _isLoading = true;
                            });
                            await LoginService.login(
                              _usernameController.text,
                              _passwordController.text,
                              context,
                            );
                            setState(() {
                              _isLoading = false;
                            });
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "ENTRAR NO APP",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w300,
                                  color: MyColors.myPrimary,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_right,
                                size: 30,
                                weight: 3.5,
                                color: MyColors.myPrimary,
                              )
                            ],
                          )),
                      const SizedBox(
                        height: 15,
                      ),
                      ElevatedButton(
                          style: loginButtonStyle,
                          onPressed: () async {
                            Navigator.pushNamed(
                                context, RouteGenerator.createAccount);
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "CRIAR CONTA NO APP",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w300,
                                  color: MyColors.myPrimary,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_right,
                                size: 30,
                                weight: 3.5,
                                color: MyColors.myPrimary,
                              )
                            ],
                          )),
                      const SizedBox(
                        height: 40,
                      ),
                    ],
                  ),
                ))));
  }
}
