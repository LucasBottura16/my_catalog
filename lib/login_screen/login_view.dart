import 'package:flutter/material.dart';
import 'package:my_catalog/login_screen/login_service.dart';
import 'package:my_catalog/login_screen/login_styles.dart';
import 'package:my_catalog/route_generator.dart';
import 'package:my_catalog/utils/colors.dart';
import 'package:my_catalog/utils/custom_input_field.dart';

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
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: MyColors.myPrimary,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          TextButton(
                              onPressed: () {},
                              child: Row(
                                children: [
                                  Image.asset("images/icon_insta.png"),
                                  const SizedBox(width: 5),
                                  const Text("Instagram",
                                      style: TextStyle(color: Colors.white))
                                ],
                              )),
                          TextButton(
                              onPressed: () {},
                              child: Row(
                                children: [
                                  Image.asset("images/icon_whats.png"),
                                  const SizedBox(width: 5),
                                  const Text("WhatsApp",
                                      style: TextStyle(color: Colors.white))
                                ],
                              )),
                          TextButton(
                              onPressed: () {},
                              child: Row(
                                children: [
                                  Image.asset("images/icon_site.png"),
                                  const SizedBox(width: 5),
                                  const Text("Site",
                                      style: TextStyle(color: Colors.white))
                                ],
                              ))
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
                      CustomInputField(
                        controller: _usernameController,
                        labelText: "Sem texto",
                        hintText: "Email",
                        spacingHeight: 0,
                        hintStyle: TextStyle(color: Colors.white),
                        autoFocus: true,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(fontSize: 20, color: Colors.white),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2.0),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10.0),
                      ),
                      CustomInputField(
                        controller: _passwordController,
                        labelText: "Sem texto",
                        hintText: "Senha",
                        spacingHeight: 0,
                        hintStyle: TextStyle(color: Colors.white),
                        obscureText: true,
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2.0),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10.0),
                      ),
                      const SizedBox(height: 25),
                      _isLoading == true
                          ? const Center(
                              child: CircularProgressIndicator(
                              color: Colors.white,
                            ))
                          : ElevatedButton(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
