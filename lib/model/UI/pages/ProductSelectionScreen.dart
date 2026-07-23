import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:diet_app/model/objects/Prodotto.dart';

class SelezioneProdotti extends StatefulWidget {
  final ThemeMode tema;
  final Function(bool) cambiatema;

  const SelezioneProdotti({
    super.key,
    required this.tema,
    required this.cambiatema,
  });

  @override
  State<SelezioneProdotti> createState() => _SelezioneProdottiState();
}

class _SelezioneProdottiState extends State<SelezioneProdotti> {
  List<Prodotto> _prodotti = [];
  List<Prodotto> _prodottiFiltrati = [];
  String _query = "";
  bool _loading = true;

  void _mostraDialogGrammi(Prodotto prodotto, bool scuro, Color colorePrincipale) {
    final TextEditingController controllerGrammi = TextEditingController(text: "100");
    final Color coloreDialogBackground = scuro ? const Color(0xFF1E1E1E) : Colors.white;
    final Color coloreTesto = scuro ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: coloreDialogBackground,
          title: Text(prodotto.nome, style: TextStyle(color: coloreTesto, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Inserisci la quantità in grammi:".tr(),
                style: TextStyle(color: scuro ? Colors.grey[300] : Colors.grey[800]),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controllerGrammi,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: TextStyle(color: coloreTesto),
                decoration: InputDecoration(
                  labelText: "g",
                  labelStyle: TextStyle(color: scuro ? Colors.grey[400] : Colors.grey[700]),
                  suffixText: "g",
                  suffixStyle: TextStyle(color: colorePrincipale),
                  filled: true,
                  fillColor: scuro ? const Color(0xFF2C2C2C) : Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: colorePrincipale, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text("Annulla", style: TextStyle(color: scuro ? Colors.grey[400] : Colors.grey[600])).tr(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorePrincipale,
                foregroundColor: scuro ? Colors.black : Colors.white,
              ),
              onPressed: () {
                final double? grammi = double.tryParse(controllerGrammi.text);
                if (grammi != null && grammi > 0) {
                  final int calorieCalcolate = ((prodotto.calorie * grammi) / 100).round();

                  final prodottoConGrammi = Prodotto(
                    id: prodotto.id,
                    nome: "${prodotto.nome} (${grammi.toInt()}g)",
                    calorie: calorieCalcolate,
                  );

                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pop(prodottoConGrammi);
                }
              },
              child: const Text("Aggiungi", style: TextStyle(fontWeight: FontWeight.bold)).tr(),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _caricaProdotti();
  }

  void _caricaProdotti() async {
    setState(() {
      _prodotti = [
        Prodotto(id: 1, nome: "Mela".tr(), calorie: 52),
        Prodotto(id: 2, nome: "Banana".tr(), calorie: 89),
        Prodotto(id: 3, nome: "Arancia".tr(), calorie: 47),
        Prodotto(id: 4, nome: "Pera".tr(), calorie: 57),
        Prodotto(id: 5, nome: "Uva".tr(), calorie: 69),
        Prodotto(id: 6, nome: "Ananas".tr(), calorie: 50),
        Prodotto(id: 7, nome: "Kiwi".tr(), calorie: 61),
        Prodotto(id: 8, nome: "Fragole".tr(), calorie: 32),
        Prodotto(id: 9, nome: "Lamponi".tr(), calorie: 52),
        Prodotto(id: 10, nome: "Mirtilli".tr(), calorie: 57),
        Prodotto(id: 11, nome: "Pesca".tr(), calorie: 39),
        Prodotto(id: 12, nome: "Albicocca".tr(), calorie: 48),
        Prodotto(id: 13, nome: "Ciliegie".tr(), calorie: 63),
        Prodotto(id: 14, nome: "Melone".tr(), calorie: 34),
        Prodotto(id: 15, nome: "Anguria".tr(), calorie: 30),
        Prodotto(id: 16, nome: "Pompelmo".tr(), calorie: 42),
        Prodotto(id: 17, nome: "Fichi".tr(), calorie: 74),
        Prodotto(id: 18, nome: "Prugne".tr(), calorie: 46),
        Prodotto(id: 19, nome: "Avocado".tr(), calorie: 160),
        Prodotto(id: 20, nome: "Mango".tr(), calorie: 60),
        Prodotto(id: 21, nome: "Carote".tr(), calorie: 41),
        Prodotto(id: 22, nome: "Pomodori".tr(), calorie: 18),
        Prodotto(id: 23, nome: "Zucchine".tr(), calorie: 17),
        Prodotto(id: 24, nome: "Melanzane".tr(), calorie: 25),
        Prodotto(id: 25, nome: "Peperoni".tr(), calorie: 31),
        Prodotto(id: 26, nome: "Patate".tr(), calorie: 77),
        Prodotto(id: 27, nome: "Cipolle".tr(), calorie: 40),
        Prodotto(id: 28, nome: "Aglio".tr(), calorie: 149),
        Prodotto(id: 29, nome: "Lattuga".tr(), calorie: 15),
        Prodotto(id: 30, nome: "Spinaci".tr(), calorie: 23),
        Prodotto(id: 31, nome: "Broccoli".tr(), calorie: 34),
        Prodotto(id: 32, nome: "Cavolfiore".tr(), calorie: 25),
        Prodotto(id: 33, nome: "Cavolo nero".tr(), calorie: 49),
        Prodotto(id: 34, nome: "Piselli".tr(), calorie: 81),
        Prodotto(id: 35, nome: "Fagiolini".tr(), calorie: 31),
        Prodotto(id: 36, nome: "Zucca".tr(), calorie: 26),
        Prodotto(id: 37, nome: "Sedano".tr(), calorie: 16),
        Prodotto(id: 38, nome: "Finocchio".tr(), calorie: 31),
        Prodotto(id: 39, nome: "Rapa".tr(), calorie: 28),
        Prodotto(id: 40, nome: "Barbabietola".tr(), calorie: 43),
        Prodotto(id: 41, nome: "Riso bianco".tr(), calorie: 130),
        Prodotto(id: 42, nome: "Riso integrale".tr(), calorie: 111),
        Prodotto(id: 43, nome: "Pasta".tr(), calorie: 131),
        Prodotto(id: 44, nome: "Pane bianco".tr(), calorie: 265),
        Prodotto(id: 45, nome: "Pane integrale".tr(), calorie: 247),
        Prodotto(id: 46, nome: "Quinoa".tr(), calorie: 120),
        Prodotto(id: 47, nome: "Avena".tr(), calorie: 389),
        Prodotto(id: 48, nome: "Orzo".tr(), calorie: 354),
        Prodotto(id: 49, nome: "Mais".tr(), calorie: 86),
        Prodotto(id: 50, nome: "Cous cous".tr(), calorie: 112),
        Prodotto(id: 51, nome: "Pollo".tr(), calorie: 165),
        Prodotto(id: 52, nome: "Tacchino".tr(), calorie: 135),
        Prodotto(id: 53, nome: "Manzo".tr(), calorie: 250),
        Prodotto(id: 54, nome: "Maiale".tr(), calorie: 242),
        Prodotto(id: 55, nome: "Agnello".tr(), calorie: 294),
        Prodotto(id: 56, nome: "Prosciutto crudo".tr(), calorie: 241),
        Prodotto(id: 57, nome: "Wurstel".tr(), calorie: 290),
        Prodotto(id: 58, nome: "Bresaola".tr(), calorie: 151),
        Prodotto(id: 59, nome: "Speck".tr(), calorie: 300),
        Prodotto(id: 60, nome: "Salame".tr(), calorie: 336),
        Prodotto(id: 61, nome: "Salmone".tr(), calorie: 208),
        Prodotto(id: 62, nome: "Tonno".tr(), calorie: 132),
        Prodotto(id: 63, nome: "Merluzzo".tr(), calorie: 82),
        Prodotto(id: 64, nome: "Sgombro".tr(), calorie: 205),
        Prodotto(id: 65, nome: "Orata".tr(), calorie: 96),
        Prodotto(id: 66, nome: "Branzino".tr(), calorie: 124),
        Prodotto(id: 67, nome: "Gamberi".tr(), calorie: 99),
        Prodotto(id: 68, nome: "Polpo".tr(), calorie: 82),
        Prodotto(id: 69, nome: "Calamari".tr(), calorie: 92),
        Prodotto(id: 70, nome: "Sardine".tr(), calorie: 208),
        Prodotto(id: 71, nome: "Latte intero".tr(), calorie: 61),
        Prodotto(id: 72, nome: "Latte scremato".tr(), calorie: 34),
        Prodotto(id: 73, nome: "Yogurt bianco".tr(), calorie: 59),
        Prodotto(id: 74, nome: "Yogurt greco".tr(), calorie: 120),
        Prodotto(id: 75, nome: "Formaggio grana".tr(), calorie: 431),
        Prodotto(id: 76, nome: "Mozzarella".tr(), calorie: 280),
        Prodotto(id: 77, nome: "Ricotta".tr(), calorie: 174),
        Prodotto(id: 78, nome: "Burro".tr(), calorie: 717),
        Prodotto(id: 79, nome: "Panna".tr(), calorie: 340),
        Prodotto(id: 80, nome: "Cheddar".tr(), calorie: 403),
        Prodotto(id: 81, nome: "Uova".tr(), calorie: 155),
        Prodotto(id: 82, nome: "Tofu".tr(), calorie: 76),
        Prodotto(id: 83, nome: "Fagioli secchi".tr(), calorie: 347),
        Prodotto(id: 84, nome: "Lenticchie".tr(), calorie: 116),
        Prodotto(id: 85, nome: "Ceci".tr(), calorie: 364),
        Prodotto(id: 86, nome: "Soia".tr(), calorie: 446),
        Prodotto(id: 87, nome: "Mandorle".tr(), calorie: 579),
        Prodotto(id: 88, nome: "Noci".tr(), calorie: 654),
        Prodotto(id: 89, nome: "Arachidi".tr(), calorie: 567),
        Prodotto(id: 90, nome: "Pistacchi".tr(), calorie: 562),
        Prodotto(id: 91, nome: "Olio di oliva".tr(), calorie: 884),
        Prodotto(id: 92, nome: "Zucchero".tr(), calorie: 387),
        Prodotto(id: 93, nome: "Miele".tr(), calorie: 304),
        Prodotto(id: 94, nome: "Cioccolato fondente".tr(), calorie: 546),
        Prodotto(id: 95, nome: "Biscotti".tr(), calorie: 502),
        Prodotto(id: 96, nome: "Torta margherita".tr(), calorie: 297),
        Prodotto(id: 97, nome: "Gelato".tr(), calorie: 207),
        Prodotto(id: 98, nome: "Cornflakes".tr(), calorie: 357),
        Prodotto(id: 99, nome: "Crackers".tr(), calorie: 421),
        Prodotto(id: 100, nome: "Pizza margherita".tr(), calorie: 266),
      ];
      _prodottiFiltrati = _prodotti;
      _loading = false;
    });
  }

  void _filtraProdotti(String query) {
    setState(() {
      _query = query;
      if (query.isEmpty) {
        _prodottiFiltrati = _prodotti;
      } else {
        _prodottiFiltrati = _prodotti
            .where((p) => p.nome.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool scuro = widget.tema == ThemeMode.dark;

    // Colori adattivi per Tema Chiaro / Scuro
    final Color colorePrincipale = scuro ? Colors.amber : Colors.deepPurple;
    final Color coloreSfondoScaffold = scuro ? const Color(0xFF121212) : Colors.grey[100]!;
    final Color coloreSearchFill = scuro ? const Color(0xFF1E1E1E) : Colors.white;
    final Color coloreTesto = scuro ? Colors.white : Colors.black;
    final Color coloreCard = scuro ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: coloreSfondoScaffold,
      appBar: AppBar(
        title: Text("titolo_selezione").tr(),
        backgroundColor: colorePrincipale,
        foregroundColor: scuro ? Colors.black : Colors.white,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: colorePrincipale))
          : Column(
        children: [
          // CAMPO DI RICERCA
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: _filtraProdotti,
              style: TextStyle(color: coloreTesto),
              decoration: InputDecoration(
                labelText: "cerca_alimento".tr(),
                labelStyle: TextStyle(color: scuro ? Colors.grey[400] : Colors.grey[700]),
                hintText: "es_mela".tr(),
                hintStyle: TextStyle(color: scuro ? Colors.grey[500] : Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: colorePrincipale),
                filled: true,
                fillColor: coloreSearchFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: colorePrincipale, width: 2),
                ),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: colorePrincipale),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _filtraProdotti("");
                  },
                )
                    : null,
              ),
            ),
          ),

          // LISTA PRODOTTI
          Expanded(
            child: _prodottiFiltrati.isEmpty
                ? Center(
              child: Text(
                "nessun_alimento_trovato".tr(),
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            )
                : ListView.builder(
              itemCount: _prodottiFiltrati.length,
              itemBuilder: (context, index) {
                final p = _prodottiFiltrati[index];
                return Card(
                  color: coloreCard,
                  elevation: scuro ? 1 : 2,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      p.nome,
                      style: TextStyle(
                        color: scuro ? Colors.amber : Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${p.calorie} ${"kcal".tr()} / 100g",
                      style: TextStyle(
                        color: scuro ? Colors.amber[300] : Colors.deepPurple[300],
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                      onPressed: () {
                        _mostraDialogGrammi(p, scuro, colorePrincipale);
                      },
                    ),
                    onTap: () {
                      _mostraDialogGrammi(p, scuro, colorePrincipale);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}