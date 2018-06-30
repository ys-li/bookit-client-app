import 'package:flutter/material.dart';
import '../Structures/Package.dart';
import 'package:bookit/UI/Themes.dart';
import 'Components/SquareLoader.dart';
import '../lang.dart';
import '../Structures/User.dart';
import 'Components/ui_utils.dart';
import 'package:flutter/cupertino.dart';
import 'ModalBook.dart';
import '../Utils/NetCode.dart';
import 'Components/SubPageChatConvo.dart';
import 'ModalBooklist.dart';

class PageSell extends StatefulWidget{

  @override
  State<PageSell> createState() {
    return new PageSellState();
  }
}

class PageSellState extends State<PageSell>{

  List<User> get usersMatched => users.where((u) => u.matchedSellingBooks != null).toList();
  List<bool> isExpandedList;
  bool loading = true;
  @override
  void initState() {
    loading = true;
    NetCode.getMatchedSellingBooks().then((m){
      for (User u in users){
        u.matchedSellingBooks = null;
      }
      m.forEach((id, bl) => User.getUserByID(id).matchedSellingBooks = bl);
      isExpandedList =
      new List<bool>.filled(usersMatched.length, false);
      setState(() => loading = false);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Widget body;
    if (loading){
      body = new Column(
          children: [
            new Expanded(child: new Container()),
            new Center(
              child: new SquareLoader(),
            ),
            new Expanded(child: new Container()),
          ]
      );
    }else{
      Widget buildHeader(){
        var content = new Row(
            children: [
              new Container(width: 10.0),
              new Icon(Icons.monetization_on, size: 40.0, color: Colors.blue,),
              new Container(width: 15.0),
              new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    new Container(height: 10.0),
                    new Text("${BKLocale.USER_MATCHED}: ${usersMatched.length}",),
                    new Text("${BKLocale.EARNINGS}: \$${usersMatched.fold(0, (p, u){
                      return p += u.matchedSellingBooks.fold(0, (pp, bl) => pp += bl.price);
                    })}"),
                    new Container(height: 10.0),
                  ]
              ),
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
          padding: const EdgeInsets.all(10.0),
        );
      }

      Widget buildExpansionBody(User buyer) {
        var content = new List<Widget>();
        var bls = buyer.matchedSellingBooks;
        for (BookListing bl in bls) {
          content.add(
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
        return new Column(
          children: content,
        );
      }

      Widget buildBody(BuildContext context) {
        var panelList = new List<ExpansionPanel>();
        var i = 0;
        for (User s in usersMatched) {
          panelList.add(new ExpansionPanel(headerBuilder: (context, b) {
            return new Row(
                children: [
                  new Container(width: 20.0),
                  addPadding(new Icon(
                    Icons.person,
                    size: 45.0,
                    color: Colors.blue,
                  ), const EdgeInsets.only(right: 15.0,)),
                  new Container(width: 15.0),
                  new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        new Container(height: 8.5),
                        new Text(s.username, style: SubHeaderStyle),
                        new Text("${BKLocale.BOOKS_MATCHED}: ${s.matchedSellingBooks.length}",
                            style: LightStyle.copyWith(fontSize: 10.0)),
                        new Container(height: 8.5),
                      ]
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: new Row(
                        children:[
                           new IconButton(
                            icon: new Icon(Icons.chat, color: Colors.blue),
                            onPressed: (){
                              //TODO: Implement chat logic
                              Navigator.of(context).push(new MaterialPageRoute(builder: (bc){
                                return new SubPageChatConvo(s);
                              })).then((b) {
                                isExpandedList =
                                new List<bool>.filled(usersMatched.length, false);
                              });
                            },
                          )
                        ]
                    ),
                  ),
                  new Expanded(child: new Container()),
                  new Text("\$${s.matchedSellingBooks.fold(
                      0, (p, bl) => p += bl.price)}", style: SubHeaderStyle),
                ]
            );
          }, body: buildExpansionBody(s),
              isExpanded: isExpandedList[i]));
          i++;
        }
        return new ExpansionPanelList(
          children: panelList,
          expansionCallback: (i, b) {
            setState(() => isExpandedList[i] = !b);
          },
        );
      }

      body = new ListView(children:[
        buildHeader(),
        new Padding(
          padding: const EdgeInsets.all(5.0),
          child: new Text(BKLocale.DETAILS, style: NormalStyle.copyWith(color: Colors.black45, fontSize: 12.0)),
        ),
        buildBody(context)
      ]);

    }
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: false,
        title: new Text(BKLocale.BAR_SELL)
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => Navigator.of(context).push(new MaterialPageRoute<int>(builder: (BuildContext context){
          return new ModalBooklist(false);
        },
          fullscreenDialog: true,
        )).then((success){ // if the update is successful
          if (success == null || success == 0) return; //no change
          if (success == 1){
            Scaffold.of(context).showSnackBar(new SnackBar(
                content: new Text(BKLocale.BOOKLIST_CHANGED)
            ));
          } else {
            Scaffold.of(context).showSnackBar(new SnackBar(
                content: new Text(BKLocale.BOOKLIST_CHANGED_FAILED)
            ));
          }
      }),
        child: new Icon(Icons.library_books),
        backgroundColor: Colors.amber,
        heroTag: "booklistFloat",
      ),
      body: new RefreshIndicator(child: body, onRefresh: (){

        setState(() => loading = true);
        isExpandedList =
        new List<bool>.filled(usersMatched.length, false);
        return NetCode.getMatchedSellingBooks().then((m){
          m.forEach((id, bl) => User.getUserByID(id).matchedSellingBooks = bl);
          setState(() => loading = false);
        });
      }),
    );
  }

}