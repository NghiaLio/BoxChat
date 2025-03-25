import 'package:chat_app/Authentication/Presentation/Cubit/authCubit.dart';
import 'package:chat_app/Components/CircleProgressIndicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isFieldEmpty = false;
  bool passVisible = true;
  bool confirmPassVisible = true;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController ConfirmPassController = TextEditingController();

  void backBtn() {
    Navigator.pop(context);
  }

  void passVisibleBtn() {
    setState(() {
      passVisible = !passVisible;
    });
  }

  void confirmPassVisibleBtn() {
    setState(() {
      confirmPassVisible = !confirmPassVisible;
    });
  }

  void tapToRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      await context.read<AuthCubit>().register(nameController.text.trim(),
          emailController.text.trim(), passController.text.trim());
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  //check Empty
  void checkEmpty() {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passController.text.isEmpty ||
        ConfirmPassController.text.isEmpty) {
      setState(() {
        isFieldEmpty = false;
      });
    } else {
      setState(() {
        isFieldEmpty = true;
      });
    }
  }

  //validated
  String? validatedEmail(String? value) {
    final bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value!);
    if (value.isEmpty) {
      return 'Enter your email';
    }
    if (!emailValid) {
      return 'Email not correct';
    }
    return null;
  }

  String? validatedName(String? value) {
    if (value!.isEmpty) {
      return 'Enter your name';
    }
    if (value.length < 4) {
      return 'Name length is more 4 character';
    }
    return null;
  }

  String? validatedPass(String? value) {
    if (value!.isEmpty) {
      return 'Enter your password';
    }
    if (value.length < 6) {
      return 'Password length is more 6 character';
    }
    return null;
  }

  String? validatedConfirmpass(String? value) {
    if (value!.isEmpty) {
      return 'Enter your confirm password';
    }
    if (value != passController.text.trim()) {
      return 'Confirm password not true';
    }
    return null;
  }

  @override
  void initState() {
    nameController.addListener(checkEmpty);
    emailController.addListener(checkEmpty);
    passController.addListener(checkEmpty);
    ConfirmPassController.addListener(checkEmpty);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
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
                'Sign up with Email',
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
                'Get chatting with friends and family today by\n signing up for our chat app!',
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 40,
              ),
              //Form
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      formField(nameController, 'Your name',
                          (value) => validatedName(value), false, null),
                      const SizedBox(
                        height: 20,
                      ),
                      formField(emailController, 'Your email',
                          (value) => validatedEmail(value), false, null),
                      const SizedBox(
                        height: 20,
                      ),
                      formField(
                          passController,
                          'Password',
                          (value) => validatedPass(value),
                          passVisible,
                          Icon(
                            passVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 22,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      formField(
                          ConfirmPassController,
                          'Confirm Password',
                          (value) => validatedConfirmpass(value),
                          confirmPassVisible,
                          Icon(
                            confirmPassVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 22,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ))
                    ],
                  )),
              //Btn
              SizedBox(
                height: size.height * 0.15,
              ),
              GestureDetector(
                onTap: tapToRegister,
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
                          height_width: 0.08,
                          color: Theme.of(context).colorScheme.primaryContainer)
                      : Text(
                          'Create an account',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              color: !isFieldEmpty
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).colorScheme.secondary),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget formField(TextEditingController _controller, String nameField,
      Function(String?) validated, bool isVisible, Widget? suffixIcon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nameField,
          style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500),
        ),
        TextFormField(
          controller: _controller,
          validator: (value) => validated(value),
          obscureText: isVisible,
          decoration: InputDecoration(
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.onSurface))),
          style: TextStyle(
              fontSize: 20, color: Theme.of(context).colorScheme.surface),
        ),
      ],
    );
  }
}
