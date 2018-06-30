import 'package:flutter/material.dart';
import 'Components/SquareLoader.dart';
import 'Components/EntryChat.dart';
import '../Structures/User.dart';
import '../lang.dart';
import 'Components/SubPageChatConvo.dart';
import '../Utils/FirebaseUtils.dart';

class PageChat extends StatefulWidget{

  static var chatPageKey = new GlobalKey<PageChatState>();
  PageChat() : super(key:chatPageKey);

  @override
  State<PageChat> createState() {
    return new PageChatState();
  }
}

class PageChatState extends State<PageChat>{

  List<User> chattingUsers;
  bool _loading = true;
  @override
  void initState() {
    if (chattingUsers == null){
      FirebaseUtils.setConvos().then((success){
        chattingUsers = User.getUsersWithChats();
        setState(() => _loading = false);
      });
    }else{
      setState(() => _loading = false);
    }
    super.initState();
  }

  void refresh() {
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    var content;

    if (_loading){
      content = new Column(
        children: [
          new Expanded(child: new Container()),
          new Center(child: new SquareLoader()),
          new Expanded(child: new Container()),
        ]
      );
    }else {
      content = new ListView.builder(
        itemCount: chattingUsers.length,
        itemBuilder: (bc, i) {
          return new EntryChat(chattingUsers[i]);
        },
      );
    }

    return new Scaffold(
      appBar: new AppBar(title: new Text(
        BKLocale.BAR_CHAT
      ), centerTitle: false,),
      body: content,
    );

  }
}
