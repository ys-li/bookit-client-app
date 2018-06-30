import 'package:flutter/material.dart';
import '../Structures/Package.dart';
import 'package:bookit/UI/Themes.dart';
import 'Components/SquareLoader.dart';
import '../lang.dart';
import '../Structures/User.dart';
import 'Components/ui_utils.dart';
import 'package:flutter/cupertino.dart';
import 'ModalBook.dart';
import 'Components/SubPageChatConvo.dart';
import '../Utils/NetCode.dart';

typedef Widget BuildWidgetWithContext(BuildContext c);

class PagePackage extends StatefulWidget{

  Package package;
  PagePackage(this.package);


  @override
  State<PagePackage> createState() {
    return new PagePackageState();
  }
}

class PagePackageState extends State<PagePackage>{
  List<bool> isExpandedList;
  bool loading = false;

  @override
  void initState() {
    isExpandedList =
    new List<bool>.filled(widget.package.sellers.length, false);
    //loading = true;
    /*widget.package.populate().then((d) {
      setState(() {
        loading = false;
        isExpandedList =
        new List<bool>.filled(widget.package.sellers.length, false);
      });
    });*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    BuildWidgetWithContext buildFullBody;
    Widget appbar;
    if (loading){
      appbar = new AppBar(title: new Text("#${widget.package.id} - ${BKLocale.LOADING}"));
      buildFullBody = (c) => new Center(child: new SquareLoader());
    }else {
      Widget buildOverview() {
        var content = new Row(
            children: [
              new Container(width: 20.0),
              widget.package.getIcon(false, 45.0),
              new Container(width: 15.0),
              new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    new Container(height: 10.0),
                    new Text("${BKLocale.BOOKS_MATCHED}: ${widget.package
                        .numOfBooksStr}",),
                    new Text("${BKLocale.PRICE}: \$${widget.package.price}"),
                    new Row(
                        children: [
                          new Text("${BKLocale.STATUS}: "),
                          new Text(widget.package.statusStr,
                              style: NormalStyle.copyWith(
                                  color: widget.package.statusStrColor))
                        ]
                    ),
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


      Widget buildExpansionBody(User seller) {
        var content = new List<Widget>();
        var bls = widget.package.getBookListingBySeller(seller);
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
        for (User s in widget.package.sellers) {
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
                        new Text("${BKLocale.BOOKS_MATCHED}: ${widget.package
                            .numOfBooksStrBySeller(s)}",
                            style: LightStyle.copyWith(fontSize: 10.0)),
                        new Container(height: 8.5),
                      ]
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: new Row(
                      children:[
                        widget.package.status == PackageStatus.Dealing ? new IconButton(
                          icon: new Icon(Icons.chat, color: Colors.blue),
                          onPressed: (){
                            //TODO: Implement chat logic
                            Navigator.of(context).push(new MaterialPageRoute(builder: (bc){
                              return new SubPageChatConvo(s);
                            }));
                          },
                        ) : new Container()
                      ]
                    ),
                  ),
                  new Expanded(child: new Container()),
                  new Text("\$${widget.package.getBookListingBySeller(s).fold(
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
      appbar = new AppBar(title: new Text("${widget.package.sellersName}", overflow: TextOverflow.ellipsis));
      buildFullBody = (c) => new Column(
        children: [
          new Flexible(child:
          new ListView(
              children:[
                buildOverview(),
                new Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: new Text(BKLocale.DETAILS, style: NormalStyle.copyWith(color: Colors.black45, fontSize: 12.0)),
                ),
                buildBody(c)
              ]
          ),
          ),
          new Padding(child: new CupertinoButton(
            pressedOpacity: 0.5,
            color: Colors.blue,
            onPressed: widget.package.status == PackageStatus.Available ? () {
              confirmPressed(c);
            } : null,
            child: new Row(
                children: [
                  new Expanded(child: new Container()),
                  new Text(widget.package.actionButtonStr,
                      style: SubHeaderStyle.copyWith(color: Colors.white)),
                  new Expanded(child: new Container()),
                ]
            ),
          ), padding: const EdgeInsets.symmetric(horizontal: 20.0)),
          new Container(height: 20.0),
        ]
      );
    }
    return new Scaffold(
      appBar: appbar,
      body: new RefreshIndicator(child: new Builder(builder: buildFullBody), onRefresh: () {
        setState(() => loading = true);
        return widget.package.populate().then((d) {
          setState(() {
            loading = false;
            isExpandedList =
            new List<bool>.filled(widget.package.sellers.length, false);
          });
        });
      })
    );
  }

  void confirmPressed(BuildContext context){
    showDialog(context: context, child: new AlertDialog(
      title: new Text(BKLocale.CONFIRM_PACKAGE),
      content: new Text(BKLocale.CONFIRM_PACKAGE_CONTENT),
      actions:[
        new FlatButton(onPressed: (){
          setState(() => loading = true);
          Navigator.of(context).pop();
          widget.package.confirm().then((b){
            if (b) {
              Navigator.of(context).pop();
            }
            else {
              setState(() => loading = false);
              Scaffold.of(context).showSnackBar(new SnackBar(
                  content: new Text(
                      BKLocale.SOMETHING_WRONG + "\nCannot confirm package.")
              ));
            }
          });
        }, child: new Text(BKLocale.CONFIRM.toUpperCase())),
        new FlatButton(onPressed: (){Navigator.of(context).pop();}, child: new Text(BKLocale.CANCEL)),
      ]
    ));
  }
}

/* //old content generation code
return new SizedBox(
        height: 184.0,
        child: new Stack(
          children: <Widget>[ //MARK: titles
            new Positioned.fill(
                child: new Image.asset("assets/package/background.jpg", fit: BoxFit.cover)
            ),
            new Align(
              alignment: FractionalOffset.centerRight,
              child: new FittedBox(
                fit: BoxFit.none,
                alignment: FractionalOffset.centerRight,
                child: new Row(
                  children: [
                    new Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children:[
                        new Text("Matched books",style: NormalStyle.copyWith(color: Colors.white, fontSize: 16.0)),
                        new Text("Price",style: NormalStyle.copyWith(color: Colors.white, fontSize: 16.0)),
                        new Text("Date Generated",style: NormalStyle.copyWith(color: Colors.white, fontSize: 16.0)),
                        new Text("Date Generated",style: NormalStyle.copyWith(color: Colors.white, fontSize: 16.0)),
                      ]
                    ),
                    new Container(width: 20.0),
                    new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:[
                          new Text(widget.package.numOfBooksStrRepresentation,style: LightStyle.copyWith(color: Colors.white, fontSize: 16.0)),
                          new Text("${widget.package.price.round()} HKD",style: LightStyle.copyWith(color: Colors.white, fontSize: 16.0)),
                          new Text("8/10/2017",style: LightStyle.copyWith(color: Colors.white, fontSize: 16.0)),
                          new Text("8/10/2017",style: LightStyle.copyWith(color: Colors.white, fontSize: 16.0)),
                        ]
                    ),
                    new Container(width: 20.0),
                  ]
                )
              )
            ),
            new Positioned(
              bottom: 30.0,
              left: 16.0,
              right: 16.0,
              child: new FittedBox(
                  fit: BoxFit.none,
                  alignment: FractionalOffset.bottomLeft,
                  child: new CircleAvatar(
                    child: new Icon(widget.package.active?Icons.gavel:Icons.border_all, color: Colors.white, size: 32.0),
                    radius: 60.0,
                    backgroundColor: Colors.white.withAlpha(50),
                  ),
              ),
            ),
          ],
        ),
      );
 */