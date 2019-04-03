import 'package:flutter/material.dart';
import 'package:no_todo_app/models/no_todo_item.dart';
import 'package:no_todo_app/util/database_client.dart';

class NoTodoScreen extends StatefulWidget {
  @override
  _NoTodoScreenState createState() => _NoTodoScreenState();
}

class _NoTodoScreenState extends State<NoTodoScreen> {
  final TextEditingController _textEditingController = new TextEditingController();
  final List<NoDoItem> _itemList = <NoDoItem>[];
  var db = new DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _readNoDoList();
  }

  void _handleSubmitted(String text) async {
    _textEditingController.clear();
    print("RECIVED: $text");
    NoDoItem noDoItem = new NoDoItem(text, new DateTime.now().toIso8601String());
    int savedItemId = await db.saveItem(noDoItem);
    print("Item saved id: $savedItemId ");
    NoDoItem addedItem = await db.getItem(savedItemId );

    setState(() {
      _itemList.insert(0, addedItem);
    });

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.black87,
      body: new Column(
        children: <Widget>[
          new Flexible(
              child: new ListView.builder(
                  padding: new EdgeInsets.all(8.0),
                  reverse: false,
                  itemCount: _itemList.length,
                  itemBuilder: (_, int index) {
                    return new Card(
                      color: Colors.white10,
                      child: new ListTile(
                        title: _itemList[index],
                        onLongPress: () => debugPrint(""),
                        trailing: new Listener(
                          key: new Key(_itemList[index].itemName),
                          child: new Icon(Icons.remove_circle, color: Colors.redAccent),
                          onPointerDown: (pointerEvent) => debugPrint(""),
                        ),
                      ),
                    );
                  }
              )
          ),
          new Divider(
            height: 1.0,
          ),
        ],
      ),

      floatingActionButton: new FloatingActionButton(
          tooltip: "Add Item",
          backgroundColor: Colors.redAccent,
          child: new ListTile(
            title: new Icon(Icons.add)
          ),
          onPressed: _showFormDialog
      ),
    );
  }

  void _showFormDialog(){
    var alert = new AlertDialog(
      content: new Row(
        children: <Widget>[
          new Expanded(
              child: new TextField(
                controller: _textEditingController,
                autofocus: true,
                decoration: new InputDecoration(
                  labelText: "Item",
                  hintText: "eg. Don't buy stuff",
                  icon: new Icon(Icons.note_add)
                ),
              )
          )
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: (){
              _handleSubmitted(_textEditingController.text);
              _textEditingController.clear();
            },
            child: Text("Save")
        ),
        new FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel")
        )
      ],
    );
    showDialog(
      context: context,
      builder: (_) {
        return alert;
      }
    );
  }

  _readNoDoList() async {
    List items = await db.getItems();
    items.forEach((item) {
      NoDoItem noDoItem = NoDoItem.fromMap(item);
      print("DB items: ${noDoItem.itemName}");
    });
  }

}
