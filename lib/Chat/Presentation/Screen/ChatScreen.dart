// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Authentication/Domains/Entity/User.dart';
import 'package:chat_app/Authentication/Presentation/Cubit/authCubit.dart';
import 'package:chat_app/Chat/Domain/Models/ChatRoom.dart';
import 'package:chat_app/Chat/Presentation/Cubit/DisplayMessage/DisplayCubit.dart';
import 'package:chat_app/Chat/Presentation/Cubit/DisplayMessage/DisplayState.dart';
import 'package:chat_app/Config/Avatar.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../Domain/Models/Message.dart';
import 'Components/DisplayImage.dart';

class ChatScreen extends StatefulWidget {
  final ChatRoom? chat;
  final UserApp? user;
  ChatScreen({super.key, this.chat, this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  UserApp? currentUser, receiveUser;
  bool isShowBottomBar = false;
  ScrollController _scrollController = ScrollController();
  List<bool>? isSelected;

  bool isReplying = false;
  String replyingTo = '';

  void openBottomBar(int indexMessage) {
    setState(() {
      isShowBottomBar = true;
    });
    context.read<DisplayCubit>().selectedMessage(indexMessage);
    print(indexMessage);
  }

  void replyMessage(int indexMessage) {
    setState(() {
      isReplying = true;
      isShowBottomBar = false;
      if (context.read<DisplayCubit>().listMess![indexMessage].type.name ==
          'Text') {
        replyingTo =
            context.read<DisplayCubit>().listMess![indexMessage].content;
      } else {
        replyingTo = '#File Image';
      }
    });
  }

  void cancleReply() {
    setState(() {
      isReplying = false;
    });
    context.read<DisplayCubit>().selectedMessage(null);
  }

  void tapToDisplay() {
    context.read<DisplayCubit>().selectedMessage(null);
    setState(() {
      isShowBottomBar = false;
    });
  }

  void displayImage(String urlImage, UserApp userOfImage) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DisplayImage(
                  urlImage: urlImage,
                  userOfImage: userOfImage,
                )));
  }

  void saveImageToCloudStore(XFile image) async {
    final ID = [currentUser!.id, receiveUser!.id];
    ID.sort();
    final String chatID = ID.join('_');
    //get image url
    final String image_url =
        await context.read<DisplayCubit>().getImageUrl(image.name, chatID);
    //save to cloud_firestore
    final Message mess = Message(
        senderID: currentUser!.id,
        content: image_url,
        type: MessageType.Image,
        sendAt: Timestamp.fromDate(DateTime.now()));
    await context.read<DisplayCubit>().sendMess(mess, receiveUser!.id);
  }

  Future pickImage(String receiveID, String currentID) async {
    final ID = [currentID,receiveID];
    ID.sort();
    final String chatID = ID.join('_');
    try {
      //selected image from gallery
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      //upload image to storage
      //check image
      final bool isExist =
          await context.read<DisplayCubit>().checkImage(image.name,chatID );
      if (isExist) {
        saveImageToCloudStore(image);
      } else {
        //upload
        await context
            .read<DisplayCubit>()
            .uploadImage(image.name, File(image.path), chatID);
        //save
        saveImageToCloudStore(image);
      }
      // print(isExist);
    } on PlatformException catch (e) {
      print(e);
      return;
    }
  }

  void sendMessage(String? content) async {
    final Message mess = Message(
        senderID: currentUser!.id,
        content: content!,
        type: MessageType.Text,
        sendAt: Timestamp.fromDate(DateTime.now()));
    await context.read<DisplayCubit>().sendMess(mess, receiveUser!.id);
  }

  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300), // Hiệu ứng mượt
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    currentUser = context.read<AuthCubit>().userData;
    receiveUser = widget.user;
    context.read<DisplayCubit>().getMessageList(receiveUser!.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SafeArea(
            child: Column(
              children: [
                //Appbar
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          //back button
                          IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.arrow_back,
                                size: 28,
                                color: Theme.of(context).colorScheme.primary,
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                          //Avatar and name
                          Row(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                      height: size.width * 0.13,
                                      width: size.width * 0.13,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                              width: 3)),
                                      clipBehavior: Clip.antiAlias,
                                      child: const Image(
                                        image: AssetImage(
                                            'assets/icons/google.png'),
                                        fit: BoxFit.cover,
                                      )),
                                  Container(
                                    height: 20,
                                    width: 20,
                                    decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle),
                                  )
                                ],
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    receiveUser!.userName,
                                    style: TextStyle(
                                        fontSize: 21,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    'Active now',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontWeight: FontWeight.w400),
                                  )
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                      //action
                      Row(
                        children: [
                          IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.phone,
                                color: Theme.of(context).colorScheme.primary,
                                size: 28,
                              )),
                          IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.video_call,
                                color: Theme.of(context).colorScheme.primary,
                                size: 28,
                              )),
                        ],
                      )
                    ],
                  ),
                ),
                Divider(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  height: 1,
                ),
                //chat display
                Expanded(child: BlocBuilder<DisplayCubit, DisplayState>(
                    builder: (context, state) {
                  print(state);
                  if (state is loadingMessage) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is loadedMessage) {
                    final List<Message> listMess = state.listMessage ?? [];
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_scrollController.hasClients) {
                        scrollToBottom();
                      }
                    });
                    return GestureDetector(
                      onTap: tapToDisplay,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: ListView.builder(
                            controller: _scrollController,
                            itemCount: listMess.length,
                            itemBuilder: (context, index) => _itemMessageChat(
                                listMess[index].content,
                                currentUser!.id == listMess[index].senderID,
                                listMess[index].type.name,
                                listMess[index].sendAt,
                                index)),
                      ),
                    );
                  } else {
                    return const Center(
                      child: Text('Have an error'),
                    );
                  }
                })),
                Divider(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                ),
                //input text
                MessageBar(
                  onSend: (content) => sendMessage(
                    content,
                  ),
                  replying: isReplying,
                  onTapCloseReply: cancleReply,
                  replyingTo: replyingTo,
                  sendButtonColor: Theme.of(context).colorScheme.primary,
                  messageBarColor: Theme.of(context).scaffoldBackgroundColor,
                  textFieldTextStyle: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.surface),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: GestureDetector(
                        onTap: null,
                        child: Icon(
                          Icons.add,
                          size: 30,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GestureDetector(
                        onTap: () => pickImage(receiveUser!.id, currentUser!.id),
                        child: Icon(
                          Icons.image,
                          size: 28,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          bottomBar()
        ],
      ),
    );
  }

  Widget _itemMessageChat(
    String text,
    bool isSender,
    String typeMessage,
    Timestamp time,
    int indexMessage,
  ) {
    int? indexSelected = context.read<DisplayCubit>().indexSelected;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          isSender
              ? const Spacer()
              : Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.width * 0.08,
                      width: MediaQuery.of(context).size.width * 0.08,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 2)),
                      clipBehavior: Clip.antiAlias,
                      child: const Image(
                        image: AssetImage('assets/icons/google.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 10,
                        width: 10,
                        decoration: const BoxDecoration(
                            color: Colors.green, shape: BoxShape.circle),
                      ),
                    )
                  ],
                ),
          Column(
            crossAxisAlignment:
                isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Transform.scale(
                scale: indexSelected == indexMessage ? 1.4 : 1,
                child: GestureDetector(
                  onLongPress: () => openBottomBar(indexMessage),
                  child: typeMessage == 'Text'
                      ? BubbleSpecialThree(
                          text: text,
                          color: isSender
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                          textStyle: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.surface,
                              fontWeight: FontWeight.w400),
                          isSender: isSender,
                          // seen: true,
                        )
                      : SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: BubbleNormalImage(
                            id: text,
                            onTap: () => displayImage(
                                text, isSender ? currentUser! : receiveUser!),
                            onLongPress: null,
                            image: CacheImage(
                                imageUrl: text,
                                widthPlachoder: 0.6,
                                heightPlachoder: 0.4),
                            isSender: isSender,
                          ),
                        ),
                ),
              ),
              Padding(
                padding: isSender
                    ? const EdgeInsets.only(right: 8.0)
                    : const EdgeInsets.only(left: 8.0),
                child: Text(
                  '${time.toDate().hour}:${time.toDate().minute}',
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w400),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget bottomBar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      bottom: isShowBottomBar ? 0 : -MediaQuery.of(context).size.height * 0.09,
      child: Padding(
        padding: isShowBottomBar
            ? EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 10)
            : EdgeInsets.zero,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.09,
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _itemSelectBar(
                    'Reply',
                    Icons.reply,
                    () => replyMessage(
                        context.read<DisplayCubit>().indexSelected!)),
                _itemSelectBar('Copy', Icons.copy_rounded, null),
                _itemSelectBar('Recall', Icons.restart_alt_outlined, null),
                _itemSelectBar('Repeat', Icons.repeat, null),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _itemSelectBar(String text, IconData icon, Function()? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 30,
            ),
            Text(
              text,
              style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.surface,
                  fontWeight: FontWeight.w400),
            )
          ],
        ),
      ),
    );
  }
}
