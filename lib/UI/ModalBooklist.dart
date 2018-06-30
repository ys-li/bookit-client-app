
import 'package:flutter/material.dart';
import 'Components/EntryBooklist.dart';
import '../Structures/Book.dart';
import '../Utils/NetCode.dart';
import '../Structures/User.dart';
import '../lang.dart';
import 'Themes.dart';
import 'dart:async';
import 'Components/SquareLoader.dart';

class ModalBooklist extends StatefulWidget{

  final bool isBuyList;
  ModalBooklist(this.isBuyList);

  @override
  State<ModalBooklist> createState() {
    return new ModalBooklistState();
  }

  static Color getMainColor([isBuyList]) => isBuyList ? Colors.blue : Colors.amber;
}

class ModalBooklistState extends State<ModalBooklist> with TickerProviderStateMixin{

  bool loading = true;
  var snapshotBookStatus = new Map<int, BookStatus>();
  var snapshotBookPrice = new Map<int, int>();

  int sellFormCur;

  List<bool> subjectExpanded;

  bool get bookStatusChanged{
    for (Book b in fullBookList.books){
      if (b.bookStatus != snapshotBookStatus[b.id]){
        return true;
      }
    }
    return false;
  }

  bool get bookPriceChanged{
    for (Book b in fullBookList.books){
      if (b.mySellPrice != snapshotBookPrice[b.id]){
        return true;
      }
    }
    return false;
  }

  void rollbackChanges(){
    for (Book b in fullBookList.books){
      b.bookStatus = snapshotBookStatus[b.id];
      b.mySellPrice = snapshotBookPrice[b.id];
    }
  }

  @override
  void initState() {
    sellFormCur = thisUser.buyForm - 1 >= 1 ? thisUser.buyForm - 1 : 1;
    NetCode.setUserBooksConfig().then((m){
      setState(() {
        //snapshot
        for (Book b in fullBookList.books){
          snapshotBookStatus[b.id] = b.bookStatus;
          snapshotBookPrice[b.id] = b.mySellPrice;
        }

        loading = false;
      }
      );
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    Scaffold scaffold = new Scaffold(
      appBar: new AppBar(
        title: new Row(
          children:[
            new Hero(
              child: new Container(
                width: 40.0,
                height: 40.0,
                decoration: new BoxDecoration(
                  borderRadius: const BorderRadius.all(const Radius.circular(20.0)),
                  color: ModalBooklist.getMainColor(widget.isBuyList),
                  boxShadow: [
                    new BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10.0,
                      spreadRadius: 3.0,
                    )
                  ]
                ),
                child: new Icon(Icons.library_books, color: Colors.white, size: 15.0),
              ),
              tag: "booklistFloat",
            ),
            new Container(width: 10.0),
            new Text(widget.isBuyList ? BKLocale.TITLE_BUYLIST : BKLocale.TITLE_SELLLIST),
          ]
        ),
        actions: [
          new FlatButton(onPressed: loading ? null : (){
            setState(() => loading = true);
            if (bookStatusChanged){
              NetCode.submitNewBookStatus(widget.isBuyList).then((b) => Navigator.of(context).pop(b?1:-1));
            } else {
              Navigator.of(context).pop(0);
            }
          }, child: new Text(BKLocale.DONE, style: NormalStyle.copyWith(color: Colors.white)),
          disabledTextColor: Colors.grey,)
        ],
      ),
      body: _buildContent(widget.isBuyList, context),
    );

    return new WillPopScope(child: scaffold,
      onWillPop: (){
        if (loading){ // do not check if popping before finish loading
          Navigator.pop(context, 0);
          return;
        }
        if (bookStatusChanged){
          showDialog(context: context, child: new AlertDialog(
            title: new Text(BKLocale.UNSAVED_CHANGES),
            content: new Text(BKLocale.UNSAVED_CHANGES_CONTENT),
            actions: [
              new FlatButton(onPressed: () {
                rollbackChanges();
                Navigator.pop(context, 0);
                Navigator.pop(context, 0);
                }, child: new Text(BKLocale.DISCARD)),
              new FlatButton(onPressed: () {
                Navigator.pop(context);
                }, child: new Text(BKLocale.CANCEL)),
            ],
          ));
        } else {
          Navigator.pop(context, 0);
        }
      }
    );

  }
  Widget _buildFormSelector(BuildContext context){
    return new Padding(
      padding: const EdgeInsets.all(15.0),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          new Row(
              children: [
                new Text(BKLocale.SCHOOL),
                new Expanded(child: new Container()),
                new Text(thisUser.schoolNameEn),
              ]
          ),
          new Row(
              children: [
                new Text(BKLocale.SECONDARY_SELECTOR_CAPTION),
                new Expanded(child: new Container()),
                new DropdownButton(
                  items: [
                    new DropdownMenuItem<int>(child: new Text(BKLocale.SECONDARY1), value: 1),
                    new DropdownMenuItem<int>(child: new Text(BKLocale.SECONDARY2), value: 2),
                    new DropdownMenuItem<int>(child: new Text(BKLocale.SECONDARY3), value: 3),
                    new DropdownMenuItem<int>(child: new Text(BKLocale.SECONDARY4), value: 4),
                    new DropdownMenuItem<int>(child: new Text(BKLocale.SECONDARY5), value: 5),
                    new DropdownMenuItem<int>(child: new Text(BKLocale.SECONDARY6), value: 6),
                  ],
                  value: widget.isBuyList ? thisUser.buyForm : sellFormCur,
                  onChanged: (i){
                    if (widget.isBuyList)
                      showDialog(context: context, child: new AlertDialog(
                          title: new Text(BKLocale.WARNING),
                          content: new Text(BKLocale.WARNING_CHANGE_FORM),
                          actions: [
                            new FlatButton(onPressed: (){
                              subjectExpanded = null; //recompute subject list
                              Booklist.resetBooklistStatusForBuy();
                              setState(() => thisUser.buyForm = i);
                              Navigator.of(context).pop();
                            }, child: new Text(BKLocale.CONTINUE)),
                            new FlatButton(onPressed: (){
                              Navigator.of(context).pop();
                            }, child: new Text(BKLocale.CANCEL))
                          ]
                      ));
                    else
                      subjectExpanded = null; //recompute subject list
                      setState(() => sellFormCur = i);
                  },
                ),
              ]
          ),
          new Text(BKLocale.BUY_SELL_FORM_HELPER_TEXT, style: LightStyle.copyWith(fontSize: 12.0),)
        ]
      )
    );
  }
  Widget _buildContent(bool type, BuildContext context){

    Widget getTitleHeader(){
      return new Column(
        children: [
          new Container(
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
          padding: const EdgeInsets.all(10.0),
            child:
            _buildFormSelector(context),
//              new Row(
//              children: [
//                new Hero(
//                  child: new CircleAvatar(
//                    radius: 50.0,
//                    child: new Icon(Icons.library_books, color: Colors.white, size: 42.0),
//                    backgroundColor: ModalBooklist.getMainColor(widget.isBuyList),
//                  ),
//                  tag: "booklistFloat",
//                ),
//                new Container(width: 20.0),
//                new Align(
//                  alignment: Alignment.centerLeft,
//                  child: new Text(widget.isBuyList ? BKLocale.BUY_BOOKLIST_HEADER : BKLocale.SELL_BOOKLIST_HEADER, style: HeaderStyle)
//                ),
//              ]

          ),
        ]
      );
    }

    // if loading
    if (loading){
      return new Column(
          children: [
            getTitleHeader(),
            new Expanded(child: new Container()),
            new Center(child: new SquareLoader()),
            new Expanded(child: new Container()),
          ]
      );
    }



    var tempBooks = fullBookList.byForm(widget.isBuyList ? thisUser.buyForm : sellFormCur);
    List<int> subjectsInTemp = new List<int>();

    //need not sort now
    tempBooks.books.sort((a,b) {
      if (!subjectsInTemp.contains(a.subjectID))
        subjectsInTemp.add(a.subjectID); // also count subject
      if (!subjectsInTemp.contains(b.subjectID))
        subjectsInTemp.add(b.subjectID); // also count subject
      return a.subjectID - b.subjectID;
    }); //sort by subject for viewing


    subjectsInTemp.sort((a,b) => a - b);

    if (subjectExpanded == null){
      subjectExpanded = new List.filled(subjectsInTemp.length, false);
    }

    Widget getSubjectHeader(int subjectID){
      print(subjectID);
      var tempBooksBySub = tempBooks.bySubject(subjectID).books;
      return new Padding(
        padding: const EdgeInsets.all(10.0),
        child: new Text("${Subjects[subjectID].name} (${tempBooksBySub.where((b){
          return b.bookStatus != BookStatus.None;
        }).length}/${tempBooksBySub.length})", style: NormalStyle.copyWith(color: Colors.black, fontSize: 16.0)),
      );
