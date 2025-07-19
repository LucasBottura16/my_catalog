import 'package:flutter/material.dart';
import 'package:my_catalog/login_screen/login_service.dart';
import 'package:my_catalog/route_generator.dart';
import 'package:my_catalog/utils/colors.dart';
import 'package:my_catalog/utils/customs_components/custom_button.dart';
import 'package:my_catalog/utils/customs_components/custom_input_field.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 20 : 50,
                  vertical: 20,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 30,
                ),
                decoration: BoxDecoration(
                  color: MyColors.myPrimary,
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset("images/icon_whats.png"),
                              const SizedBox(width: 5),
                              const Text(
                                "Suporte",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset("images/icon_site.png"),
                              const SizedBox(width: 5),
                              const Text(
                                "Site",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Logo
                    Center(
                      child: Image.asset(
                        "images/Logo.png",
                        width: isSmallScreen ? 150 : 200,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Título LOGIN
                    const Text(
                      "LOGIN",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30),

                    // Campo de Email
                    CustomInputField(
                      controller: _usernameController,
                      labelText: "Sem texto",
                      hintText: "Email",
                      spacingHeight: 0,
                      hintStyle: const TextStyle(color: Colors.white),
                      autoFocus: true,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2.0),
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 12.0),
                    ),

                    const SizedBox(height: 25),

                    // Campo de Senha
                    CustomInputField(
                      controller: _passwordController,
                      labelText: "Sem texto",
                      hintText: "Senha",
                      spacingHeight: 0,
                      hintStyle: const TextStyle(color: Colors.white),
                      obscureText: true,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2.0),
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 12.0),
                    ),

                    const SizedBox(height: 35),

                    // Botão de Entrar
                    CustomButton(
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
                      title: "ENTRAR NO APP",
                      titleColor: MyColors.myPrimary,
                      titleSize: 18,
                      titleFontWeight: FontWeight.w300,
                      icon: Icons.keyboard_arrow_right,
                      iconColor: MyColors.myPrimary,
                      iconSize: 30,
                      isLoading: _isLoading,
                      loadingColor: Colors.white,
                    ),

                    const SizedBox(height: 20),

                    // Botão de Criar Conta
                    CustomButton(
                      onPressed: () async {
                        Navigator.pushNamed(
                            context, RouteGenerator.createAccount);
                      },
                      title: "CRIAR CONTA NO APP",
                      titleColor: MyColors.myPrimary,
                      titleSize: 18,
                      titleFontWeight: FontWeight.w300,
                      icon: Icons.keyboard_arrow_right,
                      iconColor: MyColors.myPrimary,
                      iconSize: 30,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}