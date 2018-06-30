import 'package:flutter/material.dart';
import '../Themes.dart';

class Selector extends StatefulWidget{
  String caption;
  List<String> options;
  int selectedIndex;
  Function(int i) onChanged;

  Selector(this.caption, this.options, this.onChanged, {this.selectedIndex=0});

  @override
  State createState() {
    return new SelectorState();
  }
}

class SelectorState extends State<Selector>{

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<int>> sortLists = widget.options.map((s) => new DropdownMenuItem<int>(value: widget.options.indexOf(s), child: new Text(s, style: LightStyle))).toList();
    Container c = new Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      margin: const EdgeInsets.symmetric(vertical: 7.0),
      decoration: new BoxDecoration(
        color: Colors.white,
        border: new Border(
          top: new BorderSide(color: Colors.black12),
          bottom: new BorderSide(color: Colors.black12),
        )
      ),
      child: new Row(
        children: [
          new Text("   ${widget.caption}", style: NormalStyle.copyWith(fontSize: 19.0)),
          new Expanded(child: new Container()),
          new DropdownButtonHideUnderline(
            child: new DropdownButton<int>(
              iconSize: 0.0,
              isDense: true,
              value: widget.selectedIndex,
              style: LightStyle.copyWith(fontSize: 19.0, color: Colors.lightBlue),
              items: sortLists,
              onChanged: (i){
                widget.onChanged(i);
                setState(() => widget.selectedIndex = i);
              }
            )
          ),
          new Container(width: 20.0),
        ]
      )
    );
    return c;
  }
}