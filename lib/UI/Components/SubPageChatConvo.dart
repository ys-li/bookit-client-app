import 'package:flutter/material.dart';
import '../../Utils/FirebaseUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math';
import 'dart:io';
import '../../Utils/Accounts.dart';
import '../../Structures/User.dart';
import '../../Structures/Chats.dart';
import 'dart:async';
import '../Themes.dart';
import '../../Utils/HelperFunctions.dart';
import '../../lang.dart';
import '../../Utils/NetCode.dart';
import 'SquareLoader.dart';
import '../../Structures/Package.dart';
import '../ModalBook.dart';
import 'dart:convert';

class SubPageChatConvo extends StatefulWidget{

  final User partner;
  static var subChatPageKey = new GlobalKey<SubPageChatConvoState>();

  SubPageChatConvo(this.partner) : super(key: subChatPageKey);

  @override
  State createState() {
    return new SubPageChatConvoState();
  }
}

enum OverviewState{
  Normal,
  Dealt,
  Cancelled,
}

class SubPageChatConvoState extends State<SubPageChatConvo> with TickerProviderStateMixin, WidgetsBindingObserver{
  final TextEditingController _textController = new TextEditingController();
  Stream _stream;
  bool _isComposing = false;
  bool _loading = true;




  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!widget.partner.oldChatPopulated){
      FirebaseUtils.populateChatsFromDisk(widget.partner).then((chats){
        widget.partner.chats.addAll(chats);
        widget.partner.oldChatPopulated = true;
        setState(() => _loading = false);
      });

    }
    FirebaseUtils.getMessage(widget.partner, widget.partner.lastReadChatID, false).then((chats) {
      chats.removeWhere((cm) => widget.partner.chats.any((cm2) => cm.id == cm2.id));
      widget.partner.chats.insertAll(0, chats);
      setState(() => _loading = false);
    });
  }

  void refresh() {
    FirebaseUtils.getMessage(widget.partner, widget.partner.lastReadChatID, false).then((chats) {
      chats.removeWhere((cm) => widget.partner.chats.any((cm2) => cm.id == cm2.id));
      widget.partner.chats.insertAll(0, chats);
      setState((){});
    });
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.partner.saveChatsToDisk();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.partner.saveChatsToDisk();
  }


  @override
  Widget build(BuildContext context) {
    if (widget.partner.chats.length > 0) {
      widget.partner.setLastReadChat();
    }
    var body = new Container(
      child: new Column(
        children: <Widget>[
          new DealingOverview(widget.partner),
          new Flexible(
            child: new ListView.builder(
              padding: new EdgeInsets.all(8.0),
              reverse: true,
              itemBuilder: (_, int index) {
                bool showAvatar = true;
                if (index != widget.partner.chats.length - 1) {
                  if (widget.partner.chats[index + 1].sender == widget.partner.chats[index].sender)
                    showAvatar = false;
                }
                var chatWidget =  new ChatMessageWidget(
                  message: widget.partner.chats[index],
                  animationController: new AnimationController(
                    duration: new Duration(milliseconds: 700),
                    vsync: this,
                  ),
                  showAvatar: showAvatar,
                );

                if (index == widget.partner.chats.length - 1 || dtFromTimeStamp(widget.partner.chats[index + 1].timestamp).day != dtFromTimeStamp(widget.partner.chats[index].timestamp).day)
                  return new Column(children: [
                    new Container(
                      margin: const EdgeInsets.all(10.0),
                      child: new Text(dateFromTimestamp(widget.partner.chats[index].timestamp), style: LightStyle.copyWith(color: Colors.black45, fontSize: 12.0))
                    ),
                    chatWidget
                  ]
                );

                return chatWidget;
              },
              itemCount: widget.partner.chats.length,
            )
          ),
          new Divider(height: 1.0),
          new Container(
            decoration: new BoxDecoration(
                color: Theme.of(context).cardColor),
            child: new Builder(builder: (bc) => _buildTextComposer(bc)),
          ),
        ]
      ),
      decoration: Theme.of(context).platform == TargetPlatform.iOS ? new BoxDecoration(border: new Border(top: new BorderSide(color: Colors.grey[200]))) : null
    );

    return new Scaffold(
      appBar: new AppBar(title: new Row(children: [
        widget.partner.profilePicture == null
          ? new CircleAvatar(
          child: new Text(widget.partner.username[0]),
          backgroundColor: Colors.purple,
          )
          : new CircleAvatar(
          backgroundImage: new NetworkImage(widget.partner.profilePicture)),
        new Container(width: 10.0),
        new Text(widget.partner.username),
      ])),
      body: body,
      );
  }

  Widget _buildTextComposer(BuildContext context) {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: new Row(children: <Widget>[
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                  icon: new Icon(Icons.photo_camera),
                  onPressed: () async{
                    await Account.login(false);
                    File imageFile = await ImagePicker.pickImage();

                    var success = await _handleSubmitted("Uploading photo...", imageFile);
                    if (!success){
                      Scaffold.of(context).showSnackBar(new SnackBar(content: new Text(BKLocale.OPERATION_FAILED)));
                    }
                  }
              ),
            ),
            new Flexible(
              child: new TextField(
                controller: _textController,
                onChanged: (String text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
                onSubmitted: _handleSubmitted,
                decoration:
                new InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? new CupertinoButton(
                  child: new Text("Send"),
                  onPressed: _isComposing
                      ? () => _handleSubmitted(_textController.text)
                      : null,
                )
                    : new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: _isComposing
                      ? () => _handleSubmitted(_textController.text)
                      : null,
                )),
          ]),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? new BoxDecoration(
              border:
              new Border(top: new BorderSide(color: Colors.grey[200])))
              : null),
    );
  }

  Future<bool> _handleSubmitted(String text, [File image]) async{
    if (text == null) text = "";
    if (text.isEmpty) return false;
    if (image == null)_textController.clear();
    setState(() {
      _isComposing = false;
    });
    var imageUrl;

    var message = new ChatMessage(
      content: text,
      imageUrl: imageUrl,
      sender: thisUser,
      recipient: widget.partner,
      timestamp: new DateTime.now().millisecondsSinceEpoch / 1000,
    );
    setState(() {
      widget.partner.chats.insert(0, message);
    });

    if (image != null){
      imageUrl = (await FirebaseUtils.uploadImage(file: image)).toString();
      if (imageUrl == null){
        return false;
      }
      widget.partner.chats.remove(message);
      message = new ChatMessage(
        content: "Photo",
        imageUrl: imageUrl,
        sender: thisUser,
        recipient: widget.partner,
        timestamp: new DateTime.now().millisecondsSinceEpoch / 1000,
      );

      widget.partner.chats.insert(0, message);
    }

    message.id = (await FirebaseUtils.sendMessage(message)).id;
    setState((){});
    return true;
  }
}

