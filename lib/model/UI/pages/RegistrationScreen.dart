
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
  //CONTROLLER PER I CAMPI DI TESTO
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

  // FUNZIONE PER VALIDARE E SALVARE
  void salvaECalcola(BuildContext context) async {
    final model = Provider.of<Model>(context, listen: false);

    // VALIDAZIONE BASE
    final passwordPattern=RegExp(r'^[A-Z](?=.*[0-9])(?=.*[@])(?=.*\.(com|it|net)$)');
    if (_emailController.text.isEmpty || _passwordController.text.length < 6 || passwordPattern.hasMatch(_passwordController.text)) {
      _mostraErrore("err_generico".tr());
      return;
    }

    try {
      // SALVATAGGIO SU DATABASE
      await DatabaseAlimenti.registraNuovoUtente(
        email: _emailController.text,
        nome: _nomeController.text,
        password: _passwordController.text,
        genere: genere.toString(),
        eta: int.parse(_etaController.text),
        peso: double.parse(_pesoController.text),
        altezza: double.parse(_altezzaController.text),
        livelloattivita: laf,
        obbiettivo: obbiettivoSelezionato.toString()
      );

      // CREAZIONE OGGETTO UTENTE
      final nuovoUtente = UserData(
        email: _emailController.text,
        nome: _nomeController.text,
        genere: genere,
        eta: int.parse(_etaController.text),
        peso: double.parse(_pesoController.text),
        altezza: double.parse(_altezzaController.text),
        livelloAttivita: laf,
        obbiettivo: obbiettivoSelezionato,
      );


      model.updateUserData(nuovoUtente);

      // SALVA SESSIONE LOCALE
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);

      // 5. NAVIGAZIONE
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ControllaCalorie(
              tema: widget.tema,
              cambiatema: widget.cambiatema
          ),
        ),
      );

    } catch (e) {
      log("Errore: $e");
      _mostraErrore("Errore durante il salvataggio");
    }
  }
  // FUNZIONE PER GESTIRE IL LOGIN
  void effettuaLogin(BuildContext context) async {
    final model = Provider.of<Model>(context, listen: false);
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _mostraErrore("inserire_email_password".tr());
      return;
    }

    try {
      //VERIFICA DATABASE
      final UserData? utenteEsistente = await DatabaseAlimenti.loginUtente(email, password);

      if (utenteEsistente != null) {

        model.updateUserData(utenteEsistente);


        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_email', _emailController.text.trim());
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
      _mostraErrore("Errore di connessione al database");
    }
  }
  void _mostraErrore(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color YellowT = Color(0xFFFFEB3B);
    bool scuro = widget.tema == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('registrazione').tr(),

      ),
      endDrawer: _buildDrawer(context, scuro),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(controller: _emailController,keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: 'email'.tr(),prefixIcon: const Icon(Icons.email_outlined),filled: true,fillColor: Colors.white,border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0),borderSide: BorderSide(color: Colors.yellow)),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0),borderSide: BorderSide(color: Colors.deepPurpleAccent))),),
            const SizedBox(height: 10,),
            TextFormField(controller: _passwordController, decoration: InputDecoration(labelText: 'password'.tr(),prefixIcon: const Icon(Icons.password_outlined),filled: true,fillColor: Colors.white,border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0),borderSide: BorderSide(color: Colors.yellow)),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0),borderSide: BorderSide(color: Colors.deepPurpleAccent))),),
            const SizedBox(height: 10,),
            TextFormField(controller: _nomeController, decoration: InputDecoration(labelText: 'nome'.tr(),filled: true,fillColor: Colors.white,border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0),borderSide: BorderSide(color: Colors.yellow)),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0),borderSide: BorderSide(color: Colors.deepPurpleAccent))),),


            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextFormField(controller: _emailController,keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'email'.tr(),filled: true,fillColor: Colors.white,border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0),borderSide: BorderSide(color: Colors.yellow)),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0),borderSide: BorderSide(color: Colors.deepPurpleAccent))),),),
                  const SizedBox(width: 8),
                Expanded(child: TextFormField(controller: _emailController,keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'email'.tr(),filled: true,fillColor: Colors.white,border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0),borderSide: BorderSide(color: Colors.yellow)),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0),borderSide: BorderSide(color: Colors.deepPurpleAccent))),),),
                const SizedBox(width: 8),
                Expanded(child: TextFormField(controller: _emailController,keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'email'.tr(),filled: true,fillColor: Colors.white,border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0),borderSide: BorderSide(color: Colors.yellow)),focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0),borderSide: BorderSide(color: Colors.deepPurpleAccent))),),),
              ],
            ),

            const SizedBox(height: 20),
            Text("genere".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGenereButton("M", Genere.MASCHIO, YellowT),
                const SizedBox(width: 10),
                _buildGenereButton("F", Genere.FEMMINA, YellowT),
              ],
            ),

            const SizedBox(height: 20),
            _buildDropdowns(),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => salvaECalcola(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                child: const Text('registrazione').tr(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                  onPressed: () => effettuaLogin(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple,foregroundColor: Colors.white),
                  child: const Text("accedi"),
              ),

            )

          ],
        ),
      ),
    );
  }

  // Widget helper per i bottoni M/F
  Widget _buildGenereButton(String label, Genere g, Color activeColor) {
    return ElevatedButton(
      onPressed: () => setState(() => genere = g),
      style: ElevatedButton.styleFrom(
        backgroundColor: genere == g ? activeColor : Colors.grey[300],
        foregroundColor: Colors.black,
      ),
      child: Text(label),
    );
  }

  // Costruisce i Dropdown per Obbiettivo e Attività
  Widget _buildDropdowns() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: selectionOptionObbiettivo,
          decoration: InputDecoration(labelText: 'obbiettivo'.tr(), border: const OutlineInputBorder()),
          items: opzioniObbiettivo.map((e) => DropdownMenuItem(value: e, child: Text(e).tr())).toList(),
          onChanged: (val) => setState(() {
            selectionOptionObbiettivo = val!;
            obbiettivoSelezionato = (val == 'guadagnare_peso'.tr()) ? TipoObbiettivo.GUADAGNARE_PESO : (val == 'perdere_peso'.tr() ? TipoObbiettivo.PERDERE_PESO : TipoObbiettivo.MANTENERE_PESO);
          }),
        ),
        const SizedBox(height: 15),
        DropdownButtonFormField<String>(
          value: selectionOptionAttivita,
          decoration: InputDecoration(labelText: 'attivita'.tr(), border: const OutlineInputBorder()),
          items: opzioniAttivita.map((e) => DropdownMenuItem(value: e, child: Text(e).tr())).toList(),
          onChanged: (val) => setState(() {
            selectionOptionAttivita = val!;
            laf = ((val== "sedentario".tr()) ? 1.2 : (val== "moderato".tr()) ? 1.55 : 1.725);
          }),
        ),
      ],
    );
  }

  // Drawer per impostazioni
  Widget _buildDrawer(BuildContext context, bool scuro) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.deepPurple),
            child: Center(child: const Text("Impostazioni", style: TextStyle(color: Colors.white, fontSize: 20)).tr()),
          ),
          ListTile(
            leading: const Icon(Icons.language,color: Colors.deepPurple,),
            title: Text(context.locale.languageCode == 'it' ? "Italiano" : "English",),
            onTap: () {
              context.setLocale(context.locale.languageCode == 'it' ? const Locale('en') : const Locale('it'));
              Navigator.pop(context);
            },
          ),
          SwitchListTile(
            title: const Text("tema_scuro").tr(),
            secondary: Icon(widget.tema == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
              color: Colors.deepPurple,),
            value: scuro,
            onChanged: (val) => widget.cambiatema(val),
          ),
        ],
      ),
    );
  }
}