import 'package:flutter/material.dart';
import 'package:bookit/UI/Themes.dart';
import 'ui_utils.dart';
import '../../Structures/Package.dart';
import '../PagePackage.dart';
import '../../lang.dart';
import 'SquareLoader.dart';

class EntryPackage extends StatefulWidget{

  Package package;
  final bool recommended;
  EntryPackage(this.package, this.recommended, {Key key}) : super(key: key);

  @override
  State<EntryPackage> createState() {
    return new EntryPackageState();
  }
}

class EntryPackageState extends State<EntryPackage>{

  @override
  Widget build(BuildContext context) {


    Widget packageIcon;
    Widget title;
    Widget suppInfo;
    Widget status;
    Widget price;


    packageIcon = widget.package.getIcon(widget.recommended);

    title = new Text(widget.package.sellersName, style: NormalStyle.copyWith(fontSize:20.0), overflow: TextOverflow.ellipsis);
    suppInfo = new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          title,
          new Text("${BKLocale.BOOKS_MATCHED}: ${widget.package.numOfBooksStr}", style: NormalStyle.copyWith(fontSize: 12.0)),
          //new Text("Price: ${widget.package.price.round()} HKD", style: LightStyle.copyWith(fontSize: 12.0)), ,
        ]
    );
    status = addPadding(new Icon(Icons.arrow_forward_ios, color: Colors.grey.withAlpha(55)), const EdgeInsets.all(2.5));
    price = new Text("\$${widget.package.price.round()}", style: NormalStyle.copyWith(fontSize:20.0));



    return new Card(
        child: new InkWell(child: new Container(
            padding: const EdgeInsets.all(10.0),
            height: 70.0,
            child: new Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  addPadding(packageIcon, const EdgeInsets.only(right: 10.0)),
                  new Expanded(
                    child: suppInfo,
                  ),
                  price,
                  status,
                ]
            )
        ),
          onTap:(){
            Navigator.of(context).push(
                new MaterialPageRoute<Null>(builder: (BuildContext context){
                  return new PagePackage(widget.package);
                })
            );
          }
      )
    );
  }

}