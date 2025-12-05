class PricingResult {
  final double unitPriceUsed;
  final double sellPrice;
  final double costPrice;
  final double profit;
  final bool isFullPack;
  final double quantityKg;

  PricingResult({
    required this.unitPriceUsed,
    required this.sellPrice,
    required this.costPrice,
    required this.profit,
    required this.isFullPack,
    required this.quantityKg,
  });
}

class PricingCalculator {
  static PricingResult calculateTransaction({
    required double packetWeightKg,
    required double costPerKg,
    required double sellingRatePerKg,
    required double mrpPerKg,
    required String saleAmountRaw,
  }) {
    // 1. Normalize sale_amount to kilograms
    double saleAmountKg = _normalizeToKg(saleAmountRaw);

    // 2. Compute cost_per_packet_total (for reference, not strictly used in final calc but good to know)
    // double costPerPacketTotal = costPerKg * packetWeightKg;

    // 3. Decide Selling Rate (Loose vs Full Pack)
    // If Full Pack -> Use MRP
    // If Loose -> Use Selling Price (Loose)
    bool isFullPack = (saleAmountKg - packetWeightKg).abs() < 0.0001;
    double sellingRateToUse = isFullPack ? mrpPerKg : sellingRatePerKg;

    // 4. Calculate 'a' (Total Selling Price)
    // a = {quantity * selling_price}
    double a = double.parse(
      (saleAmountKg * sellingRateToUse).toStringAsFixed(2),
    );

    // 5. Calculate 'b' (Total Cost Price)
    // b = {quantity * buying_price}
    double b = double.parse((saleAmountKg * costPerKg).toStringAsFixed(2));

    // 6. Calculate Profit 'p'
    // p = a - b
    double profit = double.parse((a - b).toStringAsFixed(2));

    // Map to output variables
    double sellPrice = a;
    double costOfSoldQty = b;
    double unitPriceUsedPerKg = sellingRateToUse;

    // Handle zero or negative sale
    if (saleAmountKg <= 0) {
      sellPrice = 0;
      profit = 0;
      costOfSoldQty = 0;
    }

    return PricingResult(
      unitPriceUsed: unitPriceUsedPerKg,
      sellPrice: sellPrice,
      costPrice: costOfSoldQty,
      profit: profit,
      isFullPack: isFullPack,
      quantityKg: saleAmountKg,
    );
  }

  static double _normalizeToKg(String input) {
    String lowerInput = input.toLowerCase().trim();
    double value = 0.0;

    if (lowerInput.endsWith('kg')) {
      value = double.tryParse(lowerInput.replaceAll('kg', '').trim()) ?? 0.0;
    } else if (lowerInput.endsWith('g')) {
      value =
          (double.tryParse(lowerInput.replaceAll('g', '').trim()) ?? 0.0) /
          1000.0;
    } else {
      // Assume raw number is kg if no unit specified, or handle as needed.
      // Based on user prompt "numeric(sale_amount)" usually implies base unit.
      // Given the context of "250g" vs "2.5kg", if just "2.5" is passed, we assume kg.
      value = double.tryParse(lowerInput) ?? 0.0;
    }
    return value;
  }
}
