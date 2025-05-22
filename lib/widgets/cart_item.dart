import 'package:qwicky/models/service_model.dart';

class CartItem {
  final ServiceModel service;
  final int quantity;

  CartItem({required this.service, required this.quantity});
}