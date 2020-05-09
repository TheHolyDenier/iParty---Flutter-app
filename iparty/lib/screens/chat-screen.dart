import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iparty/providers/users.dart';
import 'package:provider/provider.dart';

import '../models/party.dart';
import '../models/user.dart';

class ChatScreen extends StatefulWidget {
  static final routeName = '/chat';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<DashChatState> _chatViewKey = GlobalKey<DashChatState>();
  final _databaseReference = Firestore.instance;
  Party _party;
  Map<String, ChatUser> _users = Map();
  String _user;

  List<ChatMessage> messages = List<ChatMessage>();
  var m = List<ChatMessage>();

  var i = 0;

  @override
  Widget build(BuildContext context) {
    _getData();
    return Scaffold(
      appBar: AppBar(
        title: Text('Sala de ${_party.title}'),
      ),
      body: StreamBuilder(
          stream: _databaseReference
              .collection('chats')
              .document('${_party.uid}')
              .collection('messages')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              );
            } else {
              List<DocumentSnapshot> items = snapshot.data.documents;
              var messages =
                  items.map((i) => ChatMessage.fromJson(i.data)).toList();
              return DashChat(
                key: _chatViewKey,
                inverted: false,
                onSend: onSend,
                sendOnEnter: true,
                textInputAction: TextInputAction.send,
                user: _users[_user],
                inputDecoration: InputDecoration.collapsed(
                    hintText: 'Escribe tu mensaje aquí...'),
                dateFormat: DateFormat('dd/MM/yyyy'),
                timeFormat: DateFormat('HH:mm'),
                messages: messages,
                showUserAvatar: false,
                showAvatarForEveryMessage: false,
                scrollToBottom: false,
                onPressAvatar: (ChatUser user) {
                  print('OnPressAvatar: ${user.name}');
                },
                onLongPressAvatar: (ChatUser user) {
                  print('OnLongPressAvatar: ${user.name}');
                },
                inputMaxLines: 5,
                messageContainerPadding: EdgeInsets.only(left: 5.0, right: 5.0),
                alwaysShowSend: true,
                inputTextStyle: TextStyle(fontSize: 16.0),
                inputContainerStyle: BoxDecoration(
                  border: Border.all(width: 0.0),
                  color: Colors.white,
                ),
                onQuickReply: (Reply reply) {
                  setState(() {
                    messages.add(ChatMessage(
                        text: reply.value,
                        createdAt: DateTime.now(),
                        user: _users[_user]));

                    messages = [...messages];
                  });

                  Timer(Duration(milliseconds: 300), () {
                    _chatViewKey.currentState.scrollController
                      ..animateTo(
                        _chatViewKey.currentState.scrollController.position
                            .maxScrollExtent,
                        curve: Curves.easeOut,
                        duration: const Duration(milliseconds: 300),
                      );

                    if (i == 0) {
                      systemMessage();
                      Timer(Duration(milliseconds: 600), () {
                        systemMessage();
                      });
                    } else {
                      systemMessage();
                    }
                  });
                },
                onLoadEarlier: () {
                  print('cargando...');
                },
                shouldShowLoadEarlier: false,
                showTraillingBeforeSend: true,
                trailing: <Widget>[
                  IconButton(
                    icon: Icon(Icons.photo),
                    onPressed: () async {
                      File result = await ImagePicker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                        maxHeight: 400,
                        maxWidth: 400,
                      );

                      if (result != null) {
                        final StorageReference storageRef =
                            FirebaseStorage.instance.ref().child('chat_images');

                        StorageUploadTask uploadTask = storageRef.putFile(
                          result,
                          StorageMetadata(
                            contentType: 'image/jpg',
                          ),
                        );
                        StorageTaskSnapshot download =
                            await uploadTask.onComplete;

                        String url = await download.ref.getDownloadURL();

                        ChatMessage message =
                            ChatMessage(text: '', user: _users[_user], image: url);

                        var documentReference = _databaseReference
                            .collection('chats')
                            .document('${_party.uid}')
                            .collection('messages')
                            .document(DateTime.now()
                                .millisecondsSinceEpoch
                                .toString());

                        _databaseReference.runTransaction((transaction) async {
                          await transaction.set(
                            documentReference,
                            message.toJson(),
                          );
                        });
                      }
                    },
                  )
                ],
              );
            }
          }),
    );
  }

  void systemMessage() {
    Timer(Duration(milliseconds: 300), () {
      if (i < 6) {
        setState(() {
          messages = [...messages, m[i]];
        });
        i++;
      }
      Timer(Duration(milliseconds: 300), () {
        _chatViewKey.currentState.scrollController
          ..animateTo(
            _chatViewKey.currentState.scrollController.position.maxScrollExtent,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
      });
    });
  }

  void onSend(ChatMessage message) {
    print(message.toJson());
    var documentReference = _databaseReference
        .collection('chats')
        .document('${_party.uid}')
        .collection('messages')
        .document(DateTime.now().millisecondsSinceEpoch.toString());

    _databaseReference.runTransaction((transaction) async {
      await transaction.set(
        documentReference,
        message.toJson(),
      );
    });
  }

  void _getData() {
    final ChatArguments args = ModalRoute.of(context).settings.arguments;
    _party = args.party;
    User user = Provider.of<UsersProvider>(context, listen: false).activeUser;
    _user = user.uid;
    var usersList = args.users;
    usersList.forEach((uid, user) {
      _users.putIfAbsent(
          uid,
          () => ChatUser(
              uid: user.uid, avatar: user.imageUrl, name: user.displayName));
    });
  }
}

class ChatArguments {
  final Party party;
  final Map<String, User> users;

  ChatArguments(this.party, this.users);
}
