import '../Utils/Preferences.dart';
import 'dart:async';
import '../Utils/HelperFunctions.dart';
import '../Utils/NetCode.dart';
import '../Utils/DataVersion.dart';
import 'dart:convert';
import 'User.dart';
import 'Package.dart';

FullBooklist fullBookList = new FullBooklist();


Map<int, Subject> Subjects = {
  2: new Subject(2, "中國語文", "Chinese Language"),
  3: new Subject(3, "英語", "English Language"),
  4: new Subject(4, "數學", "Mathematics"),
  5: new Subject(5, "通識教育", "Liberal Studies"),
};

class Subject{
  final String _chName;
  final String _enName;
  final int id;

  String get name {
    if (Preferences.langChinese) return _chName;
    return _enName;
  }

  Subject(this.id, this._chName, this._enName);
  Subject.fromMap(Map m) : id = m["id"], _chName = m["subject_name_ch"], _enName = m["subject_name_en"];
}
class Book{



  final String name;
  final int subjectID;
  final int id;
  final String publisher;
  final String author;
  final String isbn;
  final int avgPrice;
  final String photoUrl;
  final List<int> form;
  int _mySellPrice;
  String mySellRemarks;
  int get mySellPrice {
    if (bookStatus != BookStatus.Selling) return null;
    if (_mySellPrice == null) _mySellPrice = avgPrice;
    return _mySellPrice;
  }
  set mySellPrice(int p){
    if (p == null)
      bookStatus = BookStatus.None;
    else
      bookStatus = BookStatus.Selling;
    _mySellPrice = p;
  }
  bool get isMatched {
    // Rewrite all object logic
    for (User u in users){
      if (u.matchedSellingBooks != null)
        for (BookListing bl in u.matchedSellingBooks)
          if (this.id == bl.book.id) return true;
    }
    return false;
  }
  BookStatus bookStatus = BookStatus.None;
  Map get asMap {
    return {
      "name": name,
      "subject_id": subjectID,
      "book_id": id,
      "publisher": publisher,
      "author": author,
      "isbn": isbn,
      "avg_price": avgPrice,
      "form": form,
      "photo_url": photoUrl,
    };
  }

  Book(this.id, this.name, this.subjectID, this.publisher): author = "", isbn = "", avgPrice=20, form=[0,1], photoUrl="";

  Book.fromMap(Map info) :
    name = info["name"],
    subjectID = info["subject_id"],
    id = info["book_id"],
    publisher = info["publisher"],
    author = info["author"],
    isbn = info["isbn"],
    avgPrice = info["avg_price"],
    form = info["form"],
    photoUrl = info["photo_url"];



  static Book byID(int id){
    for (Book b in fullBookList.books){
      if (b.id == id)
        return b;
    }
    return null;
  }


}

enum BookStatus{
  None,
  Buying,
  Selling
}

class FullBooklist extends Booklist{

  Future<bool> init() async{

    books = new List<Book>();
    // get from disc if any
    String s = await readFromFile('booklist');
    print(s);
    if (s != null && s.isNotEmpty) {
      Map ms = getMapByNodeFromJSON(s);
      if (ms["version"] == DataVersion.newestBooklist) {
        for (Map m in ms["books"]) {
          books.add(new Book.fromMap(m));
        }
        return true;
      } else
        return await _syncWithServerNew();
    } else
      return await _syncWithServerNew();

    /*return doWithRetry<bool>(
            () async { books = await NetCode.getFullBookList(); return books;},
            (r) => r != null
    );*/
  }

  Future<bool> _syncWithServerNew() async {
    var bls = await NetCode.getFullBookList();
    if (bls == null) return false;
    try {
      Map m = new Map();
      m["version"] = DataVersion.newestBooklist;
      var bs = new List<Map>();
      for (Book b in bls) {
        bs.add(b.asMap);
      }

      m["books"] = bs;
      books = bls;
      await writeFile('booklist', JSON.encode(m));
      return true;
    }
    catch (e){
      print(e.toString());
      return false;
    }
  }

}

class Booklist{

  static void resetBooklistStatus() {
    fullBookList.books.forEach((b) => b.bookStatus = BookStatus.None);
  }

  static void resetBooklistStatusForBuy() {
    fullBookList.books.forEach((b) {if (b.bookStatus == BookStatus.Buying) b.bookStatus = BookStatus.None;});
  }

  static void setBookStatus(Map<BookStatus, List<int>> m){
    for (Book b in fullBookList.books){
      b.bookStatus = BookStatus.None;
    }
    fullBookList.byIDs(m[BookStatus.Buying]).books.forEach((b) => b.bookStatus = BookStatus.Buying);
    fullBookList.byIDs(m[BookStatus.Selling]).books.forEach((b) => b.bookStatus = BookStatus.Selling);
  }

  List<Book> books = new List<Book>();



  Booklist byForm(int form){
    Booklist _filtered = new Booklist();
    for (Book b in books){
      if (b.form.contains(form)){
        _filtered.books.add(b);
      }
    }
    return _filtered;
  }

  Booklist bySubject(int subjectID){
    Booklist _filtered = new Booklist();
    for (Book b in books){
      if (b.subjectID == subjectID){
        _filtered.books.add(b);
      }
    }
    return _filtered;
  }

  Booklist byIDs(List<int> ids){
    Booklist _filtered = new Booklist();
    for (Book b in books){
      if (ids.contains(b.id))
        _filtered.books.add(b);
    }
    return _filtered;
  }

  Booklist byStatus(BookStatus bs){
    Booklist _filtered = new Booklist();
    for (Book b in books){
      if (b.bookStatus == bs)
        _filtered.books.add(b);
    }
    return _filtered;
  }




}