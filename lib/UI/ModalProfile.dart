//{username, bio, male, form, phone_number, address, school_id, school_join_code}
import 'package:flutter/material.dart';
import 'Components/SquareLoader.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'themes.dart';
import '../Utils/Accounts.dart';
import 'MainScreen.dart';
import '../lang.dart';
import '../Structures/Book.dart';
import '../Utils/DataVersion.dart';
import '../main.dart';
import '../Utils/DataVersion.dart';
import '../Structures/User.dart';
import 'Components/Selector.dart';

class ModalProfile extends StatefulWidget{

  final bool register;

  ModalProfile(this.register);

  @override
  State createState() {
    return new ModalProfileState();
  }
}

class ModalProfileState extends State<ModalProfile>{

  String username;
  String bio;
  bool male;
  int form;
  String phoneNumber;
  String address;
  int schoolID;
  String schoolJoinCode;

  TextEditingController cUsername;
  TextEditingController cPhoneNumber;
  TextEditingController cAddress;
  TextEditingController cSchoolJoinCode;


  @override
  void initState() {
    cUsername = new TextEditingController(text: widget.register ? "" : thisUser.username);
    cPhoneNumber = new TextEditingController(text: widget.register ? "" : thisUser.phoneNumber);
    cAddress = new TextEditingController();
    cSchoolJoinCode = new TextEditingController();

    cUsername.addListener(() => username = cUsername.text);
    cPhoneNumber.addListener(() => phoneNumber = cPhoneNumber.text);
    cAddress.addListener(() => address = cAddress.text);
    cSchoolJoinCode.addListener(() => schoolJoinCode = cSchoolJoinCode.text);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Register"),
        backgroundColor: Colors.blue,
        actions: [
          new Builder(builder: (bc) => new FlatButton(
            child: new Text("SEND", style: NormalStyle.copyWith(color: Colors.white),),
            onPressed: (){
              submit(bc);
            },
          )),
        ]
      ),
      body: new ListView(
        children:[
          new Padding(child: new TextField(
            controller: cUsername,
            decoration: const InputDecoration(
              icon: const Icon(Icons.verified_user),
              labelText: 'Display Name'
            ),
          ), padding: const EdgeInsets.all(10.0)),
          new Padding(child: new TextField(
            controller: cPhoneNumber,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
                icon: const Icon(Icons.phone),
                labelText: 'Phone Number'
            ),
          ), padding: const EdgeInsets.all(10.0)),
          new Padding(child: new TextField(
            controller: cAddress,
            decoration: const InputDecoration(
                icon: const Icon(Icons.home),
                labelText: 'District'
            ),
          ), padding: const EdgeInsets.all(10.0)),
          new Selector(
            "School",
            DataVersion.schools.values.toList(),
            (i){}
          ),
          new Selector(
            "Secondary",
            ["1","2","3","4","5","6"],
            (i){}
          ),
          new Padding(child: new TextField(
            controller: cSchoolJoinCode,
            decoration: const InputDecoration(
                icon: const Icon(Icons.code),
                labelText: 'School Join Code (Optional)'
            ),
          ), padding: const EdgeInsets.all(10.0)),
        ]
      ),

    );
  }

  void submit(BuildContext context){
    var message = "";
    var okay = true;

    //TODO: DEBUG
    schoolID = 1;
    male = true;
    bio = "";
    form = 3;


    if (username == null || username.length < 5) {
      message += "Username must be longer than 5 characters.\n";
      okay = false;
    }
    if (phoneNumber == null || phoneNumber.length < 8){
      message += "Not valid phone number.\n";
      okay = false;
    }

    if (address == null || address.length < 3){
      message += "Not valid location.\n";
      okay = false;
    }

    if (schoolID == null){
      message += "Please enter a school.\n";
      okay = false;
    }

    if (schoolJoinCode != null && schoolJoinCode.length != 6 && schoolJoinCode.length != 0){
      message += "Please enter a valid join code.\n";
      okay = false;
    }

    if (okay)
      Navigator.of(context).pop({
        "username": username,
        "bio": bio,
        "male": male,
        "form": form,
        "phone_number": phoneNumber,
        "address": address,
        "school_id": schoolID,
        "school_join_code": schoolJoinCode
      });
    else
      Scaffold.of(context).showSnackBar(new SnackBar(content: new Text(message), duration: new Duration(
        seconds: message.length ~/ 30,
      )));
  }
}