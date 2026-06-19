import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:diet_app/model/Model.dart';
import 'package:diet_app/model/objects/Prodotto.dart';


// Definizione dell'oggetto Prodotto se non l'hai già in un file objects
class SelezioneProdotti extends StatefulWidget {
  const SelezioneProdotti({super.key});

  @override
  State<SelezioneProdotti> createState() => _SelezioneProdottiState();
}

class _SelezioneProdottiState extends State<SelezioneProdotti> {
  List<Prodotto> _prodotti = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _caricaProdotti();
  }

  void _caricaProdotti() async {
    // Simulazione o chiamata a DatabaseManager [cite: 65, 68]
    // final dati = await DatabaseAlimenti.getProdotti();
    setState(() {
      _prodotti = [
        Prodotto(id: 1, nome: "Mela", calorie: 52),
        Prodotto(id: 2, nome: "Pasta", calorie: 350),
      ];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("titolo_selezione").tr()),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _prodotti.length,
        itemBuilder: (context, index) {
          final p = _prodotti[index];
          return ListTile(
            title: Text(p.nome),
            subtitle: Text("${p.calorie} ${"kcal".tr()} / 100g"),
            trailing: const Icon(Icons.add_circle_outline),
            onTap: () {
              // Ritorna il prodotto alla pagina precedente (ControllaCalorie) [cite: 383]
              Navigator.of(context).pop(p);
            },
          );
        },
      ),
    );
  }
}