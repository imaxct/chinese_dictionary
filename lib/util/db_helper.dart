import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  DbHelper._();

  static final DbHelper instance = DbHelper._();

  static late final Database _database;

  Database get database {
    return _database;
  }

  Future<void> init() async {
    _database = await _initDatabase();
  }

  _initDatabase() async {
    var dbPath = await getDatabasesPath();
    var path = join(dbPath, 'content.db');
    var exist = await databaseExists(path);
    if (!exist) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}
    }

    var data = await rootBundle.load(join('assets', 'db', 'content.db'));
    var bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);

    return await openReadOnlyDatabase(path);
  }
}
