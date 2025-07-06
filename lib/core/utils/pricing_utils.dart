import 'package:iskxpress/core/models/product_model.dart';
import 'package:iskxpress/core/models/user_model.dart';

class PricingUtils {
  /// Get the appropriate price for a product based on user premium status
  static double getPriceForUser(ProductModel product, UserModel? user) {
    if (user?.premium == true) {
      return product.premiumPrice;
    }
    return product.priceWithMarkup ?? product.sellingPrice;
  }

  /// Calculate the regular price (non-premium price)
  static double getRegularPrice(ProductModel product) {
    return product.priceWithMarkup ?? product.sellingPrice;
  }

  /// Calculate the premium price (10% off regular price)
  static double getPremiumPrice(ProductModel product) {
    return product.premiumPrice;
  }

  /// Calculate savings amount for premium users
  static double calculateSavings(ProductModel product) {
    final regularPrice = getRegularPrice(product);
    final premiumPrice = getPremiumPrice(product);
    return regularPrice - premiumPrice;
  }

  /// Calculate savings percentage for premium users
  static double calculateSavingsPercentage(ProductModel product) {
    final regularPrice = getRegularPrice(product);
    final savings = calculateSavings(product);
    return (savings / regularPrice) * 100;
  }

  /// Calculate total savings for a list of products
  static double calculateTotalSavings(List<ProductModel> products, List<int> quantities) {
    double totalSavings = 0;
    for (int i = 0; i < products.length; i++) {
      totalSavings += calculateSavings(products[i]) * quantities[i];
    }
    return totalSavings;
  }

  /// Calculate total price for a list of products with quantities
  static double calculateTotalPrice(List<ProductModel> products, List<int> quantities, UserModel? user) {
    double total = 0;
    for (int i = 0; i < products.length; i++) {
      total += getPriceForUser(products[i], user) * quantities[i];
    }
    return total;
  }

  /// Calculate regular total price (non-premium)
  static double calculateRegularTotalPrice(List<ProductModel> products, List<int> quantities) {
    double total = 0;
    for (int i = 0; i < products.length; i++) {
      total += getRegularPrice(products[i]) * quantities[i];
    }
    return total;
  }

  /// Calculate delivery fee (0 for premium users, ₱10 per unique stall for regular users)
  static double calculateDeliveryFee(List<int> stallIds, UserModel? user) {
    if (user?.premium == true) {
      return 0; // Free delivery for premium users
    }
    final uniqueStalls = stallIds.toSet();
    return uniqueStalls.length * 10; // ₱10 per unique stall
  }

  /// Calculate total savings including delivery fee
  static double calculateTotalSavingsWithDelivery(
    List<ProductModel> products, 
    List<int> quantities, 
    List<int> stallIds,
    UserModel? user
  ) {
    final productSavings = calculateTotalSavings(products, quantities);
    final deliverySavings = user?.premium == true ? calculateDeliveryFee(stallIds, null) : 0;
    return productSavings + deliverySavings;
  }
} 