import 'package:flutter/material.dart';
import 'equipos_screen.dart';
import 'historial_screen.dart';
import 'ambientes_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _paginas = [
    EquiposScreen(), // Sin 'const' para evitar el conflicto de constructor
    const HistorialScreen(),
    const AmbientesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _paginas,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0D3B66),
          unselectedItemColor: Colors.grey.shade500,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 26,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.computer_rounded),
              activeIcon: Icon(Icons.computer_rounded, size: 28),
              label: 'Equipos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              activeIcon: Icon(Icons.history_rounded, size: 28),
              label: 'Historial',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.meeting_room_rounded),
              activeIcon: Icon(Icons.meeting_room_rounded, size: 28),
              label: 'Ambientes',
            ),
          ],
        ),
      ),
    );
  }
}