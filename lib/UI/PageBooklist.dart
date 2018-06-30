/*import 'package:flutter/material.dart';
import 'Components/EntryBooklist.dart';
import 'package:bookit/UI/Themes.dart';
import '../Structures/Book.dart';

class PageBooklist extends StatefulWidget{


  PageBooklist();

  @override
  State<PageBooklist> createState() {
    return new PageBooklistState();
  }
}

class PageBooklistState extends State<PageBooklist> with TickerProviderStateMixin{

  TabController tabController;
  Animation<Color> themeColorTween;
  AnimationController colorAnimController;


  @override
  void initState(){
    tabController =  new TabController(length: 3, vsync: this);
    tabController.addListener((){
      if (tabController.index == 1) colorAnimController.forward();
      else colorAnimController.reverse();
    });
    colorAnimController = new AnimationController(vsync: this, duration: new Duration(milliseconds: 300));
    colorAnimController.addListener(() => setState((){}));
    themeColorTween = new ColorTween(begin: BuyColor, end: SellColor).animate(colorAnimController);
    super.initState();

  }

  @override
  Widget build(BuildContext context) {


    TabBar tabBar = new TabBar(
      controller: tabController,
      indicatorColor: themeColorTween.value,
      labelColor: themeColorTween.value,
      //labelStyle: NormalStyle.copyWith(letterSpacing: 2.0, fontWeight: FontWeight.bold, fontSize: 8.0),
      tabs: [
        new Tab(text: "Buy", icon: new Icon(Icons.shopping_cart)),
        new Tab(text: "Sell", icon: new Icon(Icons.attach_money)),
      ],
    );
    Scaffold scaffold = new Scaffold(
      appBar: tabBar,
      body: new TabBarView(
          controller: tabController,
          children: [
            _buildByTab(true), //true = Buy
            _buildByTab(false),
          ]
      ),
      floatingActionButton: new FloatingActionButton(
        backgroundColor: themeColorTween.value,
        child: new Icon(Icons.edit),
        onPressed: (){

          Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("Clicked on ${tabController.index}")));
        }
      ),
    );
    return scaffold;

  }

  Widget _buildByTab(bool type){

    Widget getSubjectHeader(int subjectID){
      return new Padding(
        padding: const EdgeInsets.all(5.0),
        child: new Text(Book.Subjects[subjectID].name, style: NormalStyle.copyWith(color: Colors.black45, fontSize: 12.0)),
      );
    }

    List<Book> tempBooks = [

    ];
    int tempSubjectID = 0;
    return new ListView.builder(
      itemCount: tempBooks.length + Book.Subjects.length,
      itemBuilder: (bc, i){

        if (i == 0){
          return getSubjectHeader(0);
        }
        Book b = tempBooks[i - tempSubjectID - 1]; // -1 due to the first subject header

        if (tempSubjectID != b.subjectID){
          tempSubjectID = b.subjectID;
          return getSubjectHeader(b.subjectID);
        }else{
          return new EntryBooklist(b,widget.);
        }


      },
    );

  }

}


class subpageBooklistList extends StatefulWidget{
  @override
  State<subpageBooklistList> createState() {
    return new subpageBooklistListState();
  }
}

class subpageBooklistListState extends State<subpageBooklistList>{
  @override
  Widget build(BuildContext context) {
    return new Container();
  }
}*/