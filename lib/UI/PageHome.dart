import 'package:flutter/material.dart';
import 'Components/AppBarBtnMore.dart';
import '../Structures/Package.dart';
import '../Utils/NetCode.dart';
import '../Structures/User.dart';
import '../Structures/Book.dart';
import '../lang.dart';
import 'MainScreen.dart';
import 'Components/SquareLoader.dart';
import '../Utils/HelperFunctions.dart';
import 'Themes.dart';
import 'Components/ui_utils.dart';
import 'ModalBook.dart';

class PageHome extends StatefulWidget{
  static List<BookListing> newBooks;
  static List<Advertisement> advertisements;
  @override
  State<PageHome> createState() {
    return new PageHomeState();
  }
}

class PageHomeState extends State<PageHome>{

  List<bool> isExpanded;
  bool _loading = true;
  @override
  void initState() {

    setState(() => _loading = true);

    if (PageHome.newBooks == null || PageHome.advertisements == null || thisUser.histories == null){
      NetCode.getHome().then((m){
        setHomeFromMap(m);

        isExpanded = new List<bool>();
        for (int i = 0;i < thisUser.histories.length; i++) {
          isExpanded.add(false);
        }

        setState(() => _loading = false);
      });
    }else{

      isExpanded = new List<bool>();
      for (int i = 0;i < thisUser.histories.length; i++) {
        isExpanded.add(false);
      }
      setState(() => _loading = false);
    }
    super.initState();
  }

  bool setHomeFromMap(Map m){
    try {
      //histories
      thisUser.histories = new List<History>();
      for(Map mh in m["histories"]){
        thisUser.histories.add(new History(
          type: History.charToType(mh["type"]),
          books: fullBookList.byIDs(mh["books"]).books,
          timestamp: mh["timestamp"].toInt(),
          partner: User.getUserByID(mh["partner"]["user_id"]).setFromSimpleMap(mh["partner"]),
        ));
      }

      //advertisement
      PageHome.advertisements = new List<Advertisement>();
      for (Map ma in m["advertisements"]){
        PageHome.advertisements.add(new Advertisement(
          imageUrl: ma["image_url"],
          href: ma["href"]
        ));
      }

      //new books
      PageHome.newBooks = new List<BookListing>();
      for (Map mb in m["new_books"]){
        PageHome.newBooks.add(new BookListing.fromMap(mb));
      }

      return true;
    }
    catch (e){
      print(e.toString());
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {

    Widget content;
    if (_loading){
      content = new Column(
        children: [
          new Expanded(child: new Container()),
          new Center(child: new SquareLoader()),
          new Expanded(child: new Container()),
        ]
      );
    }else {
      Widget _buildProfilePanel() {
        return new Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              new Container(
                  width: 80.0,
                  height: 80.0,
                  margin: const EdgeInsets.all(10.0),
                  /*decoration: new BoxDecoration(
                borderRadius: new BorderRadius.all(
                    new Radius.circular(65.0)),
                boxShadow: [new BoxShadow(
                  color: Colors.black,
                  blurRadius: 10.0,
                  spreadRadius: 1.0,
                ),
                ]
            ),*/
                  child: new CircleAvatar(
                    backgroundImage: thisUser.profilePicture == null
                        ? null
                        : new NetworkImage(thisUser.profilePicture),
                    child: thisUser.profilePicture == null ? new Text(
                        thisUser.username[0]) : null,
                  )
              ),
              new Expanded(child:
              new Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  textDirection: TextDirection.rtl,
                  children: [
                    new Text(thisUser.username),
                    new Text(
                        thisUser.schoolNameEn + '\n' + thisUser.schoolNameCh),
                    new Text("S. ${thisUser.form}"),

                  ]
              )
              ),
              thisUser.activePackage == null ? new Container(width: 30.0) :
              new FlatButton(
                  textColor: Colors.blue,
                  color: Colors.white,
                  onPressed: () {
                    MyApp.setPage(Pages.Buy);
                  },
                  child: new Text(
                    BKLocale.HAVE_ACTIVE_PACKAGE.replaceAll(' ', '\n'),
                    textAlign: TextAlign.center,)
              )
            ]
        );
      }

      Widget _buildNewBooksPanel() {
        Widget list = new ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: PageHome.newBooks.length,
          itemBuilder: (bc, i){
          return new Container(
            width: 150.0,
            child: new Card(
              child: new Padding(
                padding: const EdgeInsets.all(5.0),
                child: new Column(
                  children: [
                    new Expanded(child:
                      new Image.network("https://about.canva.com/wp-content/uploads/sites/3/2015/01/business_bookcover.png", fit: BoxFit.cover)
                    ),
                    new Text(
                        PageHome.newBooks[i].book.name.length > 30 ? PageHome.newBooks[i].book.name.substring(0,30) + '...' : PageHome.newBooks[i].book.name,
                        overflow: TextOverflow.fade,),
                    new Align(
                      alignment: Alignment.centerLeft,
                      child: new Text(dateFromTimestamp(PageHome.newBooks[i].timestamp.toInt()), style: LightStyle.copyWith(fontSize: 12.0))
                    )
                  ]
                )
              )
            ),
          );
        });
        list = new Container(child: list, height: 200.0);
        return new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            new Padding(
              padding: const EdgeInsets.all(4.0),
              child: new Text(BKLocale.NEW_BOOKS, style: LightStyle.copyWith(fontSize: 14.0))
            ),
            list,
          ]
        );
      }

      Widget _buildHistoryPanel() {
        var i = -1;
        Widget list = new ExpansionPanelList(children:
          thisUser.histories.map<ExpansionPanel>((history){
            i++;
            return new ExpansionPanel(headerBuilder: (context, b) {
              return new Row(
                  children: [
                    new Container(width: 20.0),
                    addPadding(new Icon(
                      history.icon,
                      size: 25.0,
                      color:
                      history.color
                    ), const EdgeInsets.only(right: 15.0,)),
                    new Container(width: 8.0),
                    new Expanded(child:
                      new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            new Text(
                                history.description,
                            style: SubHeaderStyle.copyWith(fontSize: 14.0),
                              overflow: TextOverflow.fade,
                            ),
                            new Text(dateFromTimestamp(history.timestamp),
                                style: LightStyle.copyWith(fontSize: 10.0)),
                          ]
                      ),
                    ),
                    //new Text("\$${history.books.fold(
                        //0, (p, bl) => p += bl.price)}", style: SubHeaderStyle),
                  ]
              );
            }, body: new Column(
              children: history.books.map((bl){
                return new Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: new Row(

                        children: [
                          new Container(width: 20.0),
                          new Flexible(fit: FlexFit.tight,
                              child: new Text(bl.name, style: LightStyle)),
                          new Container(width: 20.0),
                          //new Text("\$${bl.price}", style: SubHeaderStyle),
                          //new Container(width: 10.0),
                          new IconButton(icon: new Icon(Icons.info_outline),
                              color: Colors.blue,
                              onPressed: () {
                                Navigator.of(context).push(
                                    new MaterialPageRoute<Null>(
                                        builder: (b) => new ModalBook
                                            .fromBook(bl)
                                    )
                                );
                          })
                        ]
                    )
                );
              }).toList()
            ),
                isExpanded: isExpanded[i]);
          }).toList(),
          expansionCallback: (i,b) { setState((){isExpanded[i] = !b;});},
        );
        return new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              new Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: new Text(BKLocale.TRANSACTION_HISTORY, style: LightStyle.copyWith(fontSize: 14.0))
              ),
              list,
            ]
        );
      }


      content = new ListView(
          children: [
            new Container(
              padding: const EdgeInsets.all(10.0),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  border: const Border(
                      bottom: const BorderSide(color: Colors.grey)),
                  boxShadow: const [
                    const BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5.0,
                        spreadRadius: 5.0)
                  ]
              ),
              child: _buildProfilePanel(),
            ),
            new Container(height: 10.0),
            new AdvertPanel(PageHome.advertisements),
            _buildNewBooksPanel(),
            _buildHistoryPanel(),
            new Container(height: 20.0),
          ]
      );
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Padding(
            padding: const EdgeInsets.all(7.5),
            child: new Hero(tag: "logo", child: new Image.asset('assets/logo_negative.png')),
        ),
        centerTitle: true,
        actions: <Widget>[
          new AppBarBtnMore()
        ]
      ),
      body: content
    );
  }

}