class DealingOverview extends StatefulWidget{

  final User partner;

  DealingOverview(this.partner);
  @override
  State createState() {
    return new DealingOverviewState();
  }
}

class DealingOverviewState extends State<DealingOverview>{

  bool _loading = true;
  bool expanded = false;
  OverviewState overviewState = OverviewState.Normal;


  @override
  void initState() {
    NetCode.updateMatchedData().then((success){
      setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> _buildBookListingEntries(List<BookListing> bls){
      var booklistingWidget = new List<Widget>();
      for (BookListing bl in bls) {
        booklistingWidget.add(
            new Padding(
                padding: const EdgeInsets.all(5.0),
                child: new Row(
                    children: [
                      new Container(width: 20.0),
                      new Flexible(fit: FlexFit.tight,
                          child: new Text(bl.book.name, style: LightStyle)),
                      new Container(width: 20.0),
                      new Text("\$${bl.price}", style: SubHeaderStyle),
                      new Container(width: 10.0),
                      new IconButton(icon: new Icon(Icons.info_outline),
                          color: Colors.blue,
                          onPressed: () {
                            Navigator.of(context).push(
                                new MaterialPageRoute<Null>(
                                    builder: (b) => new ModalBook
                                        .fromBookListing(bl)));
                          })
                    ]
                )
            )
        );
      }
      return booklistingWidget;
    }

    if (_loading){
      return new Center(
        child: new SquareLoader(),
      );
    }

    String caption;
    Widget body;
    var buyingBooks = thisUser.activePackage?.getBookListingBySeller(widget.partner);
    var sellingBooks = widget.partner.matchedSellingBooks;

    if (sellingBooks != null) {
      caption = BKLocale.CHAT_SELLING_CAPTION.replaceAll(
          '!no', sellingBooks.length.toString());
      body = new ListView(
        children: _buildBookListingEntries(sellingBooks),
      );
    }
    if (buyingBooks != null) { // buying from partner
      caption = (caption == null ? "" : "\n") + BKLocale.CHAT_BUYING_CAPTION.replaceAll(
          '!no', buyingBooks.length.toString());
      body = new ListView(
        children: _buildBookListingEntries(buyingBooks),
      );
    }
    if (sellingBooks == null && buyingBooks == null)
    {
      caption = "${BKLocale.CHAT_NO_DEALING_CAPTION} ${widget.partner.username}.";
      body = new Container();
    }


    Widget dealButtons = new Container();

    if (overviewState == OverviewState.Normal) //must be normal
    if (buyingBooks != null){
      dealButtons = new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
          new FlatButton(onPressed: (){
            showDialog(context: context, child: new AlertDialog(
              title: new Text(BKLocale.CONFIRM_DEAL),
              content: new Text(BKLocale.CONFIRM_DEAL_CONTENT),
              actions: [
                new FlatButton(onPressed: (){
                  //DEAL
                  Navigator.of(context).pop();
                  setState(() => _loading = true);
                  NetCode.confirmDeal(widget.partner).then((p){
                    if (p != false) {
                      thisUser.histories.add(new History(
                        type: HistoryType.Buy,
                        books: buyingBooks.map((bl) => bl.book).toList(),
                        timestamp: new DateTime.now().millisecondsSinceEpoch ~/ 1000,
                        partner: widget.partner
                      ));
                      if (p == null){
                        thisUser.histories.add(new History(
                            type: HistoryType.Package,
                            timestamp: new DateTime.now().millisecondsSinceEpoch ~/ 1000,
                            partner: widget.partner
                        ));
                      }
                      setState(() {
                        thisUser.activePackage = p;
                        overviewState = OverviewState.Dealt;
                        _loading = false;
                      });
                    } else {
                      Scaffold.of(context).showSnackBar(new SnackBar(
                          content: new Text(BKLocale.OPERATION_FAILED)
                      ));
                      setState(() => _loading = false);
                    }
                  });
                }, child: new Text(BKLocale.CONFIRM.toUpperCase())),
                new FlatButton(onPressed: (){
                  Navigator.of(context).pop();
                }, child: new Text(BKLocale.CANCEL))
              ]
            ));
          }, child: new Text(BKLocale.DEAL_BUTTON),
          textColor: Colors.green,
          color: Colors.white),
          new Container(width: 15.0),
          new FlatButton(onPressed: (){
            showDialog(context: context, child: new AlertDialog(
                title: new Text(BKLocale.CANCEL_DEAL),
                content: new Text(BKLocale.CANCEL_DEAL_CONTENT),
                actions: [
                  new FlatButton(onPressed: (){
                    //CANCEL
                    Navigator.of(context).pop();
                    setState(() => _loading = true);
                    NetCode.cancelDeal(widget.partner).then((p){
                      if (p != false) {
                        thisUser.histories.add(new History(
                            type: HistoryType.Cancel,
                            books: buyingBooks.map((bl) => bl.book).toList(),
                            timestamp: new DateTime.now().millisecondsSinceEpoch ~/ 1000,
                            partner: widget.partner
                        ));
                        if (p == null){
                          thisUser.histories.add(new History(
                              type: HistoryType.Package,
                              timestamp: new DateTime.now().millisecondsSinceEpoch ~/ 1000,
                              partner: widget.partner
                          ));
                        }
                        setState(() {
                          thisUser.activePackage = p;
                          overviewState = OverviewState.Cancelled;
                          _loading = false;
                        });
                      } else {
                        Scaffold.of(context).showSnackBar(new SnackBar(
                         content: new Text(BKLocale.OPERATION_FAILED)
                        ));
                        setState(() => _loading = false);
                      }
                    });
                  }, child: new Text(BKLocale.CONFIRM.toUpperCase())),
                  new FlatButton(onPressed: (){
                    Navigator.of(context).pop();
                  }, child: new Text(BKLocale.CANCEL))
                ]
            ));
          }, child: new Text(BKLocale.CANCEL_TRADE_BUTTON),
          textColor: Colors.red,
          color: Colors.white),
        ]
      );
      dealButtons = new Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: dealButtons
      );
    }

