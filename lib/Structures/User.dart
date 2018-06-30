import 'Chats.dart';
import 'Book.dart';
import 'dart:async';
import '../Utils/NetCode.dart';
import 'Package.dart';
import 'package:flutter/material.dart';
import '../Utils/DataVersion.dart';
import '../Utils/HelperFunctions.dart';
import 'dart:convert';
import '../lang.dart';

ThisUser thisUser;

List<User> users = new List<User>();

class ThisUser extends User{

  int buyForm = 4;
  Package activePackage;
  String schoolNameCh;
  String schoolNameEn;
  ThisUser(int id) : super(id){
    users.add(this);
  }
  String accessToken;
  List<History> histories;


  void setSchoolName(String _ch, String _en) { schoolNameEn = _en; schoolNameCh = _ch; }
  void setBuyForm(int _form) => buyForm = _form;

}

class User{
  final int id;
  String profilePicture;
  String username;
  int form = 3;
  List<BookListing> matchedSellingBooks;

  String phoneNumber;
  List<ChatMessage> chats;
  int _lastReadChatID = 0;
  int get lastReadChatID => _lastReadChatID;
  bool oldChatPopulated = false;

  void setLastReadChat(){
    if (chats[0].id == null) return;
    if (chats.length > 0) {
      _lastReadChatID = chats[0].id;
      DataVersion.prefs.setInt('last_read_$id', _lastReadChatID);
      DataVersion.prefs.commit();
    }
  }

  void saveChatsToDisk(){

    print("saving chats...");
    chats.sort((cm1, cm2) => cm2.timestamp - cm1.timestamp);
    writeFile('chats-' + id.toString(), json.encode({"partner_username": username, "messages": chats.map((cm) => cm.asMap).toList()}));
  }

  User(this.id){
    username = "($id)";
    chats = new List<ChatMessage>();
    _lastReadChatID = DataVersion.prefs.getInt('last_read_$id') ?? 0;
  }
  User setFromSimpleMap(Map m) => this.setUsername(m["username"]).setProfilePicture(m["profile_picture"]);
  User setUsername(String _username) { username = _username; return this;}
  User setForm(int _form) { form = _form; return this;}
  User setProfilePicture(String _url) { profilePicture = _url; return this;}
  User setPhoneNumber(String _phoneNumber) { phoneNumber = _phoneNumber; return this; }

  int get earliestChatID {
    // in case the list is not sorted
    var firstChatID = 2147483646;
    for (ChatMessage c in chats){
      if (c.id != null && c.id < firstChatID){
        firstChatID = c.id;
      }
    }
    return firstChatID;
  }

  int get latestChatID {
    // in case the list is not sorted
    var lastChatID = 0;
    for (ChatMessage c in chats){
      if (c.id != null && c.id > lastChatID){
        lastChatID = c.id;
      }
    }
    return lastChatID;
  }


  static User getUserByID(int id){
    if (thisUser != null && thisUser.id == id) return thisUser;
    for (User u in users){
      if  (u.id == id)
        return u;
    }
    User u = new User(id);
    users.add(u);
    return u;
  }

  static List<User> getUsersWithChats(){
    var l = new List<User>();
    for (User u in users){
      if  (thisUser.id != u.id && u.chats.length > 0)
        l.add(u);
    }
    l.sort((u1,u2) {
      var latestu1chat = u1.chats.reduce((c1,c2) => c1.timestamp > c2.timestamp ? c1 : c2).timestamp;
      var latestu2chat = u2.chats.reduce((c1,c2) => c1.timestamp > c2.timestamp ? c1 : c2).timestamp;
      return latestu2chat - latestu1chat;
    });
    return l;
  }



  /*void setMatchedSellingBooks(Map m){
    matchedSellingBooks = new List<BookListing>();
    for (Map bl in m["books"])
      matchedSellingBooks.add(new BookListing(Book.byID(bl["book_id"]), bl["price"], this, bl["remarks"]));
  }*/

  ChatMessage getMostRecentChat(){
    return chats.last;
  }


}


enum HistoryType{
  Buy,
  Sell,
  Cancel,
  Package
}

class History {
  final HistoryType type;
  final List<Book> books;
  final int timestamp;
  final User partner;

  History({HistoryType type, List<Book> books, int timestamp, User partner}): this.type = type, this.books = books, this.timestamp = timestamp, this.partner = partner;

  get color {
    switch (type){
      case HistoryType.Cancel:
        return Colors.red;
      case HistoryType.Buy:
        return Colors.green;
      case HistoryType.Sell:
        return Colors.green;
      case HistoryType.Package:
        return Colors.yellow;
    }
  }

  get icon {
    switch (type){
      case HistoryType.Cancel:
        return Icons.clear;
      case HistoryType.Buy:
        return Icons.done;
      case HistoryType.Sell:
        return Icons.done;
      case HistoryType.Package:
        return Icons.account_box;
    }
  }

  get description{
    switch (type){
      case HistoryType.Cancel:
        return BKLocale.TRADE_CANCELLED_USER.replaceAll("!user", partner.username).replaceAll("!no", books.length.toString());
      case HistoryType.Buy:
        return BKLocale.COMPLETED_BUY_USER.replaceAll("!user", partner.username).replaceAll("!no", books.length.toString());
      case HistoryType.Sell:
        return BKLocale.COMPLETED_SELL_USER.replaceAll("!user", partner.username).replaceAll("!no", books.length.toString());
      case HistoryType.Package:
        return BKLocale.PACKAGE_COMPLETED;
    }
  }

  static HistoryType charToType(String c){
    switch(c){
      case "B":
        return HistoryType.Buy;
      case "S":
        return HistoryType.Sell;
      case "P":
        return HistoryType.Package;
      default:
        return HistoryType.Cancel;
    }
  }
}