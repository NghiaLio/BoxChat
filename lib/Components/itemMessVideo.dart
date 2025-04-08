// ignore_for_file: must_be_immutable

import 'package:chat_app/Authentication/Domains/Entity/User.dart';
import 'package:chat_app/Components/DisplayFile.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../Chat/Domain/Models/Message.dart';

// ignore: camel_case_types
class itemMessVideo extends StatefulWidget {
  final String url;
  UserApp? userOfFile;
  itemMessVideo({super.key, required this.url, this.userOfFile});

  @override
  State<itemMessVideo> createState() => _itemMessVideoState();
}

class _itemMessVideoState extends State<itemMessVideo> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..addListener(() {})
      ..setLooping(true)
      ..initialize().then((value) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
        maxHeight: MediaQuery.of(context).size.height * 0.3,
      ),
      child: _controller.value.isInitialized
          ? ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DisplayFile(
                                        userOfFile: widget.userOfFile,
                                        urlFile: widget.url,
                                        type: MessageType.Video,
                                        videoPlayerController: _controller,
                                      )));
                        },
                        child: VideoPlayer(_controller)),
                    Center(
                      child: IconButton(
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                          });
                        },
                      ),
                    )
                  ],
                ),
              ),
            )
          : Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width * 0.3,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                  color: Theme.of(context).primaryColor.withOpacity(0.5)),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}
