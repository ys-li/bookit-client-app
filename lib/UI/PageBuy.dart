import 'package:flutter/material.dart';
import 'Components/ui_utils.dart';
import 'Components/EntryPackage.dart';
import '../Structures/Package.dart';
import '../Structures/User.dart';
import 'Themes.dart';
import 'Components/PackageFilterDrawer.dart';
import 'ModalBooklist.dart';
import '../Utils/NetCode.dart';
import '../lang.dart';
import 'Components/SquareLoader.dart';
import 'PagePackage.dart';
import 'dart:async';

enum SortByOptions {
  Score,
  Price,
  Sellers,
  Books
}

class PageBuy extends StatefulWidget{

  static const int MAX_PRICE_STEP = 5;
  static const int MAX_MAX_SELLERS_STEP = 4;
  static List<int> priceSteps = [0, 200, 400, 600, 800, 1000];
  static int currentPriceStep = 5;
  static List<int> maxSellersSteps = [1, 2, 3, 4, 5];
  static int currentMaxSellersStep = 4;
  static int maxMatchingBooks = 20;
  static int currentMinBooks = 1;
  static SortByOptions sortBy = SortByOptions.Score;

  static get filterMaxPrice => priceSteps[currentPriceStep];
  static get filterMaxSellers => maxSellersSteps[currentMaxSellersStep];
  static get filterMinBooks => currentMinBooks;

  @override
  State<PageBuy> createState() {
    return new PageBuyState();
  }

  static List<Package> getFilteredPackageList([int books, int sellers, int price]){
    var showingPackages = new List<Package>();
    if (books == null) books = PageBuy.filterMinBooks;
    if (sellers == null) sellers = PageBuy.filterMaxSellers;
    if (price == null) price = PageBuy.filterMaxPrice;
    for (Package p in packages){
      if (p.price < price)
        if (p.numOfSellers < sellers)
          if (p.books.length > books)
            showingPackages.add(p);
    }
    return showingPackages;
  }
}

class PageBuyState extends State<PageBuy>{

  bool loading = true;
  GlobalKey<DrawerControllerState> drawerKey = new GlobalKey<DrawerControllerState>();
  GlobalKey<PackageFilterDrawerState> drawerChildKey = new GlobalKey<PackageFilterDrawerState>();


  @override
  void initState() {

    if (thisUser.activePackage == null){
      NetCode.getPackages().then((pl) {
        packages = pl;
        setState(() => loading = false);
      });
    }else{
      if (thisUser.activePackage.populated){
        setState(() => loading = false);
      } else {
        NetCode.getPackage(thisUser.activePackage.id).then((pl){
          thisUser.activePackage = pl;
          setState(() => loading = false);
        });
      }
    }
    super.initState();
  }

