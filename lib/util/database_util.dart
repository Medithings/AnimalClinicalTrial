import 'dart:async';
import 'package:animal_case_study/model/measure_values.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '../model/agc_values.dart';

class DatabaseUtil{
  Database? _database;

  Future<Database> get database async{
    if(_database != null) {
      print("[DB] has database");
      return _database!;
    }

    print("[DB] openning DB");
    return await initDB();
  }

  initDB() async{
    print("[DB] init DB");
    String path = p.join(await getDatabasesPath(), 'mediLight.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      readOnly: false,
    );
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) {}

  FutureOr<void> _onCreate(Database db, int version){
    print("[Database] onCreate DB");

    db.execute('''
    CREATE TABLE agc_values(
      timeStamp TEXT,
      LEDNUM TEXT,
      led1 REAL,
      led2 REAL,
      led3 REAL,
      led4 REAL,
      led5 REAL,
      led6 REAL,
      led7 REAL,
      led8 REAL,
      led9 REAL,
      led10 REAL,
      led11 REAL,
      led12 REAL,
      led13 REAL,
      led14 REAL,
      led15 REAL,
      led16 REAL,
      led17 REAL,
      led18 REAL,
      led19 REAL,
      led20 REAL,
      led21 REAL,
      led22 REAL,
      led23 REAL,
      led24 REAL,
      led25 REAL,
      PRIMARY KEY(timeStamp, LEDNUM)
      );
    ''');

    db.execute(''' 
    CREATE TABLE measured(
      mTimeStamp TEXT,
      bat INTEGER,
      temp REAL,
      acc_x REAL, acc_y REAL, acc_z REAL, gyr_x REAL, gyr_y REAL, gyr_z REAL,
      comment TEXT,
      volume INTEGER,
      power TEXT,
      
      LED1_PD5 REAL, LED1_PD6 REAL, LED1_PD7 REAL, LED1_PD8 REAL, LED1_PD9 REAL, LED1_PD10 REAL,
      LED2_PD5 REAL, LED2_PD6 REAL, LED2_PD7 REAL, LED2_PD8 REAL, LED2_PD9 REAL, LED2_PD10 REAL, 
      LED3_PD5 REAL, LED3_PD6 REAL, LED3_PD7 REAL, LED3_PD8 REAL, LED3_PD9 REAL, LED3_PD10 REAL, 
      LED4_PD5 REAL, LED4_PD6 REAL, LED4_PD7 REAL, LED4_PD8 REAL, LED4_PD9 REAL, LED4_PD10 REAL, 
      LED5_PD5 REAL, LED5_PD6 REAL, LED5_PD7 REAL, LED5_PD8 REAL, LED5_PD9 REAL, LED5_PD10 REAL,
      LED6_PD5 REAL, LED6_PD6 REAL, LED6_PD7 REAL, LED6_PD8 REAL, LED6_PD9 REAL, LED6_PD10 REAL,
      
      LED7_PD6 REAL, LED7_PD5 REAL, LED7_PD4 REAL, LED7_PD3 REAL, LED7_PD2 REAL, LED7_PD1 REAL,
      LED8_PD6 REAL, LED8_PD5 REAL, LED8_PD4 REAL, LED8_PD3 REAL, LED8_PD2 REAL, LED8_PD1 REAL,
      LED9_PD6 REAL, LED9_PD5 REAL, LED9_PD4 REAL, LED9_PD3 REAL, LED9_PD2 REAL, LED9_PD1 REAL,
      LED10_PD6 REAL, LED10_PD5 REAL, LED10_PD4 REAL, LED10_PD3 REAL, LED10_PD2 REAL, LED10_PD1 REAL,
      LED11_PD6 REAL, LED11_PD5 REAL, LED11_PD4 REAL, LED11_PD3 REAL, LED11_PD2 REAL, LED11_PD1 REAL,
      LED12_PD6 REAL, LED12_PD5 REAL, LED12_PD4 REAL, LED12_PD3 REAL, LED12_PD2 REAL, LED12_PD1 REAL,
      
      LED13_PD15 REAL, LED13_PD16 REAL, LED13_PD17 REAL, LED13_PD18 REAL, LED13_PD19 REAL, LED13_PD20 REAL,
      LED14_PD15 REAL, LED14_PD16 REAL, LED14_PD17 REAL, LED14_PD18 REAL, LED14_PD19 REAL, LED14_PD20 REAL,
      LED15_PD15 REAL, LED15_PD16 REAL, LED15_PD17 REAL, LED15_PD18 REAL, LED15_PD19 REAL, LED15_PD20 REAL,
      LED16_PD15 REAL, LED16_PD16 REAL, LED16_PD17 REAL, LED16_PD18 REAL, LED16_PD19 REAL, LED16_PD20 REAL,
      LED17_PD15 REAL, LED17_PD16 REAL, LED17_PD17 REAL, LED17_PD18 REAL, LED17_PD19 REAL, LED17_PD20 REAL,
      LED18_PD15 REAL, LED18_PD16 REAL, LED18_PD17 REAL, LED18_PD18 REAL, LED18_PD19 REAL, LED18_PD20 REAL,
      LED19_PD16 REAL, LED19_PD15 REAL, LED19_PD14 REAL, LED19_PD13 REAL, LED19_PD12 REAL, LED19_PD11 REAL,
      LED20_PD16 REAL, LED20_PD15 REAL, LED20_PD14 REAL, LED20_PD13 REAL, LED20_PD12 REAL, LED20_PD11 REAL,
      
      LED21_PD16 REAL, LED21_PD15 REAL, LED21_PD14 REAL, LED21_PD13 REAL, LED21_PD12 REAL, LED21_PD11 REAL,
      LED22_PD16 REAL, LED22_PD15 REAL, LED22_PD14 REAL, LED22_PD13 REAL, LED22_PD12 REAL, LED22_PD11 REAL,
      LED23_PD16 REAL, LED23_PD15 REAL, LED23_PD14 REAL, LED23_PD13 REAL, LED23_PD12 REAL, LED23_PD11 REAL,
      LED24_PD16 REAL, LED24_PD15 REAL, LED24_PD14 REAL, LED24_PD13 REAL, LED24_PD12 REAL, LED24_PD11 REAL,
      
      PRIMARY KEY(mTimeStamp)
      );
    ''');
  }

