import 'package:flutter/material.dart';
import '../Themes.dart';
import 'Selector.dart';
import '../PageBuy.dart';
import '../../lang.dart';


class PackageFilterDrawer extends StatefulWidget{

  VoidCallback confirmAction;
  int currentPriceStep;
  int currentMaxSellersStep;
  int currentMinBooks;
  SortByOptions currentSortBy;


  PackageFilterDrawer(this.confirmAction, {Key key}) : super(key: key){
    syncFilter();
  }

  @override
  State createState(){
    syncFilter();
    return new PackageFilterDrawerState();
  }

  void syncFilter(){
    currentMaxSellersStep = PageBuy.currentMaxSellersStep;
    currentMinBooks = PageBuy.currentMinBooks;
    currentPriceStep = PageBuy.currentPriceStep;
    currentSortBy = PageBuy.sortBy;
  }

  void applyFilter(){
    PageBuy.currentMaxSellersStep = (currentMaxSellersStep + 1) > 4 ? 4 : currentMaxSellersStep + 1;
    PageBuy.currentMinBooks = currentMinBooks;
    PageBuy.currentPriceStep = currentPriceStep;
    PageBuy.sortBy = currentSortBy;
  }
}

class PackageFilterDrawerState extends State<PackageFilterDrawer>{
  @override
  Widget build(BuildContext context) {
    Container container1 = new Container(padding: const EdgeInsets.all(7.0), child: new Column(
      children: [
        new Container(height: 10.0),
        new Container(alignment: FractionalOffset.centerLeft, padding: const EdgeInsets.all(5.0), child: new Text(BKLocale.PRICE, style: LightStyle.copyWith(fontSize: 16.0))),
        new Card(
          child: new Column(
            children: [
              new Container(
                padding: const EdgeInsets.all(10.0),
                alignment: FractionalOffset.centerRight,
                child: new Text("\$${PageBuy.priceSteps[widget.currentPriceStep]}", style: NormalStyle.copyWith(fontSize: 24.0),)
              ),
              new Slider(
                value: widget.currentPriceStep / PageBuy.MAX_PRICE_STEP.toDouble(),
                divisions: PageBuy.MAX_PRICE_STEP,
                onChanged: (d){
                  setState((){
                    widget.currentPriceStep = (d*PageBuy.MAX_PRICE_STEP.toDouble()).round();
                  });
                },
              )
            ]
          )
        ),
        new Container(alignment: FractionalOffset.centerLeft, padding: const EdgeInsets.all(5.0), child: new Text(BKLocale.NUMBER_OF_SELLERS, style: LightStyle.copyWith(fontSize: 16.0))),
        new Card(
            child: new Column(
                children: [
                  new Container(
                      padding: const EdgeInsets.all(10.0),
                      alignment: FractionalOffset.centerRight,
                      child: new Text("${PageBuy.maxSellersSteps[widget.currentMaxSellersStep]}", style: NormalStyle.copyWith(fontSize: 24.0),)
                  ),
                  new Slider(
                    value: widget.currentMaxSellersStep / PageBuy.MAX_MAX_SELLERS_STEP.toDouble(),
                    divisions: PageBuy.MAX_MAX_SELLERS_STEP,
                    onChanged: (d){
                      setState((){
                        widget.currentMaxSellersStep = (d*PageBuy.MAX_MAX_SELLERS_STEP.toDouble()).round();
                      });
                    },
                  )
                ]
            )
        ),
        new Container(alignment: FractionalOffset.centerLeft, padding: const EdgeInsets.all(5.0), child: new Text(BKLocale.MIN_BOOKS_MATCHED, style: LightStyle.copyWith(fontSize: 16.0))),
        new Card(
            child: new Column(
                children: [
                  new Container(
                      padding: const EdgeInsets.all(10.0),
                      alignment: FractionalOffset.centerRight,
                      child: new Text("${widget.currentMinBooks}", style: NormalStyle.copyWith(fontSize: 24.0),)
                  ),
                  new Slider(
                    value: widget.currentMinBooks / PageBuy.maxMatchingBooks.toDouble(),
                    divisions: 5,
                    onChanged: (d){
                      setState((){
                        widget.currentMinBooks = (d/1.0 * PageBuy.maxMatchingBooks).round();
                      });
                    },
                  )
                ]
            )
        )


      ]
    ));

    Container container2 = new Container(
      child: new Selector(BKLocale.SORT_BY, [
        BKLocale.SCORE,
        BKLocale.PRICE,
        BKLocale.SELLERS,
        BKLocale.BOOKS
      ],
        (i){
          widget.currentSortBy = SortByOptions.values[i];
        },
        selectedIndex: widget.currentSortBy.index,
      )
    );

    Widget container3 = new Padding(
      padding: const EdgeInsets.all(10.0),
      child: new FlatButton(
        color: Colors.blueGrey,

        child: new Text(BKLocale.SEARCH_RESULT.replaceAll("!no", PageBuy.getFilteredPackageList(widget.currentMinBooks, PageBuy.maxSellersSteps[widget.currentMaxSellersStep], PageBuy.priceSteps[widget.currentPriceStep]).length.toString()), style: LightStyle.copyWith(fontSize: 16.0, color: Colors.white)),
        onPressed: (){
          widget.confirmAction();
        },
      )
    );
    return new Container(
      color: Colors.grey.shade50,
      width: 300.0,
      child: new ListView(
        children:[
          container1,
          container2,
          container3
        ]
      )
    );
  }


}