import 'package:flutter_test/flutter_test.dart';
import '../lib/utils/pricing_calculator.dart';

void main() {
  group('PricingCalculator Tests', () {
    test('Example 1: 250g of 5kg pack', () {
      final result = PricingCalculator.calculateTransaction(
        packetWeightKg: 5.0,
        costPerKg: 100.0,
        sellingRatePerKg: 110.0,
        mrpPerKg: 105.0,
        saleAmountRaw: '250g',
      );
      expect(result.unitPriceUsed, 110.0);
      expect(result.sellPrice, 27.5);
      expect(result.costPrice, 25.0);
      expect(result.profit, 2.5);
    });

    test('Example 2: 2.5kg of 5kg pack', () {
      final result = PricingCalculator.calculateTransaction(
        packetWeightKg: 5.0,
        costPerKg: 100.0,
        sellingRatePerKg: 110.0,
        mrpPerKg: 105.0,
        saleAmountRaw: '2.5kg',
      );
      expect(result.unitPriceUsed, 110.0);
      expect(result.sellPrice, 275.0);
      expect(result.costPrice, 250.0);
      expect(result.profit, 25.0);
    });

    test('Example 3: 5kg of 5kg pack (Full)', () {
      final result = PricingCalculator.calculateTransaction(
        packetWeightKg: 5.0,
        costPerKg: 100.0,
        sellingRatePerKg: 110.0,
        mrpPerKg: 105.0,
        saleAmountRaw: '5kg',
      );
      expect(result.unitPriceUsed, 105.0);
      expect(result.sellPrice, 525.0);
      expect(result.costPrice, 500.0);
      expect(result.profit, 25.0);
    });

    test('Example 4: 125g of 5kg pack', () {
      final result = PricingCalculator.calculateTransaction(
        packetWeightKg: 5.0,
        costPerKg: 95.0,
        sellingRatePerKg: 120.0,
        mrpPerKg: 118.0,
        saleAmountRaw: '125g',
      );
      expect(result.unitPriceUsed, 120.0);
      expect(result.sellPrice, 15.0);
      expect(result.costPrice, 11.88); // 95 * 0.125 = 11.875 -> 11.88
      expect(result.profit, 3.12);
    });

    test('Example 5: 750g of 10kg pack', () {
      final result = PricingCalculator.calculateTransaction(
        packetWeightKg: 10.0,
        costPerKg: 80.0,
        sellingRatePerKg: 90.0,
        mrpPerKg: 88.0,
        saleAmountRaw: '750g',
      );
      expect(result.unitPriceUsed, 90.0);
      expect(result.sellPrice, 67.5);
      expect(result.costPrice, 60.0);
      expect(result.profit, 7.5);
    });

    test('Example 6: 500g of 2kg pack', () {
      final result = PricingCalculator.calculateTransaction(
        packetWeightKg: 2.0,
        costPerKg: 60.0,
        sellingRatePerKg: 70.0,
        mrpPerKg: 68.0,
        saleAmountRaw: '500g',
      );
      expect(result.unitPriceUsed, 70.0);
      expect(result.sellPrice, 35.0);
      expect(result.costPrice, 30.0);
      expect(result.profit, 5.0);
    });

    test('Example 7: 100g of 1kg pack', () {
      final result = PricingCalculator.calculateTransaction(
        packetWeightKg: 1.0,
        costPerKg: 50.0,
        sellingRatePerKg: 55.0,
        mrpPerKg: 54.0,
        saleAmountRaw: '100g',
      );
      expect(result.unitPriceUsed, 55.0);
      expect(result.sellPrice, 5.5);
      expect(result.costPrice, 5.0);
      expect(result.profit, 0.5);
    });

    test('Example 8: 1.25kg of 5kg pack', () {
      final result = PricingCalculator.calculateTransaction(
        packetWeightKg: 5.0,
        costPerKg: 110.0,
        sellingRatePerKg: 130.0,
        mrpPerKg: 125.0,
        saleAmountRaw: '1.25kg',
      );
      expect(result.unitPriceUsed, 130.0);
      expect(result.sellPrice, 162.5);
      expect(result.costPrice, 137.5);
      expect(result.profit, 25.0);
    });

    test('Example 9: 2kg of 20kg pack', () {
      final result = PricingCalculator.calculateTransaction(
        packetWeightKg: 20.0,
        costPerKg: 40.0,
        sellingRatePerKg: 45.0,
        mrpPerKg: 42.0,
        saleAmountRaw: '2kg',
      );
      expect(result.unitPriceUsed, 45.0);
      expect(result.sellPrice, 90.0);
      expect(result.costPrice, 80.0);
      expect(result.profit, 10.0);
    });

    test('Example 10: 4999g of 5kg pack', () {
      final result = PricingCalculator.calculateTransaction(
        packetWeightKg: 5.0,
        costPerKg: 100.0,
        sellingRatePerKg: 110.0,
        mrpPerKg: 105.0,
        saleAmountRaw: '4999g',
      );
      expect(result.unitPriceUsed, 110.0);
      expect(result.sellPrice, 549.89);
      expect(result.costPrice, 499.9);
      expect(result.profit, 49.99);
    });

    test('Example 11: 5000g of 5kg pack (Full)', () {
      final result = PricingCalculator.calculateTransaction(
        packetWeightKg: 5.0,
        costPerKg: 100.0,
        sellingRatePerKg: 110.0,
        mrpPerKg: 105.0,
        saleAmountRaw: '5000g',
      );
      expect(result.unitPriceUsed, 105.0);
      expect(result.sellPrice, 525.0);
      expect(result.costPrice, 500.0);
      expect(result.profit, 25.0);
    });

    test('Example 12: 2500g of 5kg pack', () {
      final result = PricingCalculator.calculateTransaction(
        packetWeightKg: 5.0,
        costPerKg: 200.0,
        sellingRatePerKg: 220.0,
        mrpPerKg: 215.0,
        saleAmountRaw: '2500g',
      );
      expect(result.unitPriceUsed, 220.0);
      expect(result.sellPrice, 550.0);
      expect(result.costPrice, 500.0);
      expect(result.profit, 50.0);
    });

    test('Example 13: 3kg of 3kg pack (Full)', () {
      final result = PricingCalculator.calculateTransaction(
        packetWeightKg: 3.0,
        costPerKg: 120.0,
        sellingRatePerKg: 125.0,
        mrpPerKg: 123.0,
        saleAmountRaw: '3kg',
      );
      expect(result.unitPriceUsed, 123.0);
      expect(result.sellPrice, 369.0);
      expect(result.costPrice, 360.0);
      expect(result.profit, 9.0);
    });

    test('Example 14: 3.5kg of 7kg pack', () {
      final result = PricingCalculator.calculateTransaction(
        packetWeightKg: 7.0,
        costPerKg: 65.0,
        sellingRatePerKg: 75.0,
        mrpPerKg: 70.0,
        saleAmountRaw: '3.5kg',
      );
      expect(result.unitPriceUsed, 75.0);
      expect(result.sellPrice, 262.5);
      expect(result.costPrice, 227.5);
      expect(result.profit, 35.0);
    });

    test('Example 15: 250g of 2.5kg pack', () {
      final result = PricingCalculator.calculateTransaction(
        packetWeightKg: 2.5,
        costPerKg: 150.0,
        sellingRatePerKg: 160.0,
        mrpPerKg: 155.0,
        saleAmountRaw: '250g',
      );
      expect(result.unitPriceUsed, 160.0);
      expect(result.sellPrice, 40.0);
      expect(result.costPrice, 37.5);
      expect(result.profit, 2.5);
    });

    test('Example 16: 0g of 4kg pack', () {
      final result = PricingCalculator.calculateTransaction(
        packetWeightKg: 4.0,
        costPerKg: 90.0,
        sellingRatePerKg: 100.0,
        mrpPerKg: 95.0,
        saleAmountRaw: '0g',
      );
      expect(result.unitPriceUsed, 100.0);
      expect(result.sellPrice, 0.0);
      expect(result.costPrice, 0.0);
      expect(result.profit, 0.0);
    });

    test('Example 17: 6000g of 6kg pack (Full)', () {
      final result = PricingCalculator.calculateTransaction(
        packetWeightKg: 6.0,
        costPerKg: 85.0,
        sellingRatePerKg: 95.0,
        mrpPerKg: 90.0,
        saleAmountRaw: '6000g',
      );
      expect(result.unitPriceUsed, 90.0);
      expect(result.sellPrice, 540.0);
      expect(result.costPrice, 510.0);
      expect(result.profit, 30.0);
    });

    test('Example 18: 250g of 0.5kg pack', () {
      final result = PricingCalculator.calculateTransaction(
        packetWeightKg: 0.5,
        costPerKg: 300.0,
        sellingRatePerKg: 350.0,
        mrpPerKg: 330.0,
        saleAmountRaw: '250g',
      );
      expect(result.unitPriceUsed, 350.0);
      expect(result.sellPrice, 87.5);
      expect(result.costPrice, 75.0);
      expect(result.profit, 12.5);
    });

    test('Example 19: 1.5kg of 12kg pack', () {
      final result = PricingCalculator.calculateTransaction(
        packetWeightKg: 12.0,
        costPerKg: 55.0,
        sellingRatePerKg: 60.0,
        mrpPerKg: 58.0,
        saleAmountRaw: '1.5kg',
      );
      expect(result.unitPriceUsed, 60.0);
      expect(result.sellPrice, 90.0);
      expect(result.costPrice, 82.5);
      expect(result.profit, 7.5);
    });

    test('Example 20: 3.333kg of 5kg pack', () {
      final result = PricingCalculator.calculateTransaction(
        packetWeightKg: 5.0,
        costPerKg: 100.0,
        sellingRatePerKg: 110.0,
        mrpPerKg: 105.0,
        saleAmountRaw: '3.333kg',
      );
      expect(result.unitPriceUsed, 110.0);
      expect(result.sellPrice, 366.63);
      expect(result.costPrice, 333.3);
      expect(result.profit, 33.33);
    });
  });
}
