// lib/UI/pages/ControllaCalorie.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:diet_app/model/Model.dart';
import 'package:diet_app/model/objects/Prodotto.dart';
import 'package:diet_app/model/UI/pages/ProductSelectionScreen.dart';
import 'package:diet_app/model/UI/pages/RegistrationScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diet_app/model/Model.dart';

class ControllaCalorie extends StatefulWidget {
  final ThemeMode tema;
  final Function(bool) cambiatema;

  const ControllaCalorie({super.key, required this.tema, required this.cambiatema});

  @override
  State<ControllaCalorie> createState() => _ControllaCalorieState();
}

class _ControllaCalorieState extends State<ControllaCalorie> {

  void apriSelezioneProdotti(BuildContext context) async {
    final risultato = await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (context, _, __) => const SelezioneProdotti(),
      ),
    );

    if (risultato != null && risultato is Prodotto) {
      Model.sharedInstance.aggiungiProdotto(risultato);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${risultato.nome} ${"aggiunto".tr()}"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  void aggiungiAlimento(BuildContext context){
    final model=Provider.of<Model>(context,listen: false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context)  => SelezioneProdotti(),
      ),
    );
  }

  void effettuaLogout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("logout_titolo".tr()), // Esempio: "Sei sicuro?"
          content: Text("logout_messaggio".tr()), // Esempio: "Vuoi davvero uscire?"
          actions: [
            // TASTO PER TORNARE INDIETRO
            TextButton(
              onPressed: () => Navigator.pop(context), // Chiude solo la casella
              child: Text("indietro".tr(), style: const TextStyle(color: Colors.grey)),
            ),
            // TASTO PER USCIRE DEFINITIVAMENTE
            TextButton(
              onPressed: () async {
                // 1. Puliamo la sessione
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                // 2. Navigazione di sicurezza (chiudiamo tutto)
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => RegistrationScreen(
                      tema: widget.tema,
                      cambiatema: widget.cambiatema,
                    ),
                  ),
                      (route) => false,
                );
              },
              child: Text("esci".tr(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
  @override
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<Model>(context);

    // Calcolo dei dati per l'indicatore tramite la funzione nel Model
    final int obiettivo = model.calcolaRapportoCalorico(model.userData);
    final int consumate = model.statistiche.calorieConsumate;
    final int rimanenti = obiettivo - consumate;

    return Scaffold(
      backgroundColor: Colors.grey[200],

      // --- MENU LATERALE DESTRO (endDrawer) ---
      endDrawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepPurple),
              child: Center(
                child: Text("impostazioni".tr(),
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              ),
            ),
            // Cambio Lingua
            ListTile(
              leading: const Icon(Icons.language, color: Colors.deepPurple),
              title: Text("lingua".tr()),
              trailing: Text(context.locale.languageCode.toUpperCase()),
              onTap: () {
                context.setLocale(context.locale.languageCode == 'it'
                    ? const Locale('en')
                    : const Locale('it'));
              },
            ),
            // Cambio Tema
            SwitchListTile(
              secondary: Icon(
                widget.tema == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                color: Colors.deepPurple,
              ),
              title: Text("tema_scuro".tr()),
              value: widget.tema == ThemeMode.dark,
              onChanged: (val) => widget.cambiatema(val),
            ),
            const Spacer(),
            const Divider(),
            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text("esci".tr(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context); // Chiude il menu prima del dialog
                effettuaLogout(context); // Chiama la funzione di logout con conferma
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      body: Column(
        children: [
          // Intestazione Viola
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 45, bottom: 20),
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    "diet_app_title".tr(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                // ICONA MENU A DESTRA (Apre l'endDrawer)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white, size: 26),
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Sezione Calorie
          Column(
            children: [
              IndicatoreCalorieAnimato(
                obiettivo: obiettivo,
                consumate: consumate,
              ),
              const SizedBox(height: 20),
              Text("calorie_rimanenti".tr(),
                  style: const TextStyle(color: Colors.deepPurple, fontSize: 16)),
              Text("$rimanenti",
                  style: const TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 40,
                      fontWeight: FontWeight.bold)),
            ],
          ),

          const SizedBox(height: 15),

          // --- WIDGET CONTAPASSI ---
          // --- WIDGET CONTAPASSI CON LIVELLO ATTIVITÀ ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.directions_walk, color: Colors.deepPurple),
                            const SizedBox(width: 8),
                            Text("passi_oggi".tr(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        // Visualizza i passi attuali rispetto al target
                        Text("${model.passi} / 10000",
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    // Barra di progresso
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (model.passi / 10000).clamp(0.0, 1.0),
                        backgroundColor: Colors.grey[200],
                        color: Colors.deepPurple,
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // LIVELLO DI ATTIVITÀ ATTUALE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("livello_attivita".tr(),
                            style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${model.nomeLivelloAttivita }", // Mostra il valore numerico
                            style: const TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: 14
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Lista dei prodotti consumati
          Expanded( // Ho cambiato SizedBox con Expanded per gestire meglio lo spazio
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: model.prodottiConsumati.length,
              itemBuilder: (context, index) {
                final p = model.prodottiConsumati[index];
                return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      leading: const Icon(Icons.fastfood, color: Colors.purple),
                      title: Text(p.nome,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text("${p.calorie} kcal",
                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    )
                );
              },
            ),
          ),

          // Tasto Aggiungi Prodotto
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => apriSelezioneProdotti(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text("aggiungi_prodotto".tr()),
                )
            ),
          ),
        ],
      ),
    );
  }
}
// --- NUOVO WIDGET ANIMATO BASATO SUL FILE PDF ---