//      return new Padding(
//        padding: const EdgeInsets.all(5.0),
//        child: new Text(Subjects[subjectID].name, style: NormalStyle.copyWith(color: Colors.black45, fontSize: 12.0)),
//      );
    }




    int tempSubjectID = 2;
    var j = 0;
    
    return new Scrollbar(child: new ListView.builder(

      itemCount: subjectsInTemp.length + 1,
      itemBuilder: (bc, i){
        if (i == 0){
          return getTitleHeader();
        }

        var books = new List<Widget>();
        books = tempBooks.books.where((b) => b.subjectID == subjectsInTemp[i-1]).
        map((bb) => new EntryBooklist(bb, widget.isBuyList)).toList();
        
        return new ExpansionPanelList(
          children: [
            new ExpansionPanel(headerBuilder: (bc, b){
              return getSubjectHeader(subjectsInTemp[i-1]);
            }, body: new Column(
              children: books
            ), isExpanded: subjectExpanded[i-1])
          ],
          expansionCallback: (_, b) => setState(() => subjectExpanded[i-1] = !b),
        );


      },
    ));

    return new Scrollbar(child: new ListView.builder(

      itemCount: tempBooks.books.length + subjectsInTemp.length + 1,
      itemBuilder: (bc, i){
        if (i == 0){
          return getTitleHeader();
        }
        if (i == 1){
          return getSubjectHeader(tempSubjectID);
        }
        Book b = tempBooks.books[i - j - 2]; // -2 due to the first subject header

        if (tempSubjectID != b.subjectID){
          tempSubjectID = b.subjectID;
          j++;
          return getSubjectHeader(b.subjectID);
        }else{
          return new EntryBooklist(b, widget.isBuyList);
        }


      },
    ));

  }



}