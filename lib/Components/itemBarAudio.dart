import 'dart:math';
import 'package:flutter/material.dart';

class WaveformAnimation extends StatelessWidget {
  final AnimationController controller;

  const WaveformAnimation({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(20, (index) {
            double value = sin(controller.value * 2 * pi + index * pi / 4);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 30 + value * 20,
              width: 6,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );
      },
    );
  }
}

// ignore: camel_case_types, must_be_immutable
class itemBarAudio extends StatefulWidget {
  Function()? cancleRecord;
  Function()? stopRecord;
  Function()? confirmRecord;
  String textTime;
  itemBarAudio({
    super.key,
    this.cancleRecord,
    this.stopRecord,
    this.confirmRecord,
    required this.textTime,
  });

  @override
  State<itemBarAudio> createState() => _itemBarAudioState();
}

class _itemBarAudioState extends State<itemBarAudio>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isStopRecording = false;
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

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
        height: MediaQuery.of(context).size.height * 0.05,
        margin: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                onPressed: widget.cancleRecord,
                icon: Icon(
                  Icons.cancel,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                )),
            Text(
              widget.textTime,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
            WaveformAnimation(controller: _controller),
            IconButton(
                onPressed: () {
                  if (isStopRecording) {
                    widget.confirmRecord!();
                    
                  } else {
                    widget.stopRecord!();
                    setState(() {
                      isStopRecording = true;
                      // _controller.stop();
                    });
                  }
                },
                icon: Icon(
                  !isStopRecording ? Icons.stop_circle : Icons.check,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                )),
          ],
        ));
  }
}
