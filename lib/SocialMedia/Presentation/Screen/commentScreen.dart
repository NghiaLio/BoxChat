// ignore_for_file: must_be_immutable
import 'dart:io';
import 'package:chat_app/Authentication/Domains/Entity/User.dart';
import 'package:chat_app/Chat/Domain/Models/Message.dart';
import 'package:chat_app/Components/Avatar.dart';
import 'package:chat_app/Components/DisplayFile.dart';
import 'package:chat_app/Components/TopSnackBar.dart';
import 'package:chat_app/config/timePost.dart';
import 'package:chat_app/SocialMedia/Domain/Entities/comment.dart';
import 'package:chat_app/SocialMedia/Presentation/Cubits/SocialCubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class Commentscreen extends StatefulWidget {
  List<Comments> listComments;
  List<Comments> listAnswerOfComment;
  UserApp? currentUser;
  int postID;
  int numFavor;
  Commentscreen(
      {super.key,
      required this.listComments,
      this.currentUser,
      required this.postID,
      required this.numFavor,
      required this.listAnswerOfComment});

  @override
  State<Commentscreen> createState() => _CommentscreenState();
}

class _CommentscreenState extends State<Commentscreen> {
  final commentController = TextEditingController();
  bool isHaveContent = false;
  bool isAnswer = false;
  XFile? imageSelected;
  FocusNode textFiledFocus = FocusNode();
  int? commentID;
  late List<Comments> _listComments;
  void _onTextFieldChange() {
    if (commentController.text.isNotEmpty) {
      setState(() {
        isHaveContent = true;
      });
    } else {
      setState(() {
        isHaveContent = false;
      });
    }
  }

  void comment(int? commentID) async {
    //get image url
    String imageUrl = '';
    if (imageSelected != null) {
      final isExist = await context
          .read<Socialcubits>()
          .checkImage(imageSelected!.name, widget.currentUser!.id, 'comments');
      if (isExist) {
        imageUrl = await context.read<Socialcubits>().getImageUrl(
            imageSelected!.name, widget.currentUser!.id, 'comments');
      } else {
        await context.read<Socialcubits>().uploadImage(imageSelected!.name,
            widget.currentUser!.id, File(imageSelected!.path), 'comments');
        imageUrl = await context.read<Socialcubits>().getImageUrl(
            imageSelected!.name, widget.currentUser!.id, 'comments');
      }
    }
    final Comments cmt = Comments(
        created_at: DateTime.now(),
        content: commentController.text.trim(),
        user_name: widget.currentUser!.userName,
        user_id: widget.currentUser!.id,
        post_id: widget.postID,
        imageUserUrl: widget.currentUser!.avatarUrl!,
        imageCmtUrl: imageUrl,
        answerComment: commentID);
    //smoth UI
    setState(() {
      if (isAnswer) {
        widget.listAnswerOfComment.add(cmt);
      } else {
        _listComments.add(cmt);
        print(widget.listComments.length);
      }
      isAnswer = false;
      imageSelected = null;
    });
    commentController.clear();
    textFiledFocus.unfocus();
    await context.read<Socialcubits>().comment(cmt);
  }

  void deleteComment(Comments cmt) async {
    if (cmt.user_id == widget.currentUser!.id) {
      //smothUI
      if (cmt.answerComment == null) {
        _listComments.removeWhere((value) => cmt.id == value.id);
      } else {
        widget.listAnswerOfComment.removeWhere((value) => cmt.id == value.id);
      }
      await context
          .read<Socialcubits>()
          .deleteComment(cmt.id!)
          .catchError((onError) {
        if (cmt.answerComment == null) {
          _listComments.add(cmt);
        } else {
          widget.listAnswerOfComment.add(cmt);
        }
      });
      showSnackBar.show_success('Delete Success', context);
    } else {
      showSnackBar.show_error('Not permission', context);
    }
  }

  void answer(Comments cmt) {
    setState(() {
      isAnswer = true;
      if (cmt.answerComment != null) {
        commentID = cmt.answerComment;
      } else {
        commentID = cmt.id;
      }
    });
    FocusScope.of(context).requestFocus(textFiledFocus);
  }

  void pickSticker() {
    showSnackBar.show_error('Function not upgrade yet', context);
  }

