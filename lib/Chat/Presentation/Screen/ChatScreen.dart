// ignore_for_file: use_build_context_synchronously, must_be_immutable, depend_on_referenced_packages

import 'dart:async';
import 'dart:io';

// ignore: unused_import
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Authentication/Domains/Entity/User.dart';
import 'package:chat_app/Authentication/Presentation/Cubit/authCubit.dart';
import 'package:chat_app/Chat/Domain/Models/ChatRoom.dart';
import 'package:chat_app/Chat/Presentation/Cubit/DisplayMessage/DisplayCubit.dart';
import 'package:chat_app/Chat/Presentation/Cubit/DisplayMessage/DisplayState.dart';
import 'package:chat_app/Chat/Presentation/Screen/HomeScreen.dart';
import 'package:chat_app/Components/Avatar.dart';
import 'package:chat_app/Components/PlaceHolder.dart';
import 'package:chat_app/Components/TopSnackBar.dart';
import 'package:chat_app/Components/itemBarAudio.dart';
import 'package:chat_app/Components/itemMessImage.dart';
import 'package:chat_app/Components/itemMessVideo.dart';
import 'package:chat_app/config/timePost.dart';
import 'package:chat_app/Person/Presentation/Screen/Profile.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';

import '../../../Components/itemMessAudio.dart';
import '../../../Components/itemMessText.dart';
import '../../Domain/Models/Message.dart';
import '../../../Components/DisplayFile.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ChatScreen extends StatefulWidget {
  final ChatRoom? chat;
  final UserApp? user;
  bool isFromHome;
  ChatScreen({super.key, this.chat, this.user,required this.isFromHome});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  UserApp? currentUser, receiveUser;
  bool isShowBottomBar = false;
  bool isRecoding = false;
  Duration _duration = Duration.zero;
  Timer? _timer;
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  String pathRec = '';
  ScrollController _scrollController = ScrollController();
  List<bool>? isSelected;

  bool isReplying = false;
  Map replyingTo = {};

  void backButon() {
    cancleRecord();
    if(!widget.isFromHome){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c)=>HomeScreen()));
    }
    Navigator.pop(context);
  }

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
        replyingTo = {
          'message':
              context.read<DisplayCubit>().listMess![indexMessage].content,
          'senderID':
              context.read<DisplayCubit>().listMess![indexMessage].senderID
        };
      } else {
        replyingTo = {
          'message': '#File Image',
          "link": context.read<DisplayCubit>().listMess![indexMessage].content,
          'senderID':
              context.read<DisplayCubit>().listMess![indexMessage].senderID
        };
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

  void displayFile(String urlImage, UserApp userOfImage, MessageType type) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DisplayFile(
                  urlFile: urlImage,
                  type: type,
                  userOfFile: userOfImage,
                )));
  }

  void saveFileToCloudStore(XFile file, MessageType messType) async {
    final ID = [currentUser!.id, receiveUser!.id];
    ID.sort();
    final String chatID = ID.join('_');
    //get image url
    final String image_url =
        await context.read<DisplayCubit>().getImageUrl(file.name, chatID);
    //save to cloud_firestore
    final Message mess = Message(
        senderID: currentUser!.id,
        content: image_url,
        type: messType,
        sendAt: Timestamp.fromDate(DateTime.now()),
        seen: false,
        tail: true);
    await context.read<DisplayCubit>().sendMess(currentUser!,receiveUser!,mess);
    await context.read<DisplayCubit>().unTailMess(receiveUser!.id);
  }

  void processFilePicked(XFile? file, MessageType messType) async {
    final ID = [currentUser!.id, receiveUser!.id];
    ID.sort();
    final String chatID = ID.join('_');
    if (file == null) return;
    //upload image to storage
    //check image
    final bool isExist =
        await context.read<DisplayCubit>().checkImage(file.name, chatID);
    if (isExist) {
      saveFileToCloudStore(file, messType);
    } else {
      //upload
      await context
          .read<DisplayCubit>()
          .uploadImage(file.name, File(file.path), chatID);
      //save
      saveFileToCloudStore(file, messType);
    }
  }

  Future pickImage() async {
    try {
      //selected image from gallery
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      processFilePicked(image, MessageType.Image);
    } on PlatformException catch (e) {
      print(e);
      return;
    }
  }

  Future pickImageByCamera() async {
    try {
      //selected image from camera
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      processFilePicked(image, MessageType.Image);
    } on PlatformException catch (e) {
      print(e);
      return;
    }
  }

  Future pickVideo() async {
    try {
      final video = await ImagePicker().pickVideo(source: ImageSource.gallery);
      processFilePicked(video, MessageType.Video);
    } on PlatformException catch (e) {
      print(e);
      return;
    }
  }

  void sendMessage(String? content, Map? replying) async {
    print(replying);
    final Message mess = Message(
        senderID: currentUser!.id,
        content: content!,
        type: MessageType.Text,
        sendAt: Timestamp.fromDate(DateTime.now()),
        seen: false,
        tail: true,
        replyingTo: replying);
    cancleReply();
    await context.read<DisplayCubit>().sendMess(currentUser!,receiveUser!,mess);
    await context.read<DisplayCubit>().unTailMess(receiveUser!.id);
  }

  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300), // Hiệu ứng mượt
      curve: Curves.easeOut,
    );
  }

  void viewProfiles(UserApp? userProfile) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => Profile(
                  userInformation: userProfile,
                )));
  }

  String getNameReply(String id) {
    if (currentUser!.id == id) {
      return 'You replied yourself';
    } else {
      return 'You replied ${receiveUser!.userName}';
    }
  }

  void copyText(int indexMessage) {
    setState(() {
      isShowBottomBar = false;
    });
    context.read<DisplayCubit>().selectedMessage(null);
    Clipboard.setData(ClipboardData(
        text: context.read<DisplayCubit>().listMess![indexMessage].content));
    showSnackBar.show_success('Copied', context);
  }

  void delMessage(int indexMessage) async {
    setState(() {
      isShowBottomBar = false;
    });
    context.read<DisplayCubit>().selectedMessage(null);
    if (context.read<DisplayCubit>().listMess![indexMessage].senderID !=
        currentUser!.id) {
      showSnackBar.show_error('You can not delete this message', context);
      return;
    }

    await context.read<DisplayCubit>().deleteMessage(receiveUser!.id,
        context.read<DisplayCubit>().listMess![indexMessage].sendAt);
  }

  void moveToImage() {
    showSnackBar.show_error('Not support', context);
  }

  List<PopupMenuEntry> listAction = const [
    PopupMenuItem(
      value: 'Camera',
      child: Row(
        children: [
          Icon(Icons.camera_alt),
          const SizedBox(
            width: 10,
          ),
          Text('Camera')
        ],
      ),
    ),
    PopupMenuItem(
      value: 'Audio',
      child: Row(
        children: [
          Icon(Icons.mic),
          SizedBox(
            width: 10,
          ),
          Text('Audio')
        ],
      ),
    ),
    PopupMenuItem(
      value: 'Video',
      child: Row(
        children: [
          Icon(Icons.video_collection_sharp),
          SizedBox(
            width: 10,
          ),
          Text('Video')
        ],
      ),
    ),
  ];

  void moreAction(Object? value) {
    if (value == null) {
      showSnackBar.show_error('Not support', context);
    } else if (value == 'Camera') {
      pickImageByCamera();
    } else if (value == 'Audio') {
      setState(() {
        isRecoding = true;
      });
      _startRecording();
    } else {
      pickVideo();
    }
  }

  Future<void> _startRecording() async {
    print('object');
    try {
      if (await _recorder.hasPermission()) {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String filePath = path.join(
            appDir.path, 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a');
        _recorder.start(const RecordConfig(), path: filePath);
        setState(() {
          isRecoding = true;
          _duration = Duration.zero;
        });

        _timer = Timer.periodic(Duration(seconds: 1), (timer) {
          setState(() {
            _duration += Duration(seconds: 1);
          });
        });
      }
    } catch (e) {
      print("Error starting recording: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      final pathRecord = await _recorder.stop();
      setState(() {
        pathRec = pathRecord!;
        _timer?.cancel();
      });
      print(pathRec);
      //playAudio(pathRec);
      await _audioPlayer.setFilePath(pathRec);
      await _audioPlayer.play();
    } catch (e) {
      print("Error stopping recording: $e");
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  void cancleRecord() async {
    _timer?.cancel();
    _audioPlayer.dispose();
    setState(() {
      _duration = Duration.zero;
      pathRec = '';
      isRecoding = false;
    });
    print('path ' + pathRec);
  }

  void confirmRecord() async {
    processFilePicked(XFile(pathRec), MessageType.Audio);
    setState(() {
      isRecoding = false;
      pathRec = '';
      _duration = Duration.zero;
    });
  }

  
  @override
  void initState() {
    currentUser = context.read<AuthCubit>().userData;
    receiveUser = widget.user;
    context.read<DisplayCubit>().getMessageList(receiveUser!.id);
    context.read<DisplayCubit>().seenMess(receiveUser!.id);
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
                              onPressed: backButon,
                              icon: Icon(
                                Icons.arrow_back,
                                size: 28,
                                color: Theme.of(context).colorScheme.primary,
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                          //Avatar and name
                          GestureDetector(
                            onTap: () => viewProfiles(receiveUser),
                            child: Row(
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
                                                    .primary,
                                                width: 3)),
                                        padding: const EdgeInsets.all(5.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: receiveUser!.avatarUrl!.isEmpty
                                              ? const Image(
                                                  image: AssetImage(
                                                      'assets/images/person.jpg'),
                                                  fit: BoxFit.cover,
                                                )
                                              : CacheImage(
                                                  imageUrl:
                                                      widget.user!.avatarUrl!,
                                                  widthPlachoder:
                                                      size.width * 0.13,
                                                  heightPlachoder:
                                                      size.width * 0.13),
                                        )),
                                    receiveUser!.isOnline!
                                        ? Container(
                                            height: 15,
                                            width: 15,
                                            decoration: const BoxDecoration(
                                                color: Colors.green,
                                                shape: BoxShape.circle),
                                          )
                                        : Container()
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
                                          fontSize: 18,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      receiveUser!.isOnline!
                                          ? 'Active now'
                                          : Timepost.timeBefore(receiveUser!
                                              .lastActive!
                                              .toDate()),
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.w400),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      //action
                      IconButton(
                          onPressed: () => moreAction(null),
                          icon: Icon(
                            Icons.more_vert,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          )),
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
                      // child: Loading(height_width: MediaQuery.of(context).size.width*0.1 , color: Theme.of(context).colorScheme.primary),
                      child: PlaceHolder(),
                    );
                  } else if (state is loadedMessage) {
                    //khi tin nhan moi den ma van ben trong man hinh tro chuyen thi tin nhan se cap nhat da seen
                    context.read<DisplayCubit>().seenMess(receiveUser!.id);
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
                                listMess[index],
                                currentUser!.id == listMess[index].senderID,
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
                !isRecoding
                    ? MessageBar(
                        onSend: (content) => sendMessage(content, replyingTo),
                        replying: isReplying,
                        onTapCloseReply: cancleReply,
                        replyingTo:
                            replyingTo.isEmpty ? '' : replyingTo['message'],
                        sendButtonColor: Theme.of(context).colorScheme.primary,
                        messageBarColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        textFieldTextStyle: TextStyle(
                            fontSize: 17,
                            color: Theme.of(context).colorScheme.surface),
                        actions: [
                          PopupMenuButton(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            icon: Icon(
                              Icons.add,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onSelected: (value) => moreAction(value),
                            itemBuilder: (context) => listAction,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: GestureDetector(
                              onTap: () => pickImage(),
                              child: Icon(
                                Icons.image,
                                size: 28,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      )
                    : itemBarAudio(
                        textTime: formatDuration(_duration),
                        cancleRecord: () => cancleRecord(),
                        stopRecord: () => _stopRecording(),
                        confirmRecord: () => confirmRecord(),
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
    Message message,
    bool isSender,
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
                    Avatar(
                      height_width: 0.08,
                      user: receiveUser,
                    ),
                    receiveUser!.isOnline!
                        ? Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              height: 10,
                              width: 10,
                              decoration: const BoxDecoration(
                                  color: Colors.green, shape: BoxShape.circle),
                            ),
                          )
                        : Container()
                  ],
                ),
          Column(
            crossAxisAlignment:
                isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (message.type == MessageType.Text)
                Transform.scale(
                  scale: indexSelected == indexMessage ? 1.2 : 1,
                  child: GestureDetector(
                      onLongPress: () => openBottomBar(indexMessage),
                      child: itemMessText(
                        message: message,
                        isSender: isSender,
                        getNameReply: getNameReply,
                        moveToImage: moveToImage,
                      )),
                ),
              if (message.type == MessageType.Audio)
                Transform.scale(
                  scale: indexSelected == indexMessage ? 1.2 : 1,
                  child: GestureDetector(
                    onLongPress: () => openBottomBar(indexMessage),
                    child: itemMessAudio(
                      message: message,
                    ),
                  ),
                ),
              if (message.type == MessageType.Video)
                Transform.scale(
                  scale: indexSelected == indexMessage ? 1.2 : 1,
                  child: GestureDetector(
                    onLongPress: () => openBottomBar(indexMessage),
                    child: itemMessVideo(
                      url: message.content,
                      userOfFile: isSender ? currentUser : receiveUser,
                    ),
                  ),
                ),
              if (message.type == MessageType.Image)
                Transform.scale(
                  scale: indexSelected == indexMessage ? 1.2 : 1,
                  child: GestureDetector(
                    onLongPress: () => openBottomBar(indexMessage),
                    child: itemMessImage(
                      message: message,
                      currentUser: currentUser,
                      receiveUser: receiveUser,
                      isSender: isSender,
                      displayImage: displayFile,
                    ),
                  ),
                ),
              Padding(
                padding: isSender
                    ? const EdgeInsets.only(right: 8.0)
                    : const EdgeInsets.only(left: 8.0),
                child: Text(
                  '${message.sendAt.toDate().hour}:${message.sendAt.toDate().minute}',
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
                bottom: MediaQuery.of(context).viewInsets.bottom + 5)
            : EdgeInsets.zero,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.09 + 5,
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
                _itemSelectBar(
                    'Copy',
                    Icons.copy_rounded,
                    () =>
                        copyText(context.read<DisplayCubit>().indexSelected!)),
                _itemSelectBar(
                    'Delete',
                    Icons.restart_alt_outlined,
                    () => delMessage(
                        context.read<DisplayCubit>().indexSelected!)),
                _itemSelectBar('Repeat', Icons.repeat, () {
                  showSnackBar.show_error('Not support', context);
                }),
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
