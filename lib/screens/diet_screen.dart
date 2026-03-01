import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class DietScreen extends StatefulWidget {
  @override
  _DietScreenState createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  final _controller = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<AppState>(context, listen: false).loadDietFor(_selectedDate);
    });
  }

  void _addEntry() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Provider.of<AppState>(context, listen: false).addDietEntry(_selectedDate, text);
    _controller.clear();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      await Provider.of<AppState>(context, listen: false).loadDietFor(_selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final todayList = appState.dietFor(_selectedDate);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C2C2C), Color(0xFF121212)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
            Row(
              children: [
                TextButton(onPressed: _pickDate, child: Text('Date')), 
                Text('${_selectedDate.toLocal().toIso8601String().split('T')[0]}'),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(labelText: 'Add diet item'),
                  ),
                ),
                IconButton(onPressed: _addEntry, icon: Icon(Icons.add)),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: todayList.length,
                itemBuilder: (ctx, idx) => Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(todayList[idx]),
                  ),
                ),
              ),
            ),
          ],          ),        ),
      ),
    );
  }
}
