//import 'package:flutter/material.dart';
//import '../Themes.dart';
//import 'ui_utils.dart';
//import '../../Structures/Book.dart';
//import '../../lang.dart';
//import '../ModalBook.dart';
//import '../ModalBooklist.dart';
//
//class ModalSellSetup extends StatefulWidget{
//
//  final List<Book> books;
//  ModalSellSetup(this.books);
//
//  @override
//  State createState() {
//    return new ModalSellSetupState();
//  }
//}
//
//class ModalSellSetupState extends State<ModalSellSetup>{
//
//  @override
//  void initState() {
//
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    Scaffold scaffold = new Scaffold(
//      appBar: new AppBar(
//        title: new Text(widget.isBuyList ? BKLocale.TITLE_BUYLIST : BKLocale.TITLE_SELLLIST),
//        actions: [
//          new FlatButton(onPressed: loading ? null : (){
//            setState(() => loading = true);
//            if (bookStatusChanged){
//              NetCode.submitNewBookStatus().then((b) => Navigator.of(context).pop(b));
//            } else {
//              Navigator.of(context).pop(null);
//            }
//          }, child: new Text(BKLocale.DONE, style: NormalStyle.copyWith(color: Colors.white)),
//            disabledTextColor: Colors.grey,)
//        ],
//      ),
//      body: _buildContent(widget.isBuyList, context),
//    );
//
//    return new WillPopScope(child: scaffold,
//      onWillPop: (){
//
//      }
//    );
//  }
//
//
//}