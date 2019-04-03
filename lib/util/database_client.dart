import 'dart:io';
import 'package:no_todo_app/models/no_todo_item.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  final String tableName = "notodoTbl";
  final String columnId = "id";
  final String columnItemName = "itemName";
  final String columnDataCreated = "dateCreated";

  static Database _db;

  Future<Database> get db async {
    if(_db != null){
      return _db;
    }

    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "nodo_db.db");
    var ourDb = await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE $tableName(id INTEGER PRIMARY KEY, $columnItemName TEXT, $columnDataCreated TEXT)");
    print("Table is created");
  }

  //INSERTION
  Future<int> saveItem(NoDoItem item) async {
    var dbClient = await db;
    int res = await dbClient.insert("$tableName", item.toMap());
    print(res.toString());
    return res;
  }

  //GET
  Future<List> getItems () async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableName ORDER BY $columnItemName ASC");

    return result.toList();
//    if(result.length == 0){
//      return [];
//    }
//    var users = [];
//    for (Map<String, dynamic> map in result){
//      users.add(new User.fromMap(map));
//    }
//
//    return users;
  }

  //GET COUNT
  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(await dbClient.rawQuery("SELECT COUNT(1) FROM $tableName"));
  }

  //GET ONE
  Future<NoDoItem> getItem( int id) async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableName WHERE id = $id");
    if(result.length == 0 ) return null;
    return new NoDoItem.fromMap(result.first);
  }

  //DELETION
//  Future<int> deleteItem( int id) async {
//    var dbClient = await db;
//    var result = await dbClient.rawQuery("DELETE FROM $tableName WHERE id = $id");
//    if(result.length == 0 ) return null;
//    return result.first as int;
//  }

  //DELETE ITEM
  Future<int> deleteItem( int id) async {
    var dbClient = await db;
    return await dbClient.delete(tableName, where: "$columnId = ?", whereArgs: [id]);
  }

  //UPDATE ITEM
  Future<int> updateItem( NoDoItem item) async {
    var dbClient = await db;
    return await dbClient.update(tableName, item.toMap(), where: "$columnId = ? ", whereArgs: [item.id]);
  }

  Future close () async {
    var dbClient = await db;
    return dbClient.close();
  }

}