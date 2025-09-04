import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../hive&web/websocket.dart';
import '../notif/not.dart';
import '../widget/appbar.dart';
import '../widget/navbar.dart';

class homescreen extends StatefulWidget {
  const homescreen({super.key});

  @override
  State<homescreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<homescreen> with WidgetsBindingObserver {
  bool _isStarted = false;

  late WebSocketService _wsService;
  String _waterHeight = "0"; // current water value
  String _wasteWeight = "0"; // current waste value

  String _waterHeightMax = "100"; // user-defined max
  String _wasteWeightMax = "1000"; // user-defined max

  double _waterMonitorPercent = 0.0;
  double _wasteMonitorPercent = 0.0;

  int? _lastWaterBucket;
  int? _lastWasteBucket;

  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // observe lifecycle
    _initPreferences();
    _wsService = WebSocketService();
    _wsService.connect();
    _wsService.messages.listen(_handleIncomingMessage);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _wsService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // App is killed / removed from recent apps
      setState(() {
        _isStarted = false;
      });
      _saveSwitchState(false); // reset in SharedPreferences
      if (_wsService.isConnected) _wsService.sendMessage("off");
    }
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isStarted = _prefs.getBool('switchState') ?? false;
      _waterHeightMax = _prefs.getString('waterHeightMax') ?? "100";
      _wasteWeightMax = _prefs.getString('wasteWeightMax') ?? "1000";
      _waterHeight = _prefs.getString('currentWaterHeight') ?? "0";
      _wasteWeight = _prefs.getString('currentWasteWeight') ?? "0";

      final maxInt = int.tryParse(_waterHeightMax) ?? 100;
      final waterInt = int.tryParse(_waterHeight) ?? 0;
      _waterMonitorPercent = (waterInt / maxInt).clamp(0, 1);

      final maxKg = double.tryParse(_wasteWeightMax) ?? 10.0;
      final wasteKg = double.tryParse(_wasteWeight) ?? 0.0;
      _wasteMonitorPercent = (wasteKg / maxKg).clamp(0, 1);
    });

    if (_wsService.isConnected) {
      _wsService.sendMessage(_isStarted ? "on" : "off");
    }
  }

  void _handleIncomingMessage(String msg) async {
    if (!_isStarted) return;

    final parts = msg.split(';');
    final todayStr = DateTime.now().toIso8601String().split('T')[0];

    List<String> waterHistory = _prefs.getStringList('waterHistory_$todayStr') ?? [];
    List<String> wasteHistory = _prefs.getStringList('wasteHistory_$todayStr') ?? [];
    int emergencyCount = _prefs.getInt('emergency_$todayStr') ?? 0;
    int containerCount = _prefs.getInt('container_$todayStr') ?? 0;

    bool waterTriggered = false;
    bool wasteTriggered = false;
    bool containerTriggered = false;

    for (var part in parts) {
      // ----------------- WATER -----------------
      if (part.contains("water:")) {
        _waterHeight = part.split(":")[1].trim();
        final waterInt = int.tryParse(_waterHeight) ?? 0;
        final maxInt = int.tryParse(_waterHeightMax) ?? 100;
        _waterMonitorPercent = (waterInt / maxInt).clamp(0, 1);

        int percent = (_waterMonitorPercent * 100).round();

        int? rangeBucket;
        if (percent >= 25 && percent <= 49) rangeBucket = 25;
        else if (percent >= 50 && percent <= 74) rangeBucket = 50;
        else if (percent >= 75 && percent <= 99) rangeBucket = 75;
        else if (percent >= 100) rangeBucket = 100;

        int? lastBucket = _prefs.getInt('lastWaterBucket_$todayStr');

        if (rangeBucket != null && rangeBucket != lastBucket) {
          NotificationService.showWaterLevelNotification(rangeBucket);
          await _prefs.setInt('lastWaterBucket_$todayStr', rangeBucket);
          waterTriggered = true;
        }

        waterHistory.add(_waterHeight);
        await _prefs.setStringList('waterHistory_$todayStr', waterHistory);
        await _prefs.setString('currentWaterHeight', _waterHeight);
      }

      // ----------------- WASTE -----------------
      else if (part.contains("waste:")) {
        _wasteWeight = part.split(":")[1].trim();
        final kg = double.tryParse(_wasteWeight) ?? 0.0;
        final maxKg = double.tryParse(_wasteWeightMax) ?? 10.0;
        _wasteMonitorPercent = (kg / maxKg).clamp(0, 1);

        // Scale to 1000 instead of 100
        int percent = (_wasteMonitorPercent * 1000).round();

        int? rangeBucket;
        if (percent >= 250 && percent <= 499) rangeBucket = 250;
        else if (percent >= 500 && percent <= 749) rangeBucket = 500;
        else if (percent >= 750 && percent <= 999) rangeBucket = 750;
        else if (percent >= 1000) rangeBucket = 1000;

        int? lastBucket = _prefs.getInt('lastWasteBucket_$todayStr');

        if (rangeBucket != null && rangeBucket != lastBucket) {
          NotificationService.showWasteLevelNotification(rangeBucket);
          await _prefs.setInt('lastWasteBucket_$todayStr', rangeBucket);
          wasteTriggered = true;
        }

        wasteHistory.add(_wasteWeight);
        await _prefs.setStringList('wasteHistory_$todayStr', wasteHistory);
        await _prefs.setString('currentWasteWeight', _wasteWeight);
      }

      // ----------------- CONTAINER SIGNAL (C) -----------------
      else if (part == "C") {
        containerTriggered = true;
      }

      // ----------------- EMERGENCY SIGNAL (E) -----------------
      else if (part == "E") {
        bool lastEmergency = _prefs.getBool('lastEmergencyTriggered_$todayStr') ?? false;

        if (!lastEmergency) {
          emergencyCount++;
          await _prefs.setBool('lastEmergencyTriggered_$todayStr', true);
          NotificationService.showEmergencyNotification();
        }
      } else {
        await _prefs.setBool('lastEmergencyTriggered_$todayStr', false);
      }
    }

    if (waterTriggered || wasteTriggered) {
      emergencyCount++;
    }

    if (containerTriggered) {
      containerCount++;
    }

    await _prefs.setInt('emergency_$todayStr', emergencyCount);
    await _prefs.setInt('container_$todayStr', containerCount);

    setState(() {});
  }

  Future<void> _resetValues() async {
    setState(() {
      _waterHeight = "0";
      _wasteWeight = "0";
      _waterMonitorPercent = 0.0;
      _wasteMonitorPercent = 0.0;
      _lastWaterBucket = null;
      _lastWasteBucket = null;
    });

    await _prefs.remove('currentWaterHeight');
    await _prefs.remove('currentWasteWeight');
  }

  Future<void> _saveSwitchState(bool value) async {
    await _prefs.setBool('switchState', value);
  }

  Future<void> _savePreference(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<void> _showEditDialog({
    required String title,
    required String currentValue,
    required Function(String) onSave,
  }) async {
    final controller = TextEditingController(text: currentValue);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                  ElevatedButton(
                    onPressed: () {
                      final val = controller.text.trim();
                      if (val.isNotEmpty) onSave(val);
                      Navigator.pop(context);
                    },
                    child: const Text("Save"),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: ''),
      bottomNavigationBar: const CustomBottomNavBar(),
      backgroundColor: const Color(0xFFB2DAAC),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildStartSwitch(),
            const SizedBox(height: 80),
            _buildIndicators(),
            const SizedBox(height: 70),
            _buildMaxValues(),
          ],
        ),
      ),
    );
  }

  Widget _buildStartSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SwitchTheme(
          data: SwitchThemeData(
            thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
              return states.contains(MaterialState.selected)
                  ? Colors.red
                  : const Color(0xFF006400);
            }),
            trackColor: MaterialStateProperty.all(const Color(0xFFCCFFCC)),
          ),
          child: Transform.scale(
            scale: 1.4,
            child: Switch(
              value: _isStarted,
              onChanged: (value) {
                setState(() {
                  _isStarted = value;
                  if (!_isStarted) _resetValues();
                });
                _saveSwitchState(value);
                if (_wsService.isConnected) {
                  _wsService.sendMessage(value ? "on" : "off");
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 100),
        Text(
          _isStarted ? "STOP" : "START",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: _isStarted ? Colors.red : const Color(0xFF006400),
          ),
        ),
      ],
    );
  }

  Widget _buildIndicators() {
    return Opacity(
      opacity: _isStarted ? 1.0 : 0.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              _buildCircleIndicator(Icons.delete, false),
              const SizedBox(height: 20),
              _buildCircleIndicator(Icons.water_drop, true),
            ],
          ),
          Row(
            children: [
              _buildVerticalBar(Icons.delete, _wasteMonitorPercent, false),
              const SizedBox(width: 20),
              _buildVerticalBar(Icons.water_drop, _waterMonitorPercent, true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaxValues() {
    return Opacity(
      opacity: _isStarted ? 1.0 : 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _showEditDialog(
              title: "Set Max Waste Weight (kg)",
              currentValue: _wasteWeightMax,
              onSave: (val) {
                setState(() => _wasteWeightMax = val);
                _savePreference("wasteWeightMax", val);
              },
            ),
            child: Text(
              "Waste Max Weight (g): $_wasteWeight / $_wasteWeightMax",
              style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  decoration: TextDecoration.underline),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _showEditDialog(
              title: "Set Max Water Height (%)",
              currentValue: _waterHeightMax,
              onSave: (val) {
                setState(() => _waterHeightMax = val);
                _savePreference("waterHeightMax", val);
              },
            ),
            child: Text(
              "Water Height (%): $_waterHeight / $_waterHeightMax",
              style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIndicator(IconData icon, bool isWater) {
    final double value = isWater ? _waterMonitorPercent : _wasteMonitorPercent;
    final int percentage = isWater
        ? (value * 100).round()
        : (value * 1000).round();

    Color progressColor;
    if (isWater) {
      if (percentage <= 25) progressColor = Colors.green;
      else if (percentage <= 50) progressColor = Colors.yellow;
      else if (percentage <= 75) progressColor = Colors.orange;
      else progressColor = Colors.red;
    } else {
      if (percentage <= 250) progressColor = Colors.green;
      else if (percentage <= 500) progressColor = Colors.yellow;
      else if (percentage <= 750) progressColor = Colors.orange;
      else progressColor = Colors.red;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 90,
          width: 90,
          child: CircularProgressIndicator(
            value: value,
            backgroundColor: const Color(0xFF06703C),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            strokeWidth: 8,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$percentage",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Icon(icon, size: 25, color: const Color(0xFF06703C)),
          ],
        ),
      ],
    );
  }

  Widget _buildVerticalBar(IconData icon, double fillPercent, bool isWater) {
    final int percentage = isWater
        ? (fillPercent * 100).round()
        : (fillPercent * 1000).round();

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: 330,
          width: 100,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF06703C), width: 2.5),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        Container(
          height: 330 * fillPercent,
          width: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF06703C),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
          ),
        ),
        Positioned(
          top: 8,
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF06703C)),
              Text(
                "$percentage",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF06703C),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
