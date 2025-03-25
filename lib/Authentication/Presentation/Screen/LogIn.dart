import 'package:chat_app/Authentication/Presentation/Cubit/authCubit.dart';
import 'package:chat_app/Authentication/Presentation/Screen/Register.dart';
import 'package:chat_app/Authentication/Presentation/Screen/ResetPass.dart';
import 'package:chat_app/Components/CircleProgressIndicator.dart';
import 'package:chat_app/Components/TopSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  bool isLoading = false;
  bool isFieldEmpty = false;
  bool passVisible = true;

  void tapToLogin() async {
    String email = emailController.text.trim();
    String pass = passController.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      showSnackBar.show_error('Nhập thông tin', context);
    } else {
      setState(() {
        isLoading = true;
      });
      await context.read<AuthCubit>().login(email, pass);
      setState(() {
        isLoading = false;
      });
      // context.read<HomeChatCubit>().getListUser();
      // context.read<HomeChatCubit>().getAllChat();
    }
  }

  void _onFieldChange() {
    if (emailController.text.isEmpty || passController.text.isEmpty) {
      setState(() {
        isFieldEmpty = false;
      });
    } else {
      setState(() {
        isFieldEmpty = true;
      });
    }
  }

  void tapToResetPass() {
    Navigator.push(context, MaterialPageRoute(builder: (c) => ResetPass()));
  }

  void tapToRegister() {
    Navigator.push(context, MaterialPageRoute(builder: (c) => Register()));
  }

  void visiblePass() {
    setState(() {
      passVisible = !passVisible;
    });
  }

  @override
  void initState() {
    emailController.addListener(_onFieldChange);
    passController.addListener(_onFieldChange);
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: size.height * 0.18,
                ),
                //Title
                Text(
                  'Log in to ChatBox',
                  style: TextStyle(
                      fontSize: 22,
                      color: Theme.of(context).colorScheme.surface,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 20,
                ),
                //content
                Text(
                  'Welcome back! Sign in using your social \naccount or email to continue us',
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
                //other login
                const SizedBox(
                  height: 20,
                ),
                //Form
                SizedBox(
                  height: size.height * 0.08,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your email',
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8.0),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface))),
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.surface),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password',
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500),
                    ),
                    TextField(
                      controller: passController,
                      obscureText: passVisible,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: visiblePass,
                            icon: Icon(
                              !passVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                              size: 22,
                            ),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8.0),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface))),
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.surface),
                    ),
                  ],
                ),
                //Btn
                SizedBox(
                  height: size.height * 0.2,
                ),
                GestureDetector(
                  onTap: tapToLogin,
                  child: Container(
                    width: size.width * 0.9,
                    height: size.height * 0.07,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: !isFieldEmpty
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.primary,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15))),
                    child: isLoading
                        ? Loading(
                            height_width: size.width * 0.08,
                            color:
                                Theme.of(context).colorScheme.primaryContainer)
                        : Text(
                            'Login',
                            style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                color: !isFieldEmpty
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Theme.of(context).colorScheme.secondary),
                          ),
                  ),
                ),
                Container(
                  width: size.width * 0.9,
                  height: size.height * 0.07,
                  alignment: Alignment.center,
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: tapToResetPass,
                          child: Center(
                            child: Text(
                              'Forgot password',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: tapToRegister,
                          child: Center(
                            child: Text(
                              'Register',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget itemLogin(String iconPath) {
    return Container(
      height: MediaQuery.of(context).size.width * 0.15,
      width: MediaQuery.of(context).size.width * 0.15,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        border: Border(),
      ),
      child: Image(
        image: AssetImage(iconPath),
        fit: BoxFit.cover,
      ),
    );
  }
}