  void pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        isHaveContent = true;
        imageSelected = XFile(image.path);
      });
    }
  }

  void unSelectedImage() {
    setState(() {
      imageSelected = null;
    });
  }

  void openImage(Comments comment) {
    final UserApp? userComment =
        UserApp(id: comment.user_id, userName: comment.user_name, email: '');
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => DisplayFile(
                  userOfFile: userComment,
                  type: MessageType.Image,
                  urlFile: comment.imageCmtUrl,
                )));
  }

  @override
  void initState() {
    _listComments =
        widget.listComments.where((cmt) => cmt.answerComment == null).toList();
    commentController.addListener(_onTextFieldChange);
    super.initState();
  }

  @override
  void dispose() {
    commentController.removeListener(_onTextFieldChange);
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.08),
            child: DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.55,
                minChildSize: 0.4,
                maxChildSize: 0.95,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                  return GestureDetector(
                    onTap: FocusScope.of(context).unfocus,
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: [
                          //divider
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Center(
                              child: Container(
                                height: 5,
                                width: 80,
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.5),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20))),
                              ),
                            ),
                          ),
                          //number of like
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.favorite_rounded,
                                  size: 20,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(
                                  width: 5.0,
                                ),
                                Text(
                                  widget.numFavor.toString(),
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          //list comment
                          widget.listComments.isEmpty
                              ? Center(
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/icons/comment.png',
                                        height: 100,
                                        width: 100,
                                      ),
                                      Text(
                                        'No Comments Yet',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            fontWeight: FontWeight.w500),
                                      )
                                    ],
                                  ),
                                )
                              : SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                          0.78 +
                                      10,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: ListView.builder(
                                        controller: scrollController,
                                        itemCount: _listComments.length,
                                        itemBuilder: (context, index) {
                                          final List<Comments> listAnswer =
                                              widget.listAnswerOfComment
                                                  .where((cmt) =>
                                                      cmt.answerComment ==
                                                      _listComments[index].id)
                                                  .toList();
                                          return Column(
                                            children: [
                                              _itemComment(
                                                  _listComments[index]),
                                              for (int i = 0;
                                                  i < listAnswer.length;
                                                  i++)
                                                _itemComment(listAnswer[i])
                                            ],
                                          );
                                        }),
                                  ),
                                ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
          Container(
            constraints: BoxConstraints(
              maxHeight: imageSelected != null
                  ? MediaQuery.of(context).size.height * 0.25
                  : MediaQuery.of(context).size.height * 0.08,
            ),
            color: const Color.fromARGB(255, 240, 235, 235),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                imageSelected != null
                    ? Container(
                        height: MediaQuery.of(context).size.height * 0.15,
                        // width: MediaQuery.of(context).size.width * 0.5,

                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.5,
                            minWidth: MediaQuery.of(context).size.width * 0.25),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                child: Image(
                                    image:
                                        FileImage(File(imageSelected!.path)))),
                            GestureDetector(
                              onTap: unSelectedImage,
                              child: Icon(
                                Icons.cancel,
                                size: 26,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(),
                Row(
                  children: [
                    imageSelected == null
                        ? GestureDetector(
                            onTap: pickSticker,
                            child: Image.asset(
                              'assets/icons/sticker.png',
                              height: 25,
                              width: 25,
                            ),
                          )
                        : Container(),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                        child: TextField(
                      controller: commentController,
                      maxLines: null,
                      focusNode: textFiledFocus,
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Enter your comment',
                          border: InputBorder.none),
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.surface),
                    )),
                    const SizedBox(
                      width: 15,
                    ),
                    imageSelected == null
                        ? GestureDetector(
                            onTap: pickImage,
                            child: Image.asset(
                              'assets/icons/image.png',
                              height: 25,
                              width: 25,
                            ),
                          )
                        : Container(),
                    const SizedBox(
                      width: 15,
                    ),
                    GestureDetector(
                      onTap: () => isHaveContent ? comment(commentID) : null,
                      child: Icon(
                        Icons.send,
                        size: 30,
                        color: isHaveContent
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _itemComment(Comments comment) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      width: comment.answerComment == null
          ? MediaQuery.of(context).size.width
          : MediaQuery.of(context).size.width * 0.85,
      margin: comment.answerComment == null
          ? EdgeInsets.zero
          : EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Avatar
          Container(
            height: MediaQuery.of(context).size.width * 0.1,
            width: MediaQuery.of(context).size.width * 0.1,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: comment.imageUserUrl.isNotEmpty
                  ? CacheImage(
                      imageUrl: comment.imageUserUrl,
                      widthPlachoder: 0.1,
                      heightPlachoder: 0.1)
                  : Image.asset('assets/images/person.jpg'),
            ),
          ),
          //behind
          const SizedBox(
            width: 10.0,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //name
              Row(
                children: [
                  Text(
                    comment.user_name,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.surface),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Text(
                    Timepost.timeBefore(comment.created_at!),
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface),
                  )
                ],
              ),
              //comment
              SizedBox(
                width: comment.answerComment == null
                    ? MediaQuery.of(context).size.width * 0.7 - 10
                    : MediaQuery.of(context).size.width * 0.6 - 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.content,
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.surface),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                    comment.imageCmtUrl!.isNotEmpty
                        ? GestureDetector(
                            onTap: () => openImage(comment),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.width * 0.4,
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                child: CacheImage(
                                    imageUrl: comment.imageCmtUrl!,
                                    widthPlachoder:
                                        MediaQuery.of(context).size.width * 0.3,
                                    heightPlachoder:
                                        MediaQuery.of(context).size.width *
                                            0.6),
                              ),
                            ),
                          )
                        : const SizedBox()
                  ],
                ),
              ),
              //answer button
              GestureDetector(
                onTap: () => answer(comment),
                child: Text(
                  'answer',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface),
                ),
              )
            ],
          ),

          PopupMenuButton(
              onSelected: (value) => deleteComment(comment),
              icon: const Icon(
                Icons.more_horiz_outlined,
                size: 20,
              ),
              color: Theme.of(context).colorScheme.primaryContainer,
              padding: EdgeInsets.zero,
              menuPadding: EdgeInsets.zero,
              itemBuilder: (context) => [
                    const PopupMenuItem(
                        value: '',
                        child: Text(
                          'Delete comment',
                          style: TextStyle(fontSize: 14),
                        ))
                  ])
        ],
      ),
    );
  }
}
