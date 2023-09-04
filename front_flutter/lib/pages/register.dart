import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late String email;
  late String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Register Page')),
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            children: [
              TextField(
                obscureText: false,
                decoration: InputDecoration(hintText: 'email'),
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
              TextField(
                obscureText: true,
                decoration: InputDecoration(hintText: 'password'),
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
              const Text(
                  "Check for a robust password (at least 8 characters, with upper/lowercase and digits)"),
              InkWell(
                  onTap: () async {
                    HttpService httpService = HttpService();
                    await httpService.register(email, password, context);
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
                        "Register",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ))
            ],
          ),
        )
        // ignore: avoid_unnecessary_containers
        );
  }
}
