import 'package:animal_case_study/patchConnectionPage.dart';
import 'package:animal_case_study/util/ble_provider.dart';
import 'package:animal_case_study/util/database_util.dart';
import 'package:animal_case_study/util/global_variable_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color:true);
  final db = DatabaseUtil();
  print("db get database");
  await db.database;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BLEProvider()),
      ],
      child: const AnimalCaseStudy(),
    ),
  );
}

class AnimalCaseStudy extends StatelessWidget {
  const AnimalCaseStudy({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      navigatorKey: GlobalVariableSetting.navigatorState,
      debugShowCheckedModeBanner: false,
      home: const PatchConnectionPage(),
    );
  }
}