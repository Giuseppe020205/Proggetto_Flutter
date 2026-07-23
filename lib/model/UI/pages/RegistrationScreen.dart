import 'dart:developer';
import 'package:diet_app/model/UI/pages/ControllaCalorie.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:diet_app/model/Model.dart';
import 'package:diet_app/model/managers/DatabaseAlimenti.dart';
import 'package:diet_app/model/objects/Enums.dart';
import 'package:diet_app/model/objects/UserData.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatefulWidget {
  final ThemeMode tema;
  final Function(bool) cambiatema;

  const RegistrationScreen({super.key, required this.tema, required this.cambiatema});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // CONTROLLER UNICI PER OGNI CAMPO
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _etaController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _altezzaController = TextEditingController();

  Genere genere = Genere.MASCHIO;
  TipoObbiettivo obbiettivoSelezionato = TipoObbiettivo.MANTENERE_PESO;
  double laf = 1.2;

  String selectionOptionObbiettivo = 'mantenere_peso';
  String selectionOptionAttivita = 'sedentario';

  final List<String> opzioniObbiettivo = ['guadagnare_peso', 'perdere_peso', 'mantenere_peso'];
  final List<String> opzioniAttivita = ['sedentario', 'moderato', 'attivo'];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nomeController.dispose();
    _etaController.dispose();
    _pesoController.dispose();
    _altezzaController.dispose();
    super.dispose();
  }

  void salvaECalcola(BuildContext context) async {
    final model = Provider.of<Model>(context, listen: false);

    final passwordPattern = RegExp(r'^[A-Z](?=.*[0-9])(?=.*[@])(?=.*\.(com|it|net)$)');
    if (_emailController.text.isEmpty || _passwordController.text.length < 6 || passwordPattern.hasMatch(_passwordController.text)) {
      _mostraErrore("password_non_valida".tr());
      return;
    }

    try {
      await DatabaseAlimenti.registraNuovoUtente(
        email: _emailController.text,
        nome: _nomeController.text,
        password: _passwordController.text,
        genere: genere.toString(),
        eta: int.tryParse(_etaController.text) ?? 0,
        peso: double.tryParse(_pesoController.text) ?? 0.0,
        altezza: double.tryParse(_altezzaController.text) ?? 0.0,
        livelloattivita: laf,
        obbiettivo: obbiettivoSelezionato.toString(),
      );

      final nuovoUtente = UserData(
        email: _emailController.text,
        nome: _nomeController.text,
        genere: genere,
        eta: int.tryParse(_etaController.text) ?? 0,
        peso: double.tryParse(_pesoController.text) ?? 0.0,
        altezza: double.tryParse(_altezzaController.text) ?? 0.0,
        livelloAttivita: laf,
        obbiettivo: obbiettivoSelezionato,
      );

      model.updateUserData(nuovoUtente);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in'.tr(), true);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ControllaCalorie(
            tema: widget.tema,
            cambiatema: widget.cambiatema,
          ),
        ),
      );
    } catch (e) {
      log("Errore: $e");
      _mostraErrore("Errore durante il salvataggio".tr());
    }
  }

  void effettuaLogin(BuildContext context) async {
    final model = Provider.of<Model>(context, listen: false);
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _mostraErrore("inserire_email_password".tr());
      return;
    }

    try {
      final UserData? utenteEsistente = await DatabaseAlimenti.loginUtente(email, password);

      if (utenteEsistente != null) {
        model.updateUserData(utenteEsistente);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in'.tr(), true);
        await prefs.setString('user_email'.tr(), _emailController.text.trim());
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ControllaCalorie(
              tema: widget.tema,
              cambiatema: widget.cambiatema,
            ),
          ),
        );
      } else {
        _mostraErrore("credenziali_errate".tr());
      }
    } catch (e) {
      log("Errore durante il login: $e");
      _mostraErrore("Errore di connessione al database".tr());
    }
  }

  void _mostraErrore(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool scuro = widget.tema == ThemeMode.dark;

    final Color colorePrincipale = scuro ? Colors.amber : Colors.deepPurple;
    final Color coloreSfondoScaffold = scuro ? const Color(0xFF121212) : Colors.grey[100]!;
    final Color coloreInputFill = scuro ? const Color(0xFF1E1E1E) : Colors.white;
    final Color coloreTesto = scuro ? Colors.white : Colors.black;
    final Color coloreBordo = scuro ? Colors.amber : Colors.yellow;

    return Scaffold(
      backgroundColor: coloreSfondoScaffold,
      appBar: AppBar(
        title: const Text('registrazione').tr(),
        backgroundColor: colorePrincipale,
        foregroundColor: scuro ? Colors.black : Colors.white,
      ),
      endDrawer: _buildDrawer(context, scuro, colorePrincipale, coloreTesto),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // EMAIL
            TextFormField(
              key: const ValueKey('field_email'),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: coloreTesto),
              decoration: InputDecoration(
                labelText: 'email'.tr(),
                labelStyle: TextStyle(color: scuro ? Colors.grey[400] : Colors.grey[700]),
                prefixIcon: Icon(Icons.email_outlined, color: colorePrincipale),
                filled: true,
                fillColor: coloreInputFill,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: coloreBordo)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: colorePrincipale, width: 2)),
              ),
            ),
            const SizedBox(height: 10),

            // PASSWORD
            TextFormField(
              key: const ValueKey('field_password'),
              controller: _passwordController,
              obscureText: true,
              style: TextStyle(color: coloreTesto),
              decoration: InputDecoration(
                labelText: 'password'.tr(),
                labelStyle: TextStyle(color: scuro ? Colors.grey[400] : Colors.grey[700]),
                prefixIcon: Icon(Icons.password_outlined, color: colorePrincipale),
                filled: true,
                fillColor: coloreInputFill,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: coloreBordo)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: colorePrincipale, width: 2)),
              ),
            ),
            const SizedBox(height: 10),

            // NOME
            TextFormField(
              key: const ValueKey('field_nome'),
              controller: _nomeController,
              style: TextStyle(color: coloreTesto),
              decoration: InputDecoration(
                labelText: 'nome'.tr(),
                labelStyle: TextStyle(color: scuro ? Colors.grey[400] : Colors.grey[700]),
                filled: true,
                fillColor: coloreInputFill,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: coloreBordo)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: colorePrincipale, width: 2)),
              ),
            ),

            const SizedBox(height: 10),

            // ETA', PESO, ALTEZZA
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: const ValueKey('field_eta'),
                    controller: _etaController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: coloreTesto),
                    decoration: InputDecoration(
                      labelText: 'eta'.tr(),
                      labelStyle: TextStyle(color: scuro ? Colors.grey[400] : Colors.grey[700]),
                      filled: true,
                      fillColor: coloreInputFill,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: coloreBordo)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: colorePrincipale, width: 2)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    key: const ValueKey('field_peso'),
                    controller: _pesoController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: coloreTesto),
                    decoration: InputDecoration(
                      labelText: 'peso'.tr(),
                      labelStyle: TextStyle(color: scuro ? Colors.grey[400] : Colors.grey[700]),
                      filled: true,
                      fillColor: coloreInputFill,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: coloreBordo)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: colorePrincipale, width: 2)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    key: const ValueKey('field_altezza'),
                    controller: _altezzaController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: coloreTesto),
                    decoration: InputDecoration(
                      labelText: 'altezza'.tr(),
                      labelStyle: TextStyle(color: scuro ? Colors.grey[400] : Colors.grey[700]),
                      filled: true,
                      fillColor: coloreInputFill,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: coloreBordo)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: colorePrincipale, width: 2)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Text("genere".tr(), style: TextStyle(fontWeight: FontWeight.bold, color: coloreTesto)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGenereButton("M", Genere.MASCHIO, colorePrincipale, scuro),
                const SizedBox(width: 10),
                _buildGenereButton("F", Genere.FEMMINA, colorePrincipale, scuro),
              ],
            ),

            const SizedBox(height: 20),
            _buildDropdowns(colorePrincipale, coloreInputFill, coloreTesto, scuro),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => salvaECalcola(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorePrincipale,
                  foregroundColor: scuro ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('registrazione', style: TextStyle(fontWeight: FontWeight.bold)).tr(),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => effettuaLogin(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorePrincipale,
                  foregroundColor: scuro ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("accedi", style: TextStyle(fontWeight: FontWeight.bold)).tr(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGenereButton(String label, Genere g, Color activeColor, bool scuro) {
    bool isSelected = genere == g;
    return ElevatedButton(
      onPressed: () => setState(() => genere = g),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? activeColor : (scuro ? Colors.grey[800] : Colors.grey[300]),
        foregroundColor: isSelected ? (scuro ? Colors.black : Colors.white) : (scuro ? Colors.white : Colors.black),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDropdowns(Color colorePrincipale, Color fillColor, Color textColor, bool scuro) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: selectionOptionObbiettivo,
          dropdownColor: fillColor,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            labelText: 'obbiettivo'.tr(),
            labelStyle: TextStyle(color: scuro ? Colors.grey[400] : Colors.grey[700]),
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: colorePrincipale, width: 2)),
          ),
          items: opzioniObbiettivo.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: textColor)).tr())).toList(),
          onChanged: (val) => setState(() {
            selectionOptionObbiettivo = val!;
            // CONFRONTO CORRETTO SU CHIAVI FISSE (NON TRADOTTE)
            if (val == 'guadagnare_peso') {
              obbiettivoSelezionato = TipoObbiettivo.GUADAGNARE_PESO;
            } else if (val == 'perdere_peso') {
              obbiettivoSelezionato = TipoObbiettivo.PERDERE_PESO;
            } else {
              obbiettivoSelezionato = TipoObbiettivo.MANTENERE_PESO;
            }
          }),
        ),
        const SizedBox(height: 15),
        DropdownButtonFormField<String>(
          value: selectionOptionAttivita,
          dropdownColor: fillColor,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            labelText: 'attivita'.tr(),
            labelStyle: TextStyle(color: scuro ? Colors.grey[400] : Colors.grey[700]),
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide(color: colorePrincipale, width: 2)),
          ),
          items: opzioniAttivita.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: textColor)).tr())).toList(),
          onChanged: (val) => setState(() {
            selectionOptionAttivita = val!;
            // CONFRONTO CORRETTO SU CHIAVI FISSE (NON TRADOTTE)
            if (val == 'sedentario') {
              laf = 1.2;
            } else if (val == 'moderato') {
              laf = 1.55;
            } else {
              laf = 1.725;
            }
          }),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, bool scuro, Color colorePrincipale, Color coloreTesto) {
    return Drawer(
      backgroundColor: scuro ? const Color(0xFF1E1E1E) : Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colorePrincipale),
            child: Center(
              child: Text(
                "Impostazioni".tr(),
                style: TextStyle(
                  color: scuro ? Colors.black : Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ).tr(),
            ),
          ),
          ListTile(
            leading: Icon(Icons.language, color: colorePrincipale),
            title: Text(
              context.locale.languageCode == 'it' ? "Italiano" : "English",
              style: TextStyle(color: coloreTesto),
            ),
            onTap: () {
              context.setLocale(context.locale.languageCode == 'it' ? const Locale('en') : const Locale('it'));
              Navigator.pop(context);
            },
          ),
          SwitchListTile(
            title: Text("tema_scuro", style: TextStyle(color: coloreTesto)).tr(),
            secondary: Icon(
              widget.tema == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
              color: colorePrincipale,
            ),
            value: scuro,
            onChanged: (val) => widget.cambiatema(val),
          ),
        ],
      ),
    );
  }
}