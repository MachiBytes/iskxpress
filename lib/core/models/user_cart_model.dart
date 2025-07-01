import 'cart_item_model.dart';

class UserCartModel {
  final List<CartItemModel> items;

  UserCartModel({required this.items});

  factory UserCartModel.fromJson(List<dynamic> jsonList) {
    return UserCartModel(
      items: jsonList.map((json) => CartItemModel.fromJson(json)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  // Group items by stallId
  Map<int, List<CartItemModel>> get itemsByStall {
    final map = <int, List<CartItemModel>>{};
    for (final item in items) {
      map.putIfAbsent(item.stallId, () => []).add(item);
    }
    return map;
  }
} 