// ignore_for_file: must_be_immutable
import 'package:chat_app/Authentication/Domains/Entity/User.dart';
import 'package:chat_app/Config/Avatar.dart';
import 'package:chat_app/Config/TopSnackBar.dart';
import 'package:chat_app/Config/timePost.dart';
import 'package:chat_app/SocialMedia/Domain/Entities/comment.dart';
import 'package:chat_app/SocialMedia/Presentation/Cubits/SocialCubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Commentscreen extends StatefulWidget {
  List<Comments> listComments;
  UserApp? currentUser;
  int postID;
  int numFavor;
  Commentscreen(
      {super.key,
      required this.listComments,
      this.currentUser,
      required this.postID,
      required this.numFavor});

  @override
  State<Commentscreen> createState() => _CommentscreenState();
}

class _CommentscreenState extends State<Commentscreen> {
  final commentController = TextEditingController();
  bool isHaveContent = false;

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

  void comment() async {
    final Comments cmt = Comments(
        created_at: DateTime.now(),
        content: commentController.text.trim(),
        user_name: widget.currentUser!.userName,
        user_id: widget.currentUser!.id,
        post_id: widget.postID,
        imageUserUrl: widget.currentUser!.avatarUrl!);
    //smoth UI
    setState(() {
      widget.listComments.add(cmt);
    });
    commentController.clear();
    await context.read<Socialcubits>().comment(cmt);
  }

  void answer() {
    print('answer');
    showSnackBar.show_error('Function not upgrade yet', context);
  }

  void pickSticker() {
    showSnackBar.show_error('Function not upgrade yet', context);
  }

  void pickImage() {
    showSnackBar.show_error('Function not upgrade yet', context);
  }

  @override
  void initState() {
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
          DraggableScrollableSheet(
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
                                    color:
                                        Theme.of(context).colorScheme.surface),
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
                                height:
                                    MediaQuery.of(context).size.height * 0.78 +
                                        10,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: ListView.builder(
                                      controller: scrollController,
                                      itemCount: widget.listComments.length,
                                      itemBuilder: (context, index) =>
                                          _itemComment(
                                              widget.listComments[index])),
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
          Container(
            color: const Color.fromARGB(255, 240, 235, 235),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: pickSticker,
                  child: Image.asset(
                    'assets/icons/sticker.png',
                    height: 25,
                    width: 25,
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                    child: TextField(
                  controller: commentController,
                  maxLines: null,
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
                GestureDetector(
                  onTap: pickImage,
                  child: Image.asset(
                    'assets/icons/image.png',
                    height: 25,
                    width: 25,
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                GestureDetector(
                  onTap: () => isHaveContent ? comment() : null,
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
            ),
          )
        ],
      ),
    );
  }

  Widget _itemComment(Comments comment) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
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
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text(
                  comment.content,
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.surface),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              //answer button
              GestureDetector(
                onTap: answer,
                child: Text(
                  'answer',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
