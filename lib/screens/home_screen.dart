import 'package:flutter/material.dart';
import 'medicine_screen.dart';
import 'diet_screen.dart';
import 'calendar_screen.dart';
import 'missed_medicines_screen.dart';
import 'add_medicine_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    MedicineScreen(),
    DietScreen(),
    CalendarScreen(),
    MissedMedicinesScreen(),
    AddMedicineScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diabetes Tracker'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C2C2C), Color(0xFF121212)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Ensure more than 3 items display nicely
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.tealAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Diet'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.warning_amber_rounded), label: 'Missed'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Add'),
        ],
      ),
    );
  }
}
