import '../Utils/NetCode.dart';
import 'dart:async';
import 'User.dart';
import 'Book.dart';
import 'dart:collection';
import '../UI/Components/ui_utils.dart';
import 'package:flutter/material.dart';
import '../lang.dart';

List<Package> packages = new List<Package>();
class BookListing{
  final Book book;
  final int price;
  final User partner;
  final String remarks;
  final int timestamp;

  BookListing(this.book, this.price, this.partner, [this.remarks = "No special remark for this listing.", this.timestamp = 0]);

  BookListing.fromMap(Map m):
    this.book = Book.byID(m["book_id"]),
    this.price = m["price"],
    this.partner = User.getUserByID(m["user_id"]),
    this.remarks = m["remarks"] ?? BKLocale.NO_REMARKS,
    this.timestamp = m.containsKey("timestamp") ? m["timestamp"].toInt() : 0;

}
enum PackageStatus{
  Available,
  Dealing,
  Finished,
  Expired
}
class Package{
  bool _populated = false;
  bool get populated => _populated;
  double score;
  final int id;
  PackageStatus status;
  String get statusStr {
    switch (status){
      case PackageStatus.Available:
        return BKLocale.AVAILABLE;
      case PackageStatus.Dealing:
        return BKLocale.DEALING;
      case PackageStatus.Finished:
        return BKLocale.FINISHED;
      case PackageStatus.Expired:
        return BKLocale.EXPIRED;
      default:
        return "";
    }
  }
  String get actionButtonStr {
    switch (status){
      case PackageStatus.Available:
        return BKLocale.CONFIRM_PACKAGE;
      case PackageStatus.Dealing:
        return BKLocale.DEALING;
      case PackageStatus.Finished:
        return BKLocale.FINISHED;
      case PackageStatus.Expired:
        return BKLocale.EXPIRED;
      default:
        return "";
    }
  }
  Color get statusStrColor {
    switch (status){
      case PackageStatus.Available:
        return Colors.lightGreen;
      case PackageStatus.Dealing:
        return Colors.orange;
      case PackageStatus.Finished:
        return Colors.blue;
      case PackageStatus.Expired:
        return Colors.red;
      default:
        return Colors.red;
    }
  }

  //bool get recommended => packages.reduce((p1, p2) => (p2.score > p1.score) ? p2 : p1) == this;
  List<BookListing> books;
  List<User> get sellers{
    var temp = new List<User>();
    for (BookListing bl in books){
      if (!temp.contains(bl.partner))
        temp.add(bl.partner);
    }
    return temp;
  }

  int get numOfSellers => sellers.length;

  double get price{
    var _price = 0.0;
    books.forEach((bl) => _price += bl.price);
    return _price;
  }

  //Package(this.id, this.header, this.active, this.recommended, this.score);

  Package.bareID(int id) : id = id;

  Package.fromMap(Map m) : id = m["package_id"], score = m["score"]{
    books = new List<BookListing>();
    for (Map mm in m["books"]){
      books.add(new BookListing.fromMap(mm));
    }
    switch (m["status"]){
      case "A":
        status = PackageStatus.Available;
        break;
      case "O":
        status = PackageStatus.Dealing;
        break;
      case "F":
        status = PackageStatus.Finished;
        break;
      default:
        status = PackageStatus.Available;
        break;
    }
    _populated = true;
  }

  String get sellersName {
    return sellers.map((u) => u.username).join(", ");
  }

  String get numOfBooksStr {
    return "${books.length}";///${fullBookList.byStatus(BookStatus.Buying).books.length}";
  }


  String numOfBooksStrBySeller(User seller)  {
    return "${getBookListingBySeller(seller).length}/${fullBookList.byStatus(BookStatus.Buying).books.length}";
  }


  Future populate() async{
    _populated = false;
    //TODO individual get package
    packages = await NetCode.getPackages();
    await NetCode.dummyFutureMethod();
    _populated = true;
  }

  Future<bool> confirm() async {
    Package b = await NetCode.confirmPackage(this);
    if (b == null) return false;
    thisUser.activePackage = b;
    return true;
  }

  Widget getIcon(bool recommended, [double size = 32.0]){
    if (numOfSellers > 2){
      return addPadding(new Container(
        child: new Image.asset('assets/package/3_ppl_icon.png', width: size, height: size, fit: BoxFit.fill,
            color: recommended ? Colors.lime : Colors.blue,),
      ), const EdgeInsets.only(right: 15.0));
    }

    return addPadding(new Icon(
        numOfSellers > 1 ? Icons.people : Icons.person,
        color: recommended ? Colors.lime : Colors.blue,
        size: size
    ), const EdgeInsets.only(right: 15.0));
  }

  List<BookListing> getBookListingBySeller(User seller){
    return books.where((b) => b.partner.id == seller.id).toList();
  }

}