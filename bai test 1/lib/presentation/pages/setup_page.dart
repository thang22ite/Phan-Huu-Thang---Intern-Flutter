import 'package:flutter/material.dart';
import '../../core/app_config.dart';
import 'home_page.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final _formKey = GlobalKey<FormState>();

  int gridWidth = 100;
  int gridHeight = 100;
  int startX = 2;
  int startY = 3;
  double maxWeight = 50.0;
  double maxFuel = 30.0;
  int numOrders = 3;
  int numStations = 2;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final config = AppConfig(
        gridWidth: gridWidth,
        gridHeight: gridHeight,
        startX: startX,
        startY: startY,
        maxWeight: maxWeight,
        maxFuel: maxFuel,
        numOrders: numOrders,
        numStations: numStations,
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage(config: config)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Scenario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildNumberField('Grid Width (n)', gridWidth.toString(), (val) => gridWidth = int.parse(val!)),
              _buildNumberField('Grid Height (m)', gridHeight.toString(), (val) => gridHeight = int.parse(val!)),
              _buildNumberField('Start X', startX.toString(), (val) => startX = int.parse(val!)),
              _buildNumberField('Start Y', startY.toString(), (val) => startY = int.parse(val!)),
              _buildNumberField('Max Weight (W)', maxWeight.toString(), (val) => maxWeight = double.parse(val!)),
              _buildNumberField('Max Fuel (F)', maxFuel.toString(), (val) => maxFuel = double.parse(val!)),
              _buildNumberField('Number of Orders', numOrders.toString(), (val) => numOrders = int.parse(val!)),
              _buildNumberField('Number of Gas Stations', numStations.toString(), (val) => numStations = int.parse(val!)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Start Simulation'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField(String label, String initialVal, void Function(String?) onSave) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        initialValue: initialVal,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        keyboardType: TextInputType.number,
        validator: (val) {
          if (val == null || val.isEmpty) return 'Please enter a value';
          if (double.tryParse(val) == null) return 'Must be a number';
          return null;
        },
        onSaved: onSave,
      ),
    );
  }
}
