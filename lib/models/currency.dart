class Currency {
  int? currencyId;
  String name;
  String symbol;

  Currency({
    this.currencyId,
    required this.name,
    required this.symbol,
  });

  Map<String, dynamic> toMap() {
    return {
      'currency_id': currencyId,
      'name': name,
      'symbol': symbol,
    };
  }

  factory Currency.fromMap(Map<String, dynamic> map) {
    return Currency(
      currencyId: map['currency_id'],
      name: map['name'],
      symbol: map['symbol'],
    );
  }
}
