import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/aircraft.dart';

class StorageService {
  static const String _aircraftsKey = 'pid_tuner_aircrafts';

  /// 获取所有飞机档案
  static Future<List<Aircraft>> getAircrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_aircraftsKey);
    
    if (jsonString == null) return [];
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Aircraft.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  /// 保存飞机档案
  static Future<void> saveAircraft(Aircraft aircraft) async {
    final prefs = await SharedPreferences.getInstance();
    final aircrafts = await getAircrafts();
    
    // 检查是否已存在（更新）
    final existingIndex = aircrafts.indexWhere((a) => a.id == aircraft.id);
    if (existingIndex >= 0) {
      aircrafts[existingIndex] = aircraft;
    } else {
      aircrafts.add(aircraft);
    }
    
    final jsonString = jsonEncode(aircrafts.map((a) => a.toJson()).toList());
    await prefs.setString(_aircraftsKey, jsonString);
  }

  /// 删除飞机档案
  static Future<void> deleteAircraft(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final aircrafts = await getAircrafts();
    
    aircrafts.removeWhere((a) => a.id == id);
    
    final jsonString = jsonEncode(aircrafts.map((a) => a.toJson()).toList());
    await prefs.setString(_aircraftsKey, jsonString);
  }

  /// 清空所有档案
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_aircraftsKey);
  }
}