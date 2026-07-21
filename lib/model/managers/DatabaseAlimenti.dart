// lib/model/managers/DatabaseAlimenti.dart
import 'package:postgres/postgres.dart';
import 'dart:developer';
import 'package:diet_app/model/objects/Prodotto.dart';
import 'package:diet_app/model/objects/UserData.dart';
import 'package:diet_app/model/objects/Enums.dart';

// CLASSE GESTORE DATABASE
class DatabaseAlimenti {
  // Configurazione connessione
  static final PostgreSQLConnection connection = PostgreSQLConnection(
    'localhost',
    5432,
    "databaseAlimenti",
    username: "postgres",
    password: "Postgres123!",
    useSSL: false,
  );
  //CONTROLLO APERTURA CONNESSIONE
  static Future<void> _checkConnection() async {
    if (connection.isClosed) {
      await connection.open();
      log("Connessione al database aperta");
    }
  }
// Metodo per registrare un nuovo utente nel database
  static Future<void> registraNuovoUtente({
    required String email,
    required String nome,
    required String password,
    required String genere,
    required int eta,
    required double peso,
    required double altezza,
    required double livelloattivita,
    required String obbiettivo
  }) async {
    try {
      // 1. Verifichiamo che la connessione sia aperta
      await _checkConnection();

      // 2. Eseguiamo la query di inserimento
      await connection.query(
        'INSERT INTO utenti (email, nome, password,genere, eta, peso, altezza,livello_attivita,obbiettivo) '
            'VALUES (@email, @nome, @password, @genere, @eta, @peso, @altezza, @livello, @obbiettivo)',
        substitutionValues: {
          "email": email,
          "nome": nome,
          "password": password,
          "genere":genere,
          "eta": eta,
          "peso": peso,
          "altezza": altezza,
          "livello": livelloattivita,
          "obbiettivo" : obbiettivo
        },
      );

      log("Database: Utente $email registrato con successo.");
    } catch (e) {
      log("Database Error (Registrazione): $e");
      // Rilanciamo l'errore per gestirlo nella UI (mostrare lo SnackBar)
      rethrow;
    }
  }
  // recupero dati utente tramite email
   static Future<UserData?> getUtenteconEmail(String email) async {
    try {
      await _checkConnection();

      List<List<dynamic>> results = await connection.query(
        'SELECT email, nome, genere, eta, peso, altezza, livello_attivita, obbiettivo FROM utenti WHERE email = @e',
        substitutionValues: {"e": email},
      );

      if (results.isNotEmpty) {
        final r = results.first;

        // Mappatura sicura dei dati
        return UserData(
          email: r[0].toString(),
          nome: r[1].toString(),
          // Se nel DB è salvato come "MASCHIO" o "FEMMINA" (usando .name)
          genere: r[2].toString() == "MASCHIO" ? Genere.MASCHIO : Genere.FEMMINA,
          eta: (r[3] as num).toInt(),
          peso: double.tryParse(r[4].toString()) ?? 0.0,
          altezza: double.tryParse(r[5].toString()) ?? 0.0,
          livelloAttivita: double.tryParse(r[6].toString()) ?? 1.2,
          obbiettivo: TipoObbiettivo.values.firstWhere(
                (e) => e.name == r[7].toString(),
            orElse: () => TipoObbiettivo.MANTENERE_PESO,
          ),
        );
      }
      return null; // Utente non trovato
    } catch (e) {
      log("Errore Database (getUtenteByEmail): $e");
      return null;
    }
  }
  // recupero lista Alimenti
  static Future<List<Prodotto>> getProdotti() async {
    await _checkConnection();
    List<List<dynamic>> results = await connection.query('SELECT id, nome, calorie FROM alimenti');

    return results.map((row) => Prodotto(
      id: row[0],
      nome: row[1],
      calorie: int.tryParse(row[2].toString()) ?? 0,
    )).toList();
  }

  // Metodo per il login che restituisce un oggetto UserData
  static Future<UserData?> loginUtente(String email, String password) async {
    await _checkConnection();
    List<List<dynamic>> results = await connection.query(
      'SELECT email, nome, genere, eta, peso, altezza, livello_attivita, obbiettivo FROM utenti WHERE email = @e AND password = @p',
      substitutionValues: {"e": email, "p": password},
    );

    if (results.isNotEmpty) {
      final r = results.first;
      return UserData(
        email: r[0],
        nome: r[1],
        genere: r[2] == "M" ? Genere.MASCHIO : Genere.FEMMINA,
        eta: (r[3] as num).toInt(),
        peso: (r[4] as num).toDouble(),
        altezza: (r[5] as num).toDouble(),
        livelloAttivita: r[6],
        obbiettivo: TipoObbiettivo.values.firstWhere((e) => e.toString() == r[7]),
      );
    }
    return null;
  }
}