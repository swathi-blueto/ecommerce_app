import 'package:flutter/material.dart';
class ActionProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _wishlist = [];

  List<Map<String, dynamic>> get wishlist => _wishlist;

  void addToWishlist(Map<String, dynamic> watch) {
    if (!_wishlist.any((item) => item['id'] == watch['id'])) {
      _wishlist.add(watch);
      notifyListeners();
    }
  }

  void removeFromWishlist(Map<String, dynamic> watch) {
    _wishlist.removeWhere((item) => item['id'] == watch['id']);
    notifyListeners();
  }

  bool isInWishlist(Map<String, dynamic> watch) {
    return _wishlist.any((item) => item['id'] == watch['id']);
  }
}