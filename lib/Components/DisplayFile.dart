import 'dart:io';
import 'package:chat_app/Chat/Domain/Models/Message.dart';
import 'package:chat_app/Components/Avatar.dart';
import 'package:chat_app/Components/TopSnackBar.dart';
import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../Authentication/Domains/Entity/User.dart';

// ignore: must_be_immutable
class DisplayFile extends StatefulWidget {
  UserApp? userOfFile;
  MessageType type;
  String? urlFile;
  final VideoPlayerController? videoPlayerController;
  DisplayFile(
      {super.key,
      this.urlFile,
      this.userOfFile,
      required this.type,
      this.videoPlayerController});

  @override
  State<DisplayFile> createState() => _DisplayFileState();
}

class _DisplayFileState extends State<DisplayFile> {
  ChewieController? _chewieController;

  Future<void> downloadFile(String url) async {
    try {
      final Directory? downloadsDir = Directory('/storage/emulated/0/Download');
      if (downloadsDir == null || !downloadsDir.existsSync()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy thư mục Downloads.')),
        );
        return;
      }
      final String name = url.split('/').last;
      final file = File('${downloadsDir.path}/$name');

      final response = await Dio().get(url,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            receiveTimeout: const Duration(seconds: 0),
          ));
      if (response.statusCode == 200) {
        final raf = file.openSync(mode: FileMode.write);
        raf.writeFromSync(response.data);
        await raf.close();
        showSnackBar.show_success('Download Success', context);
      }
    } on Exception catch (e) {
      print(e);
      showSnackBar.show_error('Download Fail', context);
    }
  }

  @override
  void initState() {
    if (widget.type == MessageType.Video) {
      _chewieController = ChewieController(
          videoPlayerController: widget.videoPlayerController!,
          autoInitialize: true,
          aspectRatio: widget.videoPlayerController!.value.aspectRatio < 1
              ? 9 / 16
              : 16 / 9,
          // customControls: CustomChewieControls(controller: _chewieController!),
          showControls: true,
          showOptions: false);
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.type == MessageType.Video) {
      widget.videoPlayerController!.pause();
      _chewieController!.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_outlined,
              size: 28,
              color: Colors.white,
            )),
        title: Text(
          widget.userOfFile!.userName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => downloadFile(widget.urlFile!),
            icon: const Icon(Icons.file_download_outlined,
                size: 30, color: Colors.white),
          )
        ],
      ),
      body: Stack(
        // alignment: Alignment.center,
        children: [
          Center(
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: widget.type == MessageType.Image
                      ? CacheImage(
                          imageUrl: widget.urlFile!,
                          widthPlachoder: double.infinity,
                          heightPlachoder: double.infinity)
                      : Chewie(controller: _chewieController!),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 30,
                    width: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'HD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.share_outlined,
                        size: 28, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