class Advertisement{
  final String imageUrl;
  final String href;
  Advertisement({this.imageUrl, this.href});
}

class AdvertPanel extends StatefulWidget{

  final List<Advertisement> adverts;

  AdvertPanel(this.adverts);

  @override
  State createState() {
    return new AdvertPanelState();
  }
}

class AdvertPanelState extends State<AdvertPanel> with TickerProviderStateMixin{

  int index = 0;
  bool _sliding = false;
  List<Animation<Offset>> _animations;
  List<AnimationController> _controllers;


  @override
  void initState() {
    _controllers = new List<AnimationController>();
    _animations = new List<Animation<Offset>>();
    for (var i = 0; i < widget.adverts.length; i++) {
      _controllers.add(new AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ));
      _animations.add(new Tween<Offset>(
        begin: const Offset(1.0,0.0),
        end: Offset.zero,
      ).animate(new CurvedAnimation(
        parent: _controllers[i],
        curve: Curves.fastOutSlowIn,
      )));
    }
    _controllers[0].forward();

  }

  bool moveLeft(){

    print(index);
    if (_sliding) return false;
    if (index == widget.adverts.length - 1) return false;
    _sliding = true;
    _controllers[++index].forward().then((b) => setState(() => _sliding = false));
    return true;
  }

  bool moveRight(){
    print(index);
    if (_sliding) return false;
    if (index == 0) return false;
    _sliding = true;
    _controllers[index--].reverse().then((b) => setState(() => _sliding = false));
    return true;
  }

  @override
  Widget build(BuildContext context) {

    var allAdverts = new List<Widget>();
    allAdverts.add(
      new Container(
        alignment: Alignment.center,
        child: new SquareLoader(),
        height: 200.0
      )
    );
    var i = 0;
    for(Advertisement ad in widget.adverts){
      allAdverts.add(
        new SlideTransition(

            position: _animations[i],
            child: new Image.network(
              ad.imageUrl,
              fit: BoxFit.fitWidth,
            )
        )
      );
      i++;
    }

    String pager = "●".padLeft(index + 1, "○") + "".padRight(widget.adverts.length - index - 1, "○");

    allAdverts.add(
      new Align(
          alignment: Alignment.bottomRight,
          child: new Padding(
              padding: const EdgeInsets.all(5.0),
              child: new Text(pager, style: NormalStyle.copyWith(color: Colors.white))
          )
      )
    );

    var mainPanel = new GestureDetector(
      child: new Stack(
        children: allAdverts
      ),
      onHorizontalDragEnd: (details){
        if (details.primaryVelocity < 0.0) moveLeft();
        else moveRight();
      },
    );


    return mainPanel;
  }


}