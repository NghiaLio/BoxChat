// ignore_for_file: must_be_immutable, use_build_context_synchronously, non_constant_identifier_names

import 'dart:io';
import 'package:chat_app/Authentication/Domains/Entity/User.dart';
import 'package:chat_app/Components/AleartDiaglog.dart';
import 'package:chat_app/Components/Avatar.dart';
import 'package:chat_app/Person/Presentation/Cubit/personCubit.dart';
import 'package:chat_app/Person/Presentation/Cubit/personEventState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../Components/TopSnackBar.dart';

class SettingAccount extends StatefulWidget {
  UserApp? user;
  SettingAccount({super.key, this.user});

  @override
  State<SettingAccount> createState() => _SettingAccountState();
}

class _SettingAccountState extends State<SettingAccount> {
  bool isEditName = false;
  bool isEditPhone = false;
  bool isEditOtherName = false;
  bool isEditAddress = false;
  bool isUpdatingAvatar = false;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final otherNameController = TextEditingController();
  final addressController = TextEditingController();

  void clickEdit(String text, TextEditingController controller) {
    if (controller == nameController) {
      setState(() {
        isEditName = true;
        nameController.text = text;
      });
    } else if (controller == phoneController) {
      setState(() {
        isEditPhone = true;
        phoneController.text = text;
      });
    } else if (controller == otherNameController) {
      setState(() {
        isEditOtherName = true;
        otherNameController.text = text;
      });
    } else if (controller == addressController) {
      setState(() {
        isEditAddress = true;
        addressController.text = text;
      });
    }
  }

  void tapToChangePassword() {
    showDialog(
        context: context,
        builder: (context) => const dialog(
              text: 'Link change password has been sent to your email',
            ));
  }

  void DoneEdit(TextEditingController controller) async {
    if (controller == nameController) {
      if (controller.text.isNotEmpty) {
        setState(() {
          widget.user!.userName = nameController.text;
        });
        await context.read<Personcubit>().changeName(nameController.text);
      }

      setState(() {
        isEditName = false;
      });
    } else if (controller == phoneController) {
      if (controller.text.isNotEmpty) {
        await context.read<Personcubit>().changePhone(phoneController.text);
      }

      setState(() {
        isEditPhone = false;
      });
    } else if (controller == otherNameController) {
      if (controller.text.isNotEmpty) {
        await context
            .read<Personcubit>()
            .changeOtherName(otherNameController.text);
      }

      setState(() => isEditOtherName = false);
    } else if (controller == addressController) {
      if (controller.text.isNotEmpty) {
        await context.read<Personcubit>().changeAddress(addressController.text);
      }

      setState(() {
        isEditAddress = false;
      });
    }
  }

  Future selectImage(UserApp? user) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final file = File(image.path);
    final isExists = await context
        .read<Personcubit>()
        .checkImage(image.name, widget.user!.id);
    if (!isExists) {
      await context
          .read<Personcubit>()
          .uploadImage(image.name, widget.user!.id, file);
    }
    final urlImage = await context
        .read<Personcubit>()
        .getImageUrl(image.name, widget.user!.id);
    await context.read<Personcubit>().changeAvatar(urlImage);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<Personcubit, personEventState>(
        builder: (context, state) {
      return GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context, widget.user);
                },
                icon: Icon(
                  Icons.arrow_back,
                  size: 30,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
              title: Text('Settings Account',
                  style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.surface,
                      fontWeight: FontWeight.w600)),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  _avatarSetting(widget.user),
                  //Other
                  _otherSetting(
                      'Display Name',
                      widget.user!.userName,
                      isEditName,
                      () => clickEdit(widget.user!.userName, nameController),
                      nameController),
                  _otherSetting(
                      'Other name',
                      widget.user!.otherName!,
                      isEditOtherName,
                      () => clickEdit(
                          widget.user!.otherName!, otherNameController),
                      otherNameController),
                  _otherSetting(
                      'Number Phone',
                      widget.user!.phoneNumber!,
                      isEditPhone,
                      () =>
                          clickEdit(widget.user!.phoneNumber!, phoneController),
                      phoneController),
                  _otherSetting(
                      'Address',
                      widget.user!.address!,
                      isEditAddress,
                      () => clickEdit(widget.user!.address!, addressController),
                      addressController),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.09,
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(15.0)),
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.1)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Password',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface)),
                            GestureDetector(
                              onTap: tapToChangePassword,
                              child: Text(
                                'Click here to change password',
                                style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),
                      ))
                ],
              ),
            )),
      );
    }, listener: (context, state) {
      if (state is updateSuccess) {
        setState(() {
          widget.user = state.user;
          isUpdatingAvatar = false;
        });
        showSnackBar.show_success('Update Success', context);
      } else if (state is updateFailed) {
        showSnackBar.show_error('Update Failed', context);
      } else if (state is updating) {
        setState(() {
          isUpdatingAvatar = true;
        });
      }
    });
  }

  Widget _avatarSetting(UserApp? user) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Row(
        children: [
          //Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                height: size.width * 0.25,
                width: size.width * 0.25,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: widget.user!.avatarUrl!.isEmpty
                    ? const Image(
                        image: AssetImage('assets/images/person.jpg'),
                        fit: BoxFit.fill,
                      )
                    : CacheImage(
                        imageUrl: widget.user!.avatarUrl!,
                        widthPlachoder: 0.25,
                        heightPlachoder: 0.25),
              ),
              isUpdatingAvatar
                  ? Container(
                      height: size.width * 0.25,
                      width: size.width * 0.25,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.6)),
                      alignment: Alignment.center,
                      child: Text(
                        'Updating...',
                        style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).colorScheme.primaryContainer),
                      ),
                    )
                  : Container(),
              GestureDetector(
                onTap: () => selectImage(user),
                child: Container(
                  height: size.width * 0.08,
                  width: size.width * 0.08,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.8)),
                  child: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            width: 20,
          ),
          Text(
            widget.user!.userName,
            style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _otherSetting(String title, String content, bool isEdit,
      Function()? edit, TextEditingController _controller) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Container(
        height: size.height * 0.1 + 15,
        width: size.width,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(15.0)),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurface)),
                !isEdit
                    ? Text(content,
                        style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.surface,
                            fontWeight: FontWeight.w600))
                    : SizedBox(
                        width: size.width * 0.7,
                        child: TextField(
                            controller: _controller,
                            autofocus: true,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero),
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.surface,
                                fontWeight: FontWeight.w600)),
                      )
              ],
            ),
            GestureDetector(
              onTap: () {
                isEdit ? DoneEdit(_controller) : edit!();
              },
              child: Container(
                height: 25,
                width: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    borderRadius: const BorderRadius.all(Radius.circular(5))),
                child: Text(isEdit ? 'Done' : 'Edit',
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
