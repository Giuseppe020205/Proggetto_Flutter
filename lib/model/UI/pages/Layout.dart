import 'package:flutter/material.dart';
import 'package:diet_app/model/UI/pages/RegistrationScreen.dart';
import 'package:diet_app/model/UI/pages/ControllaCalorie.dart';


// WIDGET DI LAYOUT PRINCIPALE
class Layout extends StatelessWidget {
  //propietà costruttore
  final ThemeMode tema;
  final Function(bool) cambiatema;

  const Layout({super.key, required this.tema, required this.cambiatema});
  // costruzione della struttura della pagina
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: TabBarView(
          children: [
            ControllaCalorie(tema: tema, cambiatema: cambiatema),
            RegistrationScreen(tema: tema, cambiatema: cambiatema),
          ],
        ),
      ),
    );
  }
}