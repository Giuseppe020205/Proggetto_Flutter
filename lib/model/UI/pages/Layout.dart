import 'package:flutter/material.dart';
import "package:easy_localization/easy_localization.dart";
import 'package:diet_app/model/UI/pages/ProductSelectionScreen.dart';
import 'package:diet_app/model/UI/pages/RegistrationScreen.dart';
import 'package:diet_app/model/UI/pages/ControllaCalorie.dart';


import 'package:flutter/material.dart';
import "package:easy_localization/easy_localization.dart";
class Layout extends StatelessWidget {
  final ThemeMode tema;
  final Function(bool) cambiatema;

  const Layout({super.key, required this.tema, required this.cambiatema});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: TabBarView(
          children: [
            // Qui passi i parametri correttamente per gestire il tema in ogni pagina
            ControllaCalorie(tema: tema, cambiatema: cambiatema),
            RegistrationScreen(tema: tema, cambiatema: cambiatema),
          ],
        ),
      ),
    );
  }
}