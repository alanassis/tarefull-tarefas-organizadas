import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(
          primaryColor: Color(0xff9c4dcc), hintColor: Color(0xff9c4dcc)),
    ));

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  final _toDoController = new TextEditingController();
  List _toDoList = [];
  Map<String, dynamic> lastToDo = {};

  void _addToDo() {
    Map<String, dynamic> _newToDo = Map();
    _newToDo['title'] = _toDoController.text;
    _newToDo['done'] = false;

    _toDoController.text = "";
    _saveData();
    setState(() {
      _toDoList.add(_newToDo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tarefull - Tarefas Organizadas"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Container(
        padding: EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Descreva sua Tarefa'),
                  controller: _toDoController,
                )),
                IconButton(
                    icon: Icon(Icons.add_circle),
                    iconSize: 40.0,
                    color: Colors.purple,
                    onPressed: _addToDo)
              ],
            ),
            Expanded(
                child: ListView.builder(
                    padding: EdgeInsets.only(top: 20.0),
                    itemCount: _toDoList.length,
                    itemBuilder: buildItem))
          ],
        ),
      ),
    );
  }

  Widget buildItem(context, index) {
    return Dismissible(
      key: ObjectKey(_toDoList[index]),
      direction: DismissDirection.horizontal,
      background: Container(
        color: Colors.green,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(Icons.check, color: Colors.white),
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(0.9, 0.0),
          child: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      child: ListTile(
        title: Text(_toDoList[index]["title"]),
        leading: currentIcon(_toDoList[index]['done']),
        onTap: () {
          setState(() {
            _toDoList[index]['done'] = !_toDoList[index]['done'];
          });
          _saveData();
        },
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          setState(() {
            _toDoList[index]['done'] = true;
          });
          _saveData();
          print(ObjectKey(_toDoList[index]).hashCode);
          return false;
        } else {
          return true;
        }
      },
      onDismissed: (direction) {
        lastToDo = {"todo": _toDoList[index], "index": index};
        setState(() {
          _toDoList.removeAt(index);
        });
        _saveData();

        Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Tarefa excluída"),
            action: SnackBarAction(
              label: 'Desfazer',
              onPressed: () {
                setState(() {
                  _toDoList.insert(lastToDo["index"], lastToDo["todo"]);
                });
                _saveData();
              },
            )));
      },
    );
  }

// CheckboxListTile(
//
//           onChanged: (bool newValue) {
//             setState(() {
//               _toDoList[index]['done'] = newValue;
//             });
//             _saveData();
//           }),
//     );

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final dir = await _getFile();
      return dir.readAsString();
    } catch (e) {
      return null;
    }
  }

  Widget currentIcon(value) {
    if (value == true) {
      return Icon(Icons.check_circle, color: Colors.green, size: 40.0);
    } else {
      return Icon(Icons.radio_button_unchecked,
          color: Colors.purple, size: 40.0);
    }
  }
}
