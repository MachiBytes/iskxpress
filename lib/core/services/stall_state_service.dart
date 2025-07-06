import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/stall_model.dart';
import 'api_service.dart';

class StallStateService with ChangeNotifier {
  static final StallStateService _instance = StallStateService._internal();
  factory StallStateService() => _instance;
  StallStateService._internal();

  StallModel? _currentStall;
  bool _isLoading = false;

  StallModel? get currentStall => _currentStall;
  bool get isLoading => _isLoading;

  // Load stall data for the current vendor
  Future<void> loadStallForVendor(int vendorId) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (kDebugMode) debugPrint('StallStateService: Loading stall for vendor $vendorId');
      final stall = await ApiService.getStallByVendorId(vendorId);
      
      if (stall != null) {
        _currentStall = stall;
        if (kDebugMode) debugPrint('StallStateService: Successfully loaded stall: ${stall.name}');
      } else {
        if (kDebugMode) debugPrint('StallStateService: No stall found for vendor');
        _currentStall = null;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('StallStateService: Error loading stall: $e');
      _currentStall = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Update stall information (name and description)
  Future<bool> updateStallInfo({
    required String name,
    required String shortDescription,
  }) async {
    if (_currentStall == null) {
      if (kDebugMode) debugPrint('StallStateService: Cannot update stall - no current stall');
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      if (kDebugMode) debugPrint('StallStateService: Updating stall ${_currentStall!.id}');
      final updatedStall = await ApiService.updateStall(
        stallId: _currentStall!.id,
        name: name,
        shortDescription: shortDescription,
      );

      if (updatedStall != null) {
        _currentStall = updatedStall;
        if (kDebugMode) debugPrint('StallStateService: Successfully updated stall');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        if (kDebugMode) debugPrint('StallStateService: Failed to update stall');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('StallStateService: Error updating stall: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update delivery availability
  Future<bool> updateDeliveryAvailability(bool hasDelivery) async {
    if (_currentStall == null) {
      if (kDebugMode) debugPrint('StallStateService: Cannot update delivery availability - no current stall');
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      if (kDebugMode) debugPrint('StallStateService: Updating delivery availability for stall ${_currentStall!.id} to $hasDelivery');
      final updatedStall = await ApiService.updateStallDeliveryAvailability(
        stallId: _currentStall!.id,
        hasDelivery: hasDelivery,
      );

      if (updatedStall != null) {
        _currentStall = updatedStall;
        if (kDebugMode) debugPrint('StallStateService: Successfully updated delivery availability');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        if (kDebugMode) debugPrint('StallStateService: Failed to update delivery availability');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('StallStateService: Error updating delivery availability: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update stall picture
  Future<bool> updateStallPicture(File imageFile) async {
    if (_currentStall == null) {
      if (kDebugMode) debugPrint('StallStateService: Cannot update picture - no current stall');
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      if (kDebugMode) debugPrint('StallStateService: Uploading picture for stall ${_currentStall!.id}');
      final success = await ApiService.uploadStallPicture(
        stallId: _currentStall!.id,
        imageFile: imageFile,
      );

      if (success) {
        // Reload stall data to get the updated picture URL
        await loadStallForVendor(_currentStall!.vendorId);
        if (kDebugMode) debugPrint('StallStateService: Successfully updated stall picture');
        return true;
      } else {
        if (kDebugMode) debugPrint('StallStateService: Failed to update stall picture');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('StallStateService: Error updating stall picture: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear stall data (e.g., on logout)
  void clearStall() {
    _currentStall = null;
    _isLoading = false;
    notifyListeners();
    if (kDebugMode) debugPrint('StallStateService: Cleared stall data');
  }

  // Create new stall
  Future<bool> createStall({
    required int vendorId,
    required String name,
    required String shortDescription,
    bool hasDelivery = false,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (kDebugMode) debugPrint('StallStateService: Creating stall for vendor $vendorId');
      final newStall = await ApiService.createStall(
        vendorId: vendorId,
        name: name,
        shortDescription: shortDescription,
        hasDelivery: hasDelivery,
      );

      if (newStall != null) {
        _currentStall = newStall;
        
        // If delivery availability is requested, update it separately
        if (hasDelivery) {
          final deliverySuccess = await updateDeliveryAvailability(hasDelivery);
          if (!deliverySuccess) {
            if (kDebugMode) debugPrint('StallStateService: Failed to set delivery availability after stall creation');
          }
        }
        
        if (kDebugMode) debugPrint('StallStateService: Successfully created stall: ${newStall.name}');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        if (kDebugMode) debugPrint('StallStateService: Failed to create stall');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('StallStateService: Error creating stall: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Refresh stall data
  Future<void> refreshStall() async {
    if (_currentStall != null) {
      await loadStallForVendor(_currentStall!.vendorId);
    }
  }
} 