import 'package:diet_app/model/UI/pages/ControllaCalorie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'model/Model.dart';
import 'package:diet_app/model/UI/pages/RegistrationScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diet_app/model/managers/DatabaseAlimenti.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  final prefs=await SharedPreferences.getInstance();
  bool isLoggedIn=prefs.getBool('is_logged_in') ?? false;
  String ? emailSalvata = prefs.getString('user_email');

  if (isLoggedIn && emailSalvata != null) {
    try {
      final utente = await DatabaseAlimenti.getUtenteconEmail(emailSalvata);
      if (utente != null) {

        Model.sharedInstance.updateUserData(utente);
      } else {

        isLoggedIn = false;
      }
    } catch (e) {
      isLoggedIn = false;
    }
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('it'), Locale('en')],
      path: 'assets/localizable',
      fallbackLocale: const Locale('it'),
      child: ChangeNotifierProvider(
        create: (_) => Model.sharedInstance,
        child:  MyApp(inizialmenteloggato: isLoggedIn),
      ),
    ),
  );
}

// 1. CAMBIATO IN STATEFULWIDGET per gestire il tema
class MyApp extends StatefulWidget {
  const MyApp({super.key,required this.inizialmenteloggato});
  final bool inizialmenteloggato;
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Variabile per gestire il tema (Lezione 4)
  ThemeMode _themeMode = ThemeMode.light;

  // Funzione che verrà chiamata dal Layout per cambiare il tema
  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      // Configurazione Temi (Material 3)
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
      ),
      themeMode: _themeMode,

      // 2. PASSA I PARAMETRI AL LAYOUT (Il rosso sparirà qui)
      home: widget.inizialmenteloggato
        ? ControllaCalorie(tema: _themeMode,cambiatema : _toggleTheme)
          :RegistrationScreen(tema: _themeMode,cambiatema: _toggleTheme
      ),
    );
  }
}