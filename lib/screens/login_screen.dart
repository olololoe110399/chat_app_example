import 'package:chat_app/providers/auth_provider.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    switch (auth.status) {
      case Status.authenticating:
        Fluttertoast.showToast(msg: "Đang xác nhận");
        break;
      case Status.authenticated:
        Fluttertoast.showToast(msg: "Login thành công");
        break;
      case Status.authenticateError:
        Fluttertoast.showToast(msg: "Login không thành công");
        break;
      case Status.authenticateCanceled:
        Fluttertoast.showToast(msg: "Từ chối login");
        break;
      default:
    }
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login Screen'),
            ElevatedButton(
              onPressed: () async {
                final isLoggedIn = await auth.handleGoogleSignIn();
                if (isLoggedIn) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()));
                }
              },
              child: const Text('SIGN IN WITH GOOGLE'),
            ),
          ],
        ),
      ),
    );
  }
}
