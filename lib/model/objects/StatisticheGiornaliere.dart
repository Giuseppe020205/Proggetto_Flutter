// lib/model/objects/StatisticheGiornaliere.dart
import 'Prodotto.dart';

class StatisticheGiornaliere {
  final int calorieTotali;
  final int calorieConsumate;
  final List<Prodotto> prodottiConsumati;

  StatisticheGiornaliere({
    required this.calorieTotali,
    required this.calorieConsumate,
    required this.prodottiConsumati,
  });

  StatisticheGiornaliere copyWith({
    int? calorieTotali,
    int? calorieConsumate,
    List<Prodotto>? prodottiConsumati,
  }) {
    return StatisticheGiornaliere(
      calorieTotali: calorieTotali ?? this.calorieTotali,
      calorieConsumate: calorieConsumate ?? this.calorieConsumate,
      prodottiConsumati: prodottiConsumati ?? this.prodottiConsumati,
    );
  }
}