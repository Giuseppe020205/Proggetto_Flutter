import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:diet_app/model/Model.dart';
import 'package:diet_app/model/objects/Prodotto.dart';
import 'package:diet_app/model/UI/pages/ProductSelectionScreen.dart';
import 'package:diet_app/model/UI/pages/RegistrationScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        pageBuilder: (context, _, __) => SelezioneProdotti(
          tema: widget.tema,
          cambiatema: widget.cambiatema,
        ),
      ),
    );

    if (risultato != null && risultato is Prodotto) {
      Model.sharedInstance.aggiungiProdotto(risultato);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${risultato.nome} ${"aggiunto".tr()}"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void effettuaLogout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("esci".tr()),
          content: Text("logout_messaggio".tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("indietro".tr(), style: const TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

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
  Widget build(BuildContext context) {
    final model = Provider.of<Model>(context);
    final isDark = widget.tema == ThemeMode.dark;

    // Colori principali condizionali: Viola in Light Mode, Ambra in Dark Mode
    final Color colorePrincipale = isDark ? Colors.amber : Colors.deepPurple;
    final Color coloreTestoPrincipale = isDark ? Colors.amber : Colors.deepPurple;
    final Color coloreSfondoScaffold = isDark ? const Color(0xFF121212) : Colors.grey[200]!;
    final Color coloreCard = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color coloreTestoTitoli = isDark ? Colors.white : Colors.black;

    final int obiettivo = model.calcolaRapportoCalorico(model.userData);
    final int consumate = model.statistiche.calorieConsumate;
    final int rimanenti = obiettivo - consumate;

    return Scaffold(
      backgroundColor: coloreSfondoScaffold,

      // MENU LATERALE DESTRO
      endDrawer: Drawer(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: colorePrincipale),
              child: Center(
                child: Text(
                  "impostazioni".tr(),
                  style: TextStyle(
                    color: isDark ? Colors.black : Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // CAMBIO DI LINGUA
            ListTile(
              leading: Icon(Icons.language, color: colorePrincipale),
              title: Text(
                context.locale.languageCode == 'it' ? "Italiano" : "English",
                style: TextStyle(color: coloreTestoTitoli),
              ),
              onTap: () {
                context.setLocale(context.locale.languageCode == 'it' ? const Locale('en') : const Locale('it'));
                Navigator.pop(context);
              },
            ),
            // CAMBIO TEMA (SOLUZIONE A)
            SwitchListTile(
              secondary: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: colorePrincipale,
              ),
              title: Text("tema_scuro".tr(), style: TextStyle(color: coloreTestoTitoli)),
              value: isDark,
              onChanged: (val) {
                // 1. Invocazione callback globale del tema
                widget.cambiatema(val);
                // 2. Forza il refresh grafico immediato della schermata corrente
                setState(() {});
              },
            ),
            const Spacer(),
            const Divider(),
            // LOGOUT
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text("esci".tr(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                effettuaLogout(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      body: Column(
        children: [
          // HEADER SUPERIORE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 45, bottom: 20),
            decoration: BoxDecoration(
              color: colorePrincipale,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    "titolo".tr(),
                    style: TextStyle(
                      color: isDark ? Colors.black : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // ICONA MENU A DESTRA
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Builder(
                      builder: (context) => IconButton(
                        icon: Icon(Icons.menu, color: isDark ? Colors.black : Colors.white, size: 26),
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // SEZIONE CALORIE
          Column(
            children: [
              IndicatoreCalorieAnimato(
                obiettivo: obiettivo,
                consumate: consumate,
                isDark: isDark,
              ),
              const SizedBox(height: 20),
              Text(
                "calorie_rimanenti".tr(),
                style: TextStyle(color: coloreTestoPrincipale, fontSize: 16),
              ),
              Text(
                "$rimanenti",
                style: TextStyle(
                  color: coloreTestoPrincipale,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // WIDGET CONTAPASSI CON LIVELLO ATTIVITÀ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              color: coloreCard,
              elevation: isDark ? 1 : 3,
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
                            Icon(Icons.directions_walk, color: colorePrincipale),
                            const SizedBox(width: 8),
                            Text(
                              "passi".tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: coloreTestoTitoli,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "${model.passi} ",
                          style: TextStyle(fontWeight: FontWeight.bold, color: colorePrincipale),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    // BARRA DI PROGRESSO
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (model.passi / 10000).clamp(0.0, 1.0),
                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                        color: colorePrincipale,
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 15),
                    // LIVELLO DI ATTIVITÀ ATTUALE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "livello_attivita".tr(),
                          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorePrincipale.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${model.nomeLivelloAttivita}",
                            style: TextStyle(
                              color: colorePrincipale,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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

          // LISTA PRODOTTI CONSUMATI
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: model.prodottiConsumati.length,
              itemBuilder: (context, index) {
                final p = model.prodottiConsumati[index];
                return Card(
                  color: coloreCard,
                  elevation: isDark ? 1 : 2,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: Icon(Icons.fastfood, color: isDark ? Colors.amber : Colors.purple),
                    title: Text(
                      p.nome,
                      style: TextStyle(fontWeight: FontWeight.bold, color: coloreTestoTitoli),
                    ),
                    trailing:  Text(
                      "${p.calorie} kcal",
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),

          // TASTO AGGIUNGI PRODOTTO
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => apriSelezioneProdotti(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorePrincipale,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text("aggiungi_nuovo".tr()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IndicatoreCalorieAnimato extends StatefulWidget {
  final int obiettivo;
  final int consumate;
  final bool isDark;

  const IndicatoreCalorieAnimato({
    super.key,
    required this.obiettivo,
    required this.consumate,
    required this.isDark,
  });

  @override
  State<IndicatoreCalorieAnimato> createState() => _IndicatoreCalorieAnimatoState();
}

class _IndicatoreCalorieAnimatoState extends State<IndicatoreCalorieAnimato> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressoAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

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
    _controller.animateTo(valoreTarget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color coloreBordo = widget.isDark ? Colors.amber : Colors.deepPurple;

    return AnimatedBuilder(
      animation: _progressoAnimation,
      builder: (context, child) {
        double valore = _progressoAnimation.value;

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
                color: coloreBordo,
              ),
            ),
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
            // PERCENTUALE CENTRALE
            Text(
              "${(valore * 100).toInt()}%",
              style: TextStyle(
                color: coloreBordo,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }
}