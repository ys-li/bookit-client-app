import 'package:flutter/material.dart';
import 'package:bookit/UI/Themes.dart';
import 'ui_utils.dart';
import '../../Structures/User.dart';
import 'SubPageChatConvo.dart';

class EntryChat extends StatefulWidget{

  User user;
  String caption;
  VoidCallback onPressed;
  EntryChat(this.user, {this.onPressed, Key key}) : super(key: key){
    caption = user.chats[0].imageUrl == null ? user.chats[0].content : "Photo";
  }

  @override
  State<EntryChat> createState() {
    return new EntryChatState();
  }
}

class EntryChatState extends State<EntryChat>{

  @override
  Widget build(BuildContext context) {
    Widget title;
    Widget suppInfo;
    Widget arrow;

    title = new Text(widget.user.username, style: NormalStyle.copyWith(fontSize:20.0));
    suppInfo = new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          title,
          new Text(widget.caption, style: LightStyle.copyWith(fontSize: 12.0)),
        ]
    );

    arrow = new Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          addPadding(new Icon(Icons.arrow_forward_ios, color: Colors.grey.withAlpha(55)), const EdgeInsets.all(2.5)),
        ]
    );
    return new InkWell(child: new Container(
      padding: const EdgeInsets.all(10.0),
      height: 100.0,
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          addPadding(new CircleAvatar(
            radius: 27.0,
            backgroundImage: widget.user.profilePicture == null ? null : new NetworkImage(widget.user.profilePicture),
            child: widget.user.profilePicture == null ? new Text(widget.user.username[0], style: LightStyle) : null,
          ),const EdgeInsets.only(right: 15.0)),
          new Expanded(
            child: suppInfo,
          ),
          ((widget.user.chats[0].id ?? 0) > widget.user.lastReadChatID) ? addPadding(new Text("⚫", style: NormalStyle.copyWith(color: Colors.amber)), const EdgeInsets.all(2.5)): new Container(),
          arrow
        ]
      )
    ),
    onTap:(){
      if (widget.onPressed != null) widget.onPressed();

      Navigator.of(context).push(new MaterialPageRoute<Null>(builder: (context){
        return new SubPageChatConvo(widget.user);
      }));
    });
  }
}