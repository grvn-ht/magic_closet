//import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late String email;
  late String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Login Page')),
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            children: [
              TextField(
                obscureText: false,
                decoration: const InputDecoration(hintText: 'email'),
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              TextField(
                obscureText: true,
                decoration: const InputDecoration(hintText: 'password'),
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
              InkWell(
                  onTap: () async {
                    HttpService httpService =
                        HttpService(); // Create an instance of HttpService
                    await httpService.login(
                        email, password, context); // Call login on the instance
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(25)),
                    child: const Center(
                      child: Text(
                        "Login",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ))
            ],
          ),
        ));
  }
}
