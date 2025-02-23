import 'package:chat_app/Chat/Domain/Models/Message.dart';

abstract class DisplayState{}

class initialDisplay extends DisplayState{}

class loadingMessage extends DisplayState{}

class loadedMessage extends DisplayState{
  List<Message>? listMessage;
  loadedMessage(this.listMessage);
}

class loadFailMessage extends DisplayState{
  String? error;
  loadFailMessage(this.error);
}