import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/habit.dart';

class HabitDatabase {
  static final HabitDatabase instance = HabitDatabase._init();
  static Database? _database;

  HabitDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('habits.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';

    await db.execute('''
CREATE TABLE habits ( 
  ${HabitFields.id} $idType, 
  ${HabitFields.name} $textType,
  ${HabitFields.completed} $boolType
  )
''');
  }

  Future<Habit> create(Habit habit) async {
    final db = await instance.database;
    final id = await db.insert('habits', habit.toJson());
    return habit.copy(id: id);
  }

  Future<List<Habit>> readAllHabits() async {
    final db = await instance.database;
    final orderBy = '${HabitFields.id} ASC';
    final result = await db.query('habits', orderBy: orderBy);
    return result.map((json) => Habit.fromJson(json)).toList();
  }

  Future<int> update(Habit habit) async {
    final db = await instance.database;
    return db.update(
      'habits',
      habit.toJson(),
      where: '${HabitFields.id} = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'habits',
      where: '${HabitFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