  Future<void> insertingAGC(AgcValues item) async{
    var db = await database;

    await db.insert(
        'agc_values',
        item.toMap()
    );
  }

  Future<void> insertingMeasured(MeasuredValues item) async{
    var db = await database;

    await db.insert(
        'measured',
        item.toMap()
    );
  }

  Future<List<int>> countSevenHundred() async {
    var db = await database;
    String sqlQuery =
    """SELECT count(*) from (SELECT * from measured order by mTimeStamp desc limit 1)
    where 
    LED1_PD5>700 and
    LED1_PD6>700 and
    LED1_PD7>700 and
    LED1_PD8>700 and
    LED1_PD9>700 and
    LED1_PD10>700 and
      LED2_PD5>700 and
    LED2_PD6>700 and
    LED2_PD7>700 and
    LED2_PD8>700 and
    LED2_PD9>700 and
    LED2_PD10>700 and
     LED3_PD5>700 and
    LED3_PD6>700 and
    LED3_PD7>700 and
    LED3_PD8>700 and
    LED3_PD9>700 and
    LED3_PD10>700 and
     LED4_PD5>700 and
    LED4_PD6>700 and
    LED4_PD7>700 and
    LED4_PD8>700 and
    LED4_PD9>700 and
    LED4_PD10>700 and
     LED5_PD5>700 and
    LED5_PD6>700 and
    LED5_PD7>700 and
    LED5_PD8>700 and
    LED5_PD9>700 and
    LED5_PD10>700 and
     LED6_PD5>700 and
    LED6_PD6>700 and
    LED6_PD7>700 and
    LED6_PD8>700 and
    LED6_PD9>700 and
    LED6_PD10>700 and
     LED7_PD6>700 and
    LED7_PD5>700 and
    LED7_PD4>700 and
    LED7_PD3>700 and
    LED7_PD2>700 and
    LED7_PD1>700 and
      LED8_PD6>700 and
    LED8_PD5>700 and
    LED8_PD4>700 and
    LED8_PD3>700 and
    LED8_PD2>700 and
    LED8_PD1>700 and
      LED9_PD6>700 and
    LED9_PD5>700 and
    LED9_PD4>700 and
    LED9_PD3>700 and
    LED9_PD2>700 and
    LED9_PD1>700 and
      LED10_PD6>700 and
    LED10_PD5>700 and
    LED10_PD4>700 and
    LED10_PD3>700 and
    LED10_PD2>700 and
    LED10_PD1>700 and
     LED11_PD6>700 and
    LED11_PD5>700 and
    LED11_PD4>700 and
    LED11_PD3>700 and
    LED11_PD2>700 and
    LED11_PD1>700 and
     LED12_PD6>700 and
    LED12_PD5>700 and
    LED12_PD4>700 and
    LED12_PD3>700 and
    LED12_PD2>700 and
    LED12_PD1>700 and
     LED13_PD15>700 and
    LED13_PD16>700 and
    LED13_PD17>700 and
    LED13_PD18>700 and
    LED13_PD19>700 and
    LED13_PD20>700 and
      LED14_PD15>700 and
    LED14_PD16>700 and
    LED14_PD17>700 and
    LED14_PD18>700 and
    LED14_PD19>700 and
    LED14_PD20>700 and
      LED15_PD15>700 and
    LED15_PD16>700 and
    LED15_PD17>700 and
    LED15_PD18>700 and
    LED15_PD19>700 and
    LED15_PD20>700 and
      LED16_PD15>700 and
    LED16_PD16>700 and
    LED16_PD17>700 and
    LED16_PD18>700 and
    LED16_PD19>700 and
    LED16_PD20>700 and
      LED17_PD15>700 and
    LED17_PD16>700 and
    LED17_PD17>700 and
    LED17_PD18>700 and
    LED17_PD19>700 and
    LED17_PD20>700 and
      LED18_PD15>700 and
    LED18_PD16>700 and
    LED18_PD17>700 and
    LED18_PD18>700 and
    LED18_PD19>700 and
    LED18_PD20>700 and
      LED19_PD16>700 and
    LED19_PD15>700 and
    LED19_PD14>700 and
    LED19_PD13>700 and
    LED19_PD12>700 and
    LED19_PD11>700 and
      LED20_PD16>700 and
    LED20_PD15>700 and
    LED20_PD14>700 and
    LED20_PD13>700 and
    LED20_PD12>700 and
    LED20_PD11>700 and
      LED21_PD16>700 and
    LED21_PD15>700 and
    LED21_PD14>700 and
    LED21_PD13>700 and
    LED21_PD12>700 and
    LED21_PD11>700 and
      LED22_PD16>700 and
    LED22_PD15>700 and
    LED22_PD14>700 and
    LED22_PD13>700 and
    LED22_PD12>700 and
    LED22_PD11>700 and
      LED23_PD16>700 and
    LED23_PD15>700 and
    LED23_PD14>700 and
    LED23_PD13>700 and
    LED23_PD12>700 and
    LED23_PD11>700 and
      LED24_PD16>700 and
    LED24_PD15>700 and
    LED24_PD14>700 and
    LED24_PD13>700 and
    LED24_PD12>700 and
    LED24_PD11>700;
    """;
    final List<Map<String, dynamic>> map = await db.rawQuery(sqlQuery);

    return List.generate(map.length, (index){
      return int.parse(map[index]["count(*)"]);
    });
  }

  Future<List<AgcValues>> getAgcValues() async{
    var db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery("SELECT * FROM agc_values");

    return List.generate(maps.length, (index){
     return AgcValues(
       timeStamp: maps[index]["timeStamp"] as String,
       lednum: maps[index]["LEDNUM"] as String,
       led1: maps[index]["led1"] as double,
       led2: maps[index]["led1"] as double,
     );
    });
  }
}