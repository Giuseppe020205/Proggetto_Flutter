import 'package:diet_app/model/objects/Enums.dart';
class UserData {
  final String email, nome;
  final Genere genere;
  final int eta;
  final double peso, altezza;
  double livelloAttivita;
  final TipoObbiettivo obbiettivo;

  UserData({
    required this.email, required this.nome, required this.genere,
    required this.eta, required this.peso, required this.altezza,
    required this.livelloAttivita, required this.obbiettivo,
  });

  // Metodo per creare una copia modificata (utile per lo stato)
  UserData copyWith({double? peso, TipoObbiettivo? obbiettivo}) {
    return UserData(
      email: email, nome: nome, genere: genere, eta: eta,
      peso: peso ?? this.peso, altezza: altezza,
      livelloAttivita: livelloAttivita, obbiettivo: obbiettivo ?? this.obbiettivo,
    );
  }
}