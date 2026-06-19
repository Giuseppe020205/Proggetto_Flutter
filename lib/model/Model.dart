import 'package:flutter/material.dart';
// Importiamo solo ciò che riguarda i DATI (Model)
import 'package:diet_app/model/objects/Enums.dart'; // Controlla se il nome è Enums.dart o AppEnums.dart
import 'package:diet_app/model/objects/UserData.dart';
import 'package:diet_app/model/objects/Prodotto.dart';
import 'package:diet_app/model/objects/StatisticheGiornaliere.dart';

class Model extends ChangeNotifier {



  static final Model sharedInstance = Model._internal();
  Model._internal();

  // Dati dell'utente
  UserData _userData = UserData(
      email: "", nome: "", genere: Genere.MASCHIO,eta: 0, peso: 0.0,
      altezza: 0.0, livelloAttivita: 1.2, obbiettivo: TipoObbiettivo.MANTENERE_PESO
  );
  List<Prodotto> get prodottiConsumati => statistiche.prodottiConsumati;

  // Stato delle statistiche
  StatisticheGiornaliere _statistiche = StatisticheGiornaliere(
      calorieTotali: 0,
      calorieConsumate: 0,
      prodottiConsumati: []
  );

  // Getter per la UI
  UserData get userData => _userData;
  StatisticheGiornaliere get statistiche => _statistiche;

  // Metodo per aggiungere prodotti
  void aggiungiProdotto(Prodotto p) {
    // Creiamo una nuova lista aggiungendo il prodotto
    final nuovaLista = List<Prodotto>.from(_statistiche.prodottiConsumati)..add(p);

    // Aggiorniamo l'oggetto statistiche (usa il metodo copyWith del tuo oggetto)
    _statistiche = _statistiche.copyWith(
      calorieConsumate: _statistiche.calorieConsumate + p.calorie,
      prodottiConsumati: nuovaLista,
    );

    notifyListeners(); // Notifica la UI
  }

  void updateUserData(UserData nuovoUtente) {
    _userData = nuovoUtente;
    _statistiche = _statistiche.copyWith(
        calorieTotali: calcolaRapportoCalorico(nuovoUtente)
    );
    notifyListeners();
  }

  int calcolaRapportoCalorico(UserData utente) {
    double mb = (utente.genere == Genere.MASCHIO)
        ? (10 * utente.peso) + (6.25 * utente.altezza) - (5 * utente.eta) + 5
        : (10 * utente.peso) + (6.25 * utente.altezza) - (5 * utente.eta) - 161;

    double tdee = mb * utente.livelloAttivita;
    if (utente.obbiettivo == TipoObbiettivo.GUADAGNARE_PESO) tdee += 500;
    else if (utente.obbiettivo == TipoObbiettivo.PERDERE_PESO) tdee -= 500;

    return tdee.toInt();
  }
  int _passi = 0; // Questa è la variabile "privata"

  // Getter per leggere i passi dalla UI
  int get passi => _passi;

  // Metodo per aggiornare i passi e ridisegnare l'interfaccia
  void setPassi(int nuoviPassi) {
    _passi = nuoviPassi;

    // IMPORTANTE: Qui puoi integrare la logica che cambia il livello di attività
    if (userData != null) {
      if (_passi > 10000) {
        userData!.livelloAttivita = 1.7; // Diventa "Attivo"
      } else if (_passi > 5000) {
        userData!.livelloAttivita = 1.4; // Moderato
      }
    }

    notifyListeners(); // Avvisa l'app di aggiornare il cerchio e la barra
  }
  String get nomeLivelloAttivita {
    double valore = userData?.livelloAttivita ?? 1.2;

    if (valore <= 1.2) return "sedentario";
    if (valore <= 1.4) return "moderato";
    if (valore <= 1.6) return "attivo";
    return "molto_attivo";
  }
}
