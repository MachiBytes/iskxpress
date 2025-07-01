import 'dart:io';
import '../models/stall_model.dart';
import '../models/product_model.dart';
import '../models/section_model.dart';
import '../models/category_model.dart';

// Import the new specialized API services
import 'user_api_service.dart';
import 'stall_api_service.dart';
import 'product_api_service.dart';
import 'section_api_service.dart';
import 'category_api_service.dart';

/// Facade class that delegates to specialized API services
/// This maintains backward compatibility while organizing code better
class ApiService {
  // ============== USER ENDPOINTS ==============
  
  /// Sync users endpoint
  static Future<bool> syncUsers() => UserApiService.syncUsers();

  /// Check if user exists by email
  static Future<Map<String, dynamic>?> getUserByEmail(String email) => 
      UserApiService.getUserByEmail(email);

  /// Create new user
  static Future<Map<String, dynamic>?> createUser({
    required String name,
    required String email,
    required int authProvider,
  }) => UserApiService.createUser(
        name: name,
        email: email,
        authProvider: authProvider,
      );

  /// Get user by ID
  static Future<Map<String, dynamic>?> getUserById(int userId) => 
      UserApiService.getUserById(userId);

  // ============== STALL ENDPOINTS ==============

  /// Get all stalls
  static Future<List<StallModel>> getStalls() => 
      StallApiService.getStalls();

  /// Get stalls for a vendor
  static Future<StallModel?> getStallByVendorId(int vendorId) => 
      StallApiService.getStallByVendorId(vendorId);

  /// Create new stall (updated request body format)
  static Future<StallModel?> createStall({
    required int vendorId,
    required String name,
    required String shortDescription,
  }) => StallApiService.createStall(
        vendorId: vendorId,
        name: name,
        shortDescription: shortDescription,
      );

  /// Update stall information
  static Future<StallModel?> updateStall({
    required int stallId,
    required String name,
    required String shortDescription,
  }) => StallApiService.updateStall(
        stallId: stallId,
        name: name,
        shortDescription: shortDescription,
      );

  /// Upload stall picture
  static Future<bool> uploadStallPicture({
    required int stallId,
    required File imageFile,
  }) => StallApiService.uploadStallPicture(
        stallId: stallId,
        imageFile: imageFile,
      );

  // ============== PRODUCT ENDPOINTS ==============

  /// Get products for a stall
  static Future<List<ProductModel>> getStallProducts(int stallId) => 
      ProductApiService.getStallProducts(stallId);

  /// Create new product (updated request body format)
  static Future<ProductModel?> createProduct({
    required int stallId,
    required String name,
    required double basePrice,
    required int sectionId,
    int? categoryId,
  }) => ProductApiService.createProduct(
        stallId: stallId,
        name: name,
        basePrice: basePrice,
        sectionId: sectionId,
        categoryId: categoryId,
      );

  /// Update product
  static Future<ProductModel?> updateProduct({
    required int productId,
    required String name,
    required double basePrice,
    required int sectionId,
    int? categoryId,
  }) => ProductApiService.updateProduct(
        productId: productId,
        name: name,
        basePrice: basePrice,
        sectionId: sectionId,
        categoryId: categoryId,
      );

  /// Delete product
  static Future<bool> deleteProduct(int productId) => 
      ProductApiService.deleteProduct(productId);

  /// Upload product picture
  static Future<bool> uploadProductPicture({
    required int productId,
    required File imageFile,
  }) => ProductApiService.uploadProductPicture(
        productId: productId,
        imageFile: imageFile,
      );

  // ============== SECTION ENDPOINTS ==============

  /// Get sections for a stall
  static Future<List<SectionModel>> getStallSections(int stallId) => 
      SectionApiService.getStallSections(stallId);

  /// Create new section
  static Future<SectionModel?> createSection({
    required int stallId,
    required String name,
  }) => SectionApiService.createSection(
        stallId: stallId,
        name: name,
      );

  /// Update section
  static Future<SectionModel?> updateSection({
    required int sectionId,
    required String name,
  }) => SectionApiService.updateSection(
        sectionId: sectionId,
        name: name,
      );

  /// Delete section
  static Future<bool> deleteSection(int sectionId) => 
      SectionApiService.deleteSection(sectionId);

  // ============== CATEGORY ENDPOINTS ==============

  /// Get all categories
  static Future<List<CategoryModel>> getCategories() => 
      CategoryApiService.getCategories();
} 