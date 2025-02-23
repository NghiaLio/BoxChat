import 'package:chat_app/Authentication/Presentation/Cubit/authCubit.dart';
import 'package:chat_app/Config/TopSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPass extends StatefulWidget {
  const ResetPass({super.key});

  @override
  State<ResetPass> createState() => _ResetPassState();
}

class _ResetPassState extends State<ResetPass> {
  bool isFieldEmpty = false;
  final emailController = TextEditingController();
  void sendEmail() async {
    final String email = emailController.text.trim();
    if (email.isEmpty) {
      showSnackBar.show_error('Nhập email của bạn', context);
    } else {
      final String? result = await context.read<AuthCubit>().resetPass(email);
      if (result == null) {
        showSnackBar.show_error('Email không chính xác', context);
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return dialogSuccess();
            });
      }
    }
  }

  @override
  void initState() {
    emailController.addListener(() {
      if (emailController.text.isEmpty) {
        setState(() {
          isFieldEmpty = false;
        });
      } else {
        setState(() {
          isFieldEmpty = true;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                size: 26,
                color: Theme.of(context).colorScheme.surface,
              )),
          title: Text(
            'Reset Password',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.surface),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your email',
                style: TextStyle(
                    fontSize: 18, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onSurface))),
                style: TextStyle(
                    fontSize: 18, color: Theme.of(context).colorScheme.surface),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: !isFieldEmpty
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.primary),
                      onPressed: sendEmail,
                      child: Text(
                        'Send',
                        style: TextStyle(
                            fontSize: 18,
                            color: !isFieldEmpty
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.secondary),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget dialogSuccess() {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: Container(
        height: MediaQuery.of(context).size.height * 0.14 - 5,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Link reset password is sent to your email',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
            MaterialButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.lightBlue,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
