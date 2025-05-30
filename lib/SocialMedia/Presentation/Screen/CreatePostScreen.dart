// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:io';

import 'package:chat_app/Authentication/Domains/Entity/User.dart';
import 'package:chat_app/Components/TopSnackBar.dart';
import 'package:chat_app/SocialMedia/Presentation/Cubits/SocialCubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../Components/Avatar.dart';
import '../../Domain/Entities/post.dart';

class Createpostscreen extends StatefulWidget {
  UserApp? currentUser;
  bool isShowPickedImage;
  bool isEditPost;
  Posts? post;
  Createpostscreen(
      {super.key,
      this.currentUser,
      required this.isShowPickedImage,
      required this.isEditPost,
      this.post});

  @override
  State<Createpostscreen> createState() => _CreatepostscreenState();
}

class _CreatepostscreenState extends State<Createpostscreen> {
  bool isHaveContent = false;
  bool isVisibilityKeyBoard = false;
  final FocusNode _focusNode = FocusNode();
  final contentController = TextEditingController();

  XFile? fileSelected;

  void _onFocusNodeChange() {
    setState(() {
      isVisibilityKeyBoard = !isVisibilityKeyBoard;
    });
  }

  void _onTextFieldChange() {
    if (contentController.text.isNotEmpty) {
      setState(() {
        isHaveContent = true;
      });
    } else {
      setState(() {
        isHaveContent = false;
      });
    }
  }

  void pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        isHaveContent = true;
        fileSelected = XFile(image.path);
      });
    }
  }

  void pickCamera() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        isHaveContent = true;
        fileSelected = XFile(image.path);
      });
    }
  }

  void createPost() async {
    Navigator.pop(context);
    final String content = contentController.text.trim();
    if (fileSelected != null) {
      await context.read<Socialcubits>().createPost(content, widget.currentUser,
          fileSelected!.name, File(fileSelected!.path));
    } else {
      await context
          .read<Socialcubits>()
          .createPost(content, widget.currentUser, null, null);
    }
  }

  void updatePost() async {
    final String content = contentController.text.trim();
    if (fileSelected != null) {
      await context
          .read<Socialcubits>()
          .updatePost(content, widget.currentUser, fileSelected!.name,
              File(fileSelected!.path), widget.post!)
          .then((onValue) => Navigator.pop(context, 200))
          .catchError((onError) => Navigator.pop(context, null));
    } else {
      await context
          .read<Socialcubits>()
          .updatePost(content, widget.currentUser, null, null,widget.post!)
          .then((onValue) => Navigator.pop(context, 200))
          .catchError((onError) => Navigator.pop(context, null));
    }
  }

  void removeImage() {
    if (widget.isEditPost) {
      setState(() {
        widget.post!.post_image_url = '';
      });
    } else {
      setState(() {
        fileSelected = null;
      });
    }
  }

  void actionNotSuport() {
    showSnackBar.show_error('Not Suport', context);
  }

  @override
  void initState() {
    _focusNode.addListener(_onFocusNodeChange);
    contentController.addListener(_onTextFieldChange);
    widget.isShowPickedImage ? pickImage() : null;
    if (widget.isEditPost) {
      contentController.text = widget.post!.content;
    }
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusNodeChange);
    _focusNode.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 1,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                size: 28,
                color: Theme.of(context).colorScheme.surface,
              )),
          title: Text(
            widget.isEditPost ? 'Edit Post' : 'Create Post',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.surface),
          ),
          actions: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    backgroundColor: isHaveContent
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.3)),
                onPressed: () {
                  if (isHaveContent) {
                    widget.isEditPost ? updatePost() : createPost();
                  } else {
                    null;
                  }
                },
                child: Text(
                  widget.isEditPost ? 'save' : 'post',
                  style: TextStyle(
                      fontSize: 18,
                      color: isHaveContent
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.onSurface),
                ))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: FocusScope.of(context).unfocus,
            child: Column(
              children: [
                //Avatar and name
                Row(
                  children: [
                    Avatar(
                      height_width: 0.15,
                      user: widget.currentUser,
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(
                      widget.currentUser!.userName,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.surface),
                    ),
                  ],
                ),
                // input content
                Expanded(child: _inputContent(context)),
                //other select
                _otherSelect(context)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            controller: contentController,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'What do you think?',
                hintStyle: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary)),
            maxLines: null,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.surface),
          ),
          if (!widget.isEditPost && fileSelected != null)
            _displayImageSelected(Image.file(
              File(fileSelected!.path),
              fit: BoxFit.contain,
            )),
          if (widget.isEditPost &&
              widget.post != null &&
              widget.post!.post_image_url.isNotEmpty)
            _displayImageSelected(Image.network(
              widget.post!.post_image_url,
              fit: BoxFit.contain,
            )),
        ],
      ),
    );
  }

  Widget _displayImageSelected(Widget image) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.25,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(top: 10.0),
        child: Stack(
          children: [
            image,
            Positioned(
              right: 10,
              top: -10,
              child: IconButton(
                  onPressed: removeImage,
                  icon: Icon(
                    Icons.close,
                    size: 30,
                    color: Theme.of(context).colorScheme.primary,
                  )),
            ),
          ],
        ));
  }

  Widget _otherSelect(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: MediaQuery.of(context).size.height * 0.1 + 21,
      margin: EdgeInsets.only(
          bottom: isVisibilityKeyBoard
              ? MediaQuery.of(context).viewInsets.bottom
              : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              _itemUp('Music', Icons.music_note, () => actionNotSuport()),
              const SizedBox(
                width: 8.0,
              ),
              _itemUp('Background', Icons.abc, () => actionNotSuport())
            ],
          ),
          Divider(
              thickness: 1,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          Row(
            children: [
              _itemDown(() => actionNotSuport(), Icons.sentiment_neutral_sharp),
              const Spacer(),
              _itemDown(() => pickImage(), Icons.image),
              _itemDown(() => pickCamera(), Icons.camera),
              _itemDown(() => actionNotSuport(), Icons.location_on)
            ],
          )
        ],
      ),
    );
  }

  Widget _itemUp(String text, IconData icon, Function()? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
            border: Border.all(
                width: 2, color: Theme.of(context).colorScheme.primary),
            borderRadius: const BorderRadius.all(Radius.circular(8.0))),
        alignment: Alignment.center,
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            Text(
              text,
              style: TextStyle(
                  fontSize: 14, color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemDown(Function()? onPressed, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            size: 30,
            color: Theme.of(context).colorScheme.primary,
          )),
    );
  }
}
