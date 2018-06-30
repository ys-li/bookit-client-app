import 'package:flutter/material.dart';
import '../Themes.dart';
import 'ui_utils.dart';
import '../../Structures/Book.dart';
import '../../lang.dart';
import '../ModalBook.dart';
import '../ModalBooklist.dart';
import '../MainScreen.dart';

class EntryBooklist extends StatefulWidget{

  final Book book;
  final bool isBuyList;

  EntryBooklist(this.book, this.isBuyList);

  @override
  State<EntryBooklist> createState() {
    return new EntryBooklistState();
  }
}

class EntryBooklistState extends State<EntryBooklist>{



  @override
  Widget build(BuildContext context) {
    Widget title;
    Widget suppInfo;
    Widget status;

    title = new Text(widget.book.name, style: LightStyle.copyWith(fontSize:20.0));
    suppInfo = new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        title,
        //new Text("ISBN: 923180239182309", style: LightStyle.copyWith(fontSize: 12.0)),
        new Text(widget.book.publisher, style: LightStyle.copyWith(fontSize: 12.0)),
      ]
    );
    status = new Container();
    if (widget.book.bookStatus == (widget.isBuyList ? BookStatus.Buying : BookStatus.Selling)){
      status = new Padding(
        padding: const EdgeInsets.all(5.0),
        child: new Icon(Icons.done, color: ModalBooklist.getMainColor(widget.isBuyList),)
      );
    } else if (widget.book.bookStatus == (widget.isBuyList ? BookStatus.Selling : BookStatus.Buying)) {
      status = new Padding(
          padding: const EdgeInsets.all(5.0),
          child: new Icon(Icons.block, color: Colors.red,)
      );
    }
    return new Card(
      elevation: 0.5,
      child: new InkWell(
        child: new Container(
          padding: const EdgeInsets.all(10.0),
          //height: 100.0,
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  new IconButton(icon: new Icon(Icons.info_outline),
                      color: Colors.blue,
                      onPressed: () {
                        Navigator.of(context).push(
                            new MaterialPageRoute<Null>(
                                builder: (b) => new ModalBook
                                    .fromBook(widget.book)
                            )
                        );
                      }),
                  new Expanded(
                    child: suppInfo,
                  ),
                  new Container(width: 10.0),
                  new Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: !widget.isBuyList && widget.book.bookStatus == BookStatus.Selling ?
                    new Text("\$${widget.book.mySellPrice ?? "..."}", style: SubHeaderStyle)
                        : new Container()
                  ),
                  status
                ]
            ),
            widget.book.bookStatus == BookStatus.Selling && !widget.isBuyList?
            new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [new Expanded(child: new Container(
                padding: const EdgeInsets.all(5.0),
                child: new Slider(
                  label: BKLocale.PRICE,
                  value: widget.book.mySellPrice.toDouble(),
                  min: 0.0,
                  max: widget.book.avgPrice * 2.0,
                  divisions: widget.book.avgPrice * 2,
                  onChanged: (v) {setState((){
                    widget.book.mySellPrice = v.toInt();
                  });},
                )
            )), new FlatButton(
                textColor: Colors.blue,
                color: Colors.white,
                onPressed: () {
                  MyApp.setPage(Pages.Buy);
                },
                child: new Text(
                  BKLocale.REMARKS.replaceAll(' ', '\n'),
                  textAlign: TextAlign.center,)
            )])
                : new Container()
          ]
          )
        ),
        onTap: (){
          setState((){
            if (widget.isBuyList){
              switch (widget.book.bookStatus){
                case BookStatus.Buying:
                  widget.book.bookStatus = BookStatus.None;
                  break;
                case BookStatus.Selling:
                  Scaffold.of(context).showSnackBar(new SnackBar(content: new Text(BKLocale.CANT_BUY_SELL_SAME_BOOK)));
                  break;
                case BookStatus.None:
                  widget.book.bookStatus = BookStatus.Buying;
                  break;
              }
            }else{
              switch (widget.book.bookStatus){
                case BookStatus.Buying:
                  Scaffold.of(context).showSnackBar(new SnackBar(content: new Text(BKLocale.CANT_BUY_SELL_SAME_BOOK)));
                  break;
                case BookStatus.Selling:
                  widget.book.bookStatus = BookStatus.None;
                  break;
                case BookStatus.None:
                  widget.book.bookStatus = BookStatus.Selling;
                  widget.book.mySellPrice = widget.book.avgPrice;
                  break;
              }
            }
          });

        },
      ),

    );
  }

}