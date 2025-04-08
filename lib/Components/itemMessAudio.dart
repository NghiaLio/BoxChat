// ignore_for_file: camel_case_types

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:just_audio/just_audio.dart';

import '../Chat/Domain/Models/Message.dart';

class itemMessAudio extends StatefulWidget {
  final Message message;

  const itemMessAudio({
    super.key,
    required this.message,
  });

  @override
  State<itemMessAudio> createState() => _itemMessAudioState();
}

class _itemMessAudioState extends State<itemMessAudio> {
  Duration? duration = Duration.zero;
  Duration position = Duration.zero;
  bool isLoading = false;
  bool isPlaying = false;
  bool isPaused = false;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> fetchAudio() async {
    try {
  setState(() {
    isLoading = true;
  });
  final xduration = await _audioPlayer.setUrl(widget.message.content);
  setState(() {
    duration = xduration!;
    isLoading = false;
  });
} on Exception {
  return;
}
  }

  Future<void> _playPauseAudio() async {
    if (isPlaying) {
      _audioPlayer.stop();
      _timer!.cancel();
      setState(() {
        isPlaying = false;
        isPaused = true;
      });
    } else {
      setState(() {
        isPlaying = true;
        isPaused = false;
      });
      _audioPlayer.play();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            position += const Duration(seconds: 1);
            if (position > duration!) {
              position -= const Duration(seconds: 1);
              isPlaying = false;
              isPaused = true;
            }
          });
        }
      });
    }
  }

  void onSeekChanged(double value) async {
    final newPosition = Duration(seconds: value.toInt());
    await _audioPlayer.seek(newPosition);
    if (mounted) {
      setState(() {
        position = newPosition;
      });
    }
  }

  @override
  void initState() {
    fetchAudio();
    super.initState();
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: BubbleNormalAudio(
        onSeekChanged: onSeekChanged,
        onPlayPauseButtonClick: () => _playPauseAudio(),
        isLoading: isLoading,
        duration: duration!.inSeconds.toDouble(),
        position: position.inSeconds.toDouble(),
        isPause: isPaused,
        isPlaying: isPlaying,
        seen: widget.message.seen,
        tail: widget.message.tail,
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }
}
