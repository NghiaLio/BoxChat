import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';

import '../Chat/Domain/Models/Message.dart';
import 'Avatar.dart';

class itemMessText extends StatelessWidget {
  final bool isSender;
  final Function()? moveToImage;
  final Function getNameReply;
  final Message message;
  const itemMessText({super.key, required this.isSender, this.moveToImage, required this.getNameReply, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
                          crossAxisAlignment: isSender
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            message.replyingTo!.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 5.0, right: 20, left: 20),
                                    child: Column(
                                      crossAxisAlignment: isSender
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.reply,
                                              size: 18,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                            Text(
                                              getNameReply(message
                                                  .replyingTo!['senderID']),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .surface
                                                      .withOpacity(0.8),
                                                  fontWeight: FontWeight.w400),
                                            )
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: !message.replyingTo!
                                                  .containsKey('link')
                                              ? Text(
                                                  message
                                                      .replyingTo!['message'],
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .surface
                                                          .withOpacity(0.8),
                                                      fontWeight:
                                                          FontWeight.w400),
                                                )
                                              : GestureDetector(
                                                  onTap: moveToImage,
                                                  child: Opacity(
                                                    opacity: 0.5,
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.4,
                                                      child: CacheImage(
                                                          imageUrl: message
                                                                  .replyingTo![
                                                              'link'],
                                                          widthPlachoder:
                                                              MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.4,
                                                          heightPlachoder:
                                                              MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.4),
                                                    ),
                                                  ),
                                                ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            BubbleSpecialThree(
                              seen: message.seen,
                              tail: message.tail,
                              text: message.content,
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
                            ),
                          ],
                        );
  }
}