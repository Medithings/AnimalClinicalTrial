import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUtil{
  late final SharedPreferences? _sharedPrefs;

  static final SharedPrefsUtil _instance = SharedPrefsUtil._internal();

  factory SharedPrefsUtil() => _instance;
  SharedPrefsUtil._internal();

  Future<void> init() async{
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  int get gainType => _sharedPrefs?.getInt("gainType") ?? 0;

  set gainType(int x) => _sharedPrefs?.setInt("gainType", x);

}