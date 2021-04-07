import 'package:flutter/material.dart';
import 'package:switchsnek/screens/snek.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool onScreenControls = true;

  // ignore: avoid_positional_boolean_parameters
  void toggleOnScreenControls(bool val) {
    setState(() {
      onScreenControls = val;
    });
  }

  void toSnek() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SnekScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'switchsnek',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              toSnek();
            },
            child: const Text('START'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Switch(
                  onChanged: toggleOnScreenControls,
                  value: onScreenControls,
                ),
                const Text('Show on-screen controls'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
