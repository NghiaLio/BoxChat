import 'package:chat_app/Authentication/Presentation/Cubit/authCubit.dart';
import 'package:chat_app/Authentication/Presentation/Screen/Register.dart';
import 'package:chat_app/Authentication/Presentation/Screen/ResetPass.dart';
import 'package:chat_app/Config/TopSnackBar.dart';
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

  void backBtn() {
    // Navigator.pop(context);
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
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          leading: IconButton(
              onPressed: backBtn,
              icon: Icon(
                Icons.arrow_back,
                size: 24,
                color: Theme.of(context).colorScheme.surface,
              )),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 50,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    itemLogin('assets/icons/facebook.png'),
                    const SizedBox(
                      width: 15,
                    ),
                    itemLogin('assets/icons/google.png'),
                  ],
                ),
                //divider
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Container(
                      height: 1,
                      width: size.width * 0.41,
                      color: const Color.fromRGBO(205, 209, 208, 1.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 11.0),
                      child: Text(
                        'OR',
                        style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                    Container(
                      height: 1,
                      width: size.width * 0.41,
                      color: const Color.fromRGBO(205, 209, 208, 1.0),
                    ),
                  ],
                ),
                //Form
                const SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your email',
                      style: TextStyle(
                          fontSize: 18,
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
                          fontSize: 20,
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
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500),
                    ),
                    TextField(
                      controller: passController,
                      decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8.0),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface))),
                      style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.surface),
                    ),
                  ],
                ),
                //Btn
                SizedBox(
                  height: size.height * 0.20,
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
                        ? CircularProgressIndicator()
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: tapToResetPass,
                        child: Text(
                          'Forgot password',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      GestureDetector(
                        onTap: tapToRegister,
                        child: Text(
                          'Register',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary),
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
