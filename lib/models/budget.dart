class Budget {
  const Budget({
    required this.clientName,
    required this.serviceDescription,
    required this.validityDays,
    required this.materialCost,
    required this.hours,
    required this.hourlyRate,
    required this.extraExpenses,
    required this.profitPercentage,
    this.discountPercentage = 0,
    this.roundPrice = false,
    this.createdAt,
  });

  final String clientName;
  final String serviceDescription;
  final int validityDays;
  final double materialCost;
  final double hours;
  final double hourlyRate;
  final double extraExpenses;
  final double profitPercentage;
  final double discountPercentage;
  final bool roundPrice;
  final DateTime? createdAt;

  double get laborCost => hours * hourlyRate;
  double get subtotal => materialCost + laborCost + extraExpenses;
  double get profitAmount => subtotal * (profitPercentage / 100);
  double get priceBeforeDiscount => subtotal + profitAmount;
  double get discountAmount => priceBeforeDiscount * (discountPercentage / 100);
  double get calculatedPrice => priceBeforeDiscount - discountAmount;
  double get suggestedPrice =>
      roundPrice ? calculatedPrice.ceilToDouble() : calculatedPrice;

  Map<String, Object?> toJson() => {
    'clientName': clientName,
    'serviceDescription': serviceDescription,
    'validityDays': validityDays,
    'materialCost': materialCost,
    'hours': hours,
    'hourlyRate': hourlyRate,
    'extraExpenses': extraExpenses,
    'profitPercentage': profitPercentage,
    'discountPercentage': discountPercentage,
    'roundPrice': roundPrice,
    'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
  };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
    clientName: json['clientName'] as String? ?? '',
    serviceDescription: json['serviceDescription'] as String? ?? '',
    validityDays: (json['validityDays'] as num?)?.toInt() ?? 7,
    materialCost: (json['materialCost'] as num).toDouble(),
    hours: (json['hours'] as num).toDouble(),
    hourlyRate: (json['hourlyRate'] as num).toDouble(),
    extraExpenses: (json['extraExpenses'] as num).toDouble(),
    profitPercentage: (json['profitPercentage'] as num).toDouble(),
    discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0,
    roundPrice: json['roundPrice'] as bool? ?? false,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
  );
}