class IndicatoreCalorieAnimato extends StatefulWidget {
  final int obiettivo;
  final int consumate;

  const IndicatoreCalorieAnimato({super.key, required this.obiettivo, required this.consumate});

  @override
  State<IndicatoreCalorieAnimato> createState() => _IndicatoreCalorieAnimatoState();
}

// Implementazione con TickerProviderStateMixin come richiesto [cite: 4, 5]
class _IndicatoreCalorieAnimatoState extends State<IndicatoreCalorieAnimato> with TickerProviderStateMixin {
  late AnimationController _controller; // [cite: 6]
  late Animation<double> _progressoAnimation; // [cite: 7]

  @override
  void initState() {
    super.initState();
    // Inizializzazione del controller con durata di 700ms [cite: 12]
    _controller = AnimationController(
      vsync: this, // [cite: 12]
      duration: const Duration(milliseconds: 700),
    );

    // Definizione dell'animazione curva [cite: 30]
    _progressoAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _aggiornaAnimazione();
  }

  @override
  void didUpdateWidget(IndicatoreCalorieAnimato oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.consumate != widget.consumate) {
      _aggiornaAnimazione();
    }
  }

  void _aggiornaAnimazione() {
    double valoreTarget = (widget.consumate / widget.obiettivo).clamp(0.0, 1.0);
    _controller.animateTo(valoreTarget); // Attivazione dell'animazione
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressoAnimation,
      builder: (context, child) {
        double valore = _progressoAnimation.value;

        // Logica Colori richiesta:
        // Rosso <= 50% | Arancione < 100% | Verde >= 100%
        Color coloreIndicatore;
        if (valore <= 0.5) {
          coloreIndicatore = Colors.red;
        } else if (valore < 1.0) {
          coloreIndicatore = Colors.orange;
        } else {
          coloreIndicatore = Colors.green;
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            // Sfondo del cerchio
            SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 12,
                color: Colors.deepPurple,
              ),
            ),
            // Parte animata
            SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                value: valore,
                strokeWidth: 12,
                strokeCap: StrokeCap.round,
                valueColor: AlwaysStoppedAnimation<Color>(coloreIndicatore),
              ),
            ),
            // Percentuale centrale
            Text(
              "${(valore * 100).toInt()}%",
              style: const TextStyle(
                  color: Colors.deepPurple,
                  fontSize: 24,
                  fontWeight: FontWeight.bold
              ),
            ),
          ],
        );
      },

    );
  }
}