  Widget buildFilterBar(BuildContext context){
    List<Widget> filterBarWidgets = [
      new Card(
          child: addPadding(new Text("Sort by: ${PageBuy.sortBy.toString().replaceAll("SortByOptions.",'')}"), const EdgeInsets.all(7.0))
      ),
    ];
    if (PageBuy.currentPriceStep != PageBuy.MAX_PRICE_STEP){
      filterBarWidgets.add(
        new Card(
            child: addPadding(new Text("\$${PageBuy.priceSteps[PageBuy.currentPriceStep]}"), const EdgeInsets.all(7.0))
        ),
      );
    }
    if (PageBuy.currentMaxSellersStep != PageBuy.MAX_MAX_SELLERS_STEP){
      filterBarWidgets.add(
        new Card(
            child: addPadding(new Text("<${PageBuy.maxSellersSteps[PageBuy.currentMaxSellersStep]} ${BKLocale.SELLERS}"), const EdgeInsets.all(7.0))
        ),
      );
    }
    if (PageBuy.currentMinBooks != 1){
      filterBarWidgets.add(
        new Card(
            child: addPadding(new Text(">${PageBuy.currentMinBooks} ${BKLocale.BOOKS.toLowerCase()}"), const EdgeInsets.all(7.0))
        ),
      );
    }
    filterBarWidgets.addAll([
      new Expanded(child: new Container()),
      new IconButton(icon: new Icon(Icons.filter_list), onPressed: (){
        if (drawerChildKey.currentState != null) drawerChildKey.currentState.widget.syncFilter();
        drawerKey.currentState.open();
      })
    ]);
    return new Padding(padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 5.0), child: new Row(
      children: filterBarWidgets
    ));
  }

  Widget buildSubHeader(BuildContext context, String text){
    return new Container(
      constraints: new BoxConstraints.expand(height: 27.0),
      child: addPadding(new Text("  " + text, style: LightStyle), const EdgeInsets.all(5.0)),
      //decoration: new BoxDecoration(border: new Border(bottom: new BorderSide(color: Colors.grey.withAlpha(55)))),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (loading){
      return new Scaffold(
        appBar: new AppBar(
          title: new Text(BKLocale.BAR_BUY),
          centerTitle: false,
        ),
        body: new Column(
          children: [
            new Expanded(child: new Container()),
            new Center(
                child: new Column(children: [
                  new SquareLoader(),
                  new Container(height: 10.0),
                  new Text(BKLocale.UPDATING_PACKAGES, style: SubHeaderStyle.copyWith(fontWeight: FontWeight.w200))
                ]),
            ),
            new Expanded(child: new Container()),
          ]
        )
      );
    }

    if (thisUser.activePackage != null){
      return new PagePackage(thisUser.activePackage);
    }

    Widget d = new DrawerController(
      alignment: DrawerAlignment.end,
      child: new PackageFilterDrawer((){
        setState((){
          drawerChildKey.currentState.widget.applyFilter();
          drawerKey.currentState.close();
        });
    }, key: drawerChildKey), key: drawerKey);

    // start filtering packages

    var showingPackages = PageBuy.getFilteredPackageList();

    // sort packages
    switch (PageBuy.sortBy){
      case SortByOptions.Score:
        showingPackages.sort((p1, p2) => (p2.score - p1.score).toInt());
        break;
      case SortByOptions.Price:
        showingPackages.sort((p1, p2) => (p1.price - p2.price).toInt());
        break;
      case SortByOptions.Sellers:
        showingPackages.sort((p1, p2) => (p1.numOfSellers - p2.numOfSellers));
        break;
      case SortByOptions.Books:
        showingPackages.sort((p1, p2) => (p2.books.length - p1.books.length));
        break;
    }


    var packageListWidget = new Stack(
        children: [ // after refresh retain filter
          new ListView.builder(
            itemCount: showingPackages.length + 3,
            itemBuilder: (bc, i) {
              if (i == 0)
                return buildFilterBar(context);
              else if (i == 1)
                return buildSubHeader(context, "Recommended");
              else if (i == 2)
                if (showingPackages.length > 0)
                  return new EntryPackage(showingPackages[0], true);
                else
                  return new Padding(padding: const EdgeInsets.symmetric(vertical: 50.0, horizontal: 40.0), child: new Text(BKLocale.NO_PACKAGES, textAlign: TextAlign.center,));
              else if (i == 3)
                return buildSubHeader(context, "Other Options");
              else
                return new EntryPackage(showingPackages[i - 3], false);
            },
          ),
          d
        ]
      );
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(BKLocale.BAR_BUY),
        centerTitle: false,
      ),
      body: new RefreshIndicator(child: packageListWidget,
        onRefresh: () {
          return refreshPackages();
        },),
      floatingActionButton: new FloatingActionButton(
        onPressed: () => Navigator.of(context).push(new MaterialPageRoute<int>(builder: (BuildContext context){
          return new ModalBooklist(true);
        },
        fullscreenDialog: true,
        )).then((success){ // if the update is successful
          if (success == null || success == 0) return; //no change
          if (success == 1){
            refreshPackages();
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
        heroTag: "booklistFloat",
      ),
    );
  }
  Future refreshPackages(){

    setState(() => loading = true);
    return NetCode.getPackages().then((pl) {
      packages = pl;
      setState(() => loading = false);
    });
  }
}