    var content = new Column(
      //padding: const EdgeInsets.all(15.0),
      children: [
        new ExpansionPanelList(
          expansionCallback: (i, b) => setState(() { expanded = !expanded; }),
          children: [
            new ExpansionPanel(
              isExpanded: expanded,
              headerBuilder: (bc, i){
                if (overviewState == OverviewState.Normal) {
                  return new Row(
                      children: [
                        new Container(width: 20.0),
                        new Icon(Icons.library_books, color: Colors.blue),
                        new Container(width: 20.0),
                        new Expanded(child: new Text(caption, style: LightStyle))
                      ]
                  );
                } else if (overviewState == OverviewState.Dealt){
                  return new Row(
                      children: [
                        new Container(width: 20.0),
                        new Icon(Icons.done_outline, color: Colors.green),
                        new Container(width: 20.0),
                        new Expanded(child: new Text(BKLocale.TRADE_COMPLETED, style: LightStyle))
                      ]
                  );
                } else {
                  return new Row(
                      children: [
                        new Container(width: 20.0),
                        new Icon(Icons.clear, color: Colors.red),
                        new Container(width: 20.0),
                        new Expanded(child: new Text(BKLocale.TRADE_CANCELLED, style: LightStyle))
                      ]
                  );
                }
              },
              body: new Container(height: 175.0, child: body
              ),
            )
          ]
        ),
      dealButtons,
      ]
    );
    return new Container(
      child: content,
      decoration: const BoxDecoration(
          color: Colors.white,
          border: const Border(
              bottom: const BorderSide(color: Colors.grey)),
          boxShadow: const [
            const BoxShadow(
                color: Colors.black12, blurRadius: 5.0, spreadRadius: 5.0)
          ]
      ),
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  ChatMessageWidget({this.message, this.animationController, this.showAvatar});

  final ChatMessage message;
  final AnimationController animationController;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    if (!message.shown) animationController.forward();

    var content = new Container(
        child: new Row(
          textDirection: message.sender == thisUser ? TextDirection.rtl : TextDirection.ltr,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Column(children:[
              new Icon(
                message.id == null ? Icons.done : Icons.done_all,
                size: 20.0,
                color: Colors.black26
              ),
              new Text(
                timeFromTimestamp(message.timestamp),
                style: LightStyle.copyWith(fontSize: 12.0)
              )
            ]),
            new Container(width: 16.0),
            new Flexible(
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                textDirection: message.sender == thisUser ? TextDirection.rtl : TextDirection.ltr,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Container(
                    padding: const EdgeInsets.all(9.0),
                    margin: const EdgeInsets.all(4.0),
                    decoration: message.hasImage ? null : new BoxDecoration(
                      borderRadius: new BorderRadius.all(
                          new Radius.circular(17.0)),
                      color: message.sender == thisUser ? Colors.lightBlue : Colors.grey.shade300,
                    ),
                    child: message.hasImage ? new Image.network(message.imageUrl, width: 250.0) : new Text(message.content),
                  ),
                ],
              ),
            ),
            new Container(width: 32.0),
          ],
        )
    );

    if (message.shown) {
      return content;
    }else {
      message.shown = true;
      return new SizeTransition(
          sizeFactor: new CurvedAnimation(
              parent: animationController,
              curve: Curves.easeOut
          ),
          axisAlignment: 0.0,
          child: content
      );
    }
  }
}

/*

                showAvatar ? new Text(message.sender.username, style: Theme
                      .of(context)
                      .textTheme
                      .subhead) : new Container(),
 */