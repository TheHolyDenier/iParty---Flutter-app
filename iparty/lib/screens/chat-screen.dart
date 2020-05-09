import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../models/party.dart';
import '../models/user.dart';
import '../providers/users.dart';

class ChatScreen extends StatefulWidget {
  static final routeName = '/chat';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GlobalKey<DashChatState> _chatViewKey = GlobalKey<DashChatState>();
  final _databaseReference = Firestore.instance;
  Party _party;
  ChatUser _user;

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
                child: SpinKitWanderingCubes(
                  color: Theme.of(context).accentColor,
                  size: 25.0,
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
                user: _user,
                inputDecoration: InputDecoration.collapsed(
                    hintText: 'Escribe tu mensaje aquí...'),
                dateFormat: DateFormat('dd/MM/yyyy'),
                timeFormat: DateFormat('HH:mm'),
                messages: messages,
                showUserAvatar: false,
                showAvatarForEveryMessage: false,
                scrollToBottom: true,
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
                        user: _user));

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
    _party = ModalRoute.of(context).settings.arguments;
    User user = Provider.of<UsersProvider>(context, listen: false).activeUser;
    _user =
        ChatUser(uid: user.uid, avatar: user.imageUrl, name: user.displayName);
  }
}
