import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qwicky/models/service_model.dart';
import 'package:http/http.dart' as http;
import 'package:qwicky/widgets/cart_item.dart';
import 'dart:convert';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitial()) {
    on<AddServiceToCart>(_onAddServiceToCart);
    on<RemoveServiceFromCart>(_onRemoveServiceFromCart);
    on<LoadCartFromBackend>(_onLoadCartFromBackend);
  }

  Future<void> _onAddServiceToCart(AddServiceToCart event, Emitter<CartState> emit) async {
    final currentState = state;
    final uniqueKey = '${event.service.serviceId}_${DateTime.now().millisecondsSinceEpoch}';

    if (event.service.serviceId == null) {
      print('CartBloc: Error - Service ID is null for service: ${event.service.title}');
      emit(const CartError('Cannot add service to cart: Service ID is missing'));
      return;
    }

    List<int>? updatedServiceItemsId;
    try {
      updatedServiceItemsId = await _updateServiceItemsId(event.service.serviceId!, userId: event.userId, add: true);
      print('CartBloc: Updated service_items_id after add: $updatedServiceItemsId');
    } catch (e, stackTrace) {
      print('CartBloc: Error updating service_items_id on add: $e');
      print('Stack trace: $stackTrace');
      emit(CartError('Failed to add item to cart: $e. Please try logging in again.'));
      return;
    }

    if (currentState is CartLoaded) {
      final updatedItems = List<MapEntry<String, CartItem>>.from(currentState.items);
      final existingIndex = updatedItems.indexWhere((item) => item.value.service.serviceId == event.service.serviceId);
      if (existingIndex != -1) {
        final existingItem = updatedItems[existingIndex];
        updatedItems[existingIndex] = MapEntry(
          existingItem.key,
          CartItem(
            service: existingItem.value.service,
            quantity: existingItem.value.quantity + 1,
          ),
        );
        print('CartBloc: Incremented quantity for service ID ${event.service.serviceId} (quantity: ${updatedItems[existingIndex].value.quantity})');
      } else {
        updatedItems.add(MapEntry(uniqueKey, CartItem(service: event.service, quantity: 1)));
        print('CartBloc: Added service ID ${event.service.serviceId} to cart (unique key: $uniqueKey, quantity: 1)');
      }
      print('CartBloc: Current cart items: ${updatedItems.map((e) => "${e.value.service.serviceId} (x${e.value.quantity})").toList()}');
      emit(CartLoaded(updatedItems));
    } else {
      print('CartBloc: Added service ID ${event.service.serviceId} to cart (unique key: $uniqueKey, quantity: 1)');
      print('CartBloc: Current cart items: [${event.service.serviceId} (x1)]');
      emit(CartLoaded([MapEntry(uniqueKey, CartItem(service: event.service, quantity: 1))]));
    }
  }

  Future<void> _onRemoveServiceFromCart(RemoveServiceFromCart event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      final updatedItems = List<MapEntry<String, CartItem>>.from(currentState.items);
      final index = updatedItems.indexWhere((item) => item.key == event.uniqueKey);
      if (index != -1) {
        final cartItem = updatedItems[index].value;
        final serviceId = cartItem.service.serviceId;
        if (serviceId == null) {
          print('CartBloc: Error - Service ID is null for item with unique key: ${event.uniqueKey}');
          emit(const CartError('Cannot remove service from cart: Service ID is missing'));
          return;
        }

        List<int>? updatedServiceItemsId;
        try {
          updatedServiceItemsId = await _updateServiceItemsId(serviceId, userId: event.userId, add: false);
          print('CartBloc: Updated service_items_id after remove: $updatedServiceItemsId');
        } catch (e, stackTrace) {
          print('CartBloc: Error updating service_items_id on remove: $e');
          print('Stack trace: $stackTrace');
          emit(CartError('Failed to remove item from cart: $e. Please try logging in again.'));
          return;
        }

        if (cartItem.quantity > 1) {
          updatedItems[index] = MapEntry(
            updatedItems[index].key,
            CartItem(
              service: cartItem.service,
              quantity: cartItem.quantity - 1,
            ),
          );
          print('CartBloc: Decreased quantity for service ID $serviceId (quantity: ${updatedItems[index].value.quantity})');
        } else {
          updatedItems.removeAt(index);
          print('CartBloc: Removed service ID $serviceId from cart (unique key: ${event.uniqueKey})');
        }
        print('CartBloc: Current cart items: ${updatedItems.map((e) => "${e.value.service.serviceId} (x${e.value.quantity})").toList()}');
        emit(CartLoaded(updatedItems));
      }
    }
  }

  Future<void> _onLoadCartFromBackend(LoadCartFromBackend event, Emitter<CartState> emit) async {
    final services = event.services;
    final Map<int, int> serviceQuantities = {};
    for (var service in services) {
      if (service.serviceId != null) {
        serviceQuantities[service.serviceId!] = (serviceQuantities[service.serviceId!] ?? 0) + 1;
      }
    }

    final cartItems = serviceQuantities.entries.map((entry) {
      final service = services.firstWhere((s) => s.serviceId == entry.key);
      final uniqueKey = '${service.serviceId}_${DateTime.now().millisecondsSinceEpoch}';
      return MapEntry(uniqueKey, CartItem(service: service, quantity: entry.value));
    }).toList();

    print('CartBloc: Loaded cart from backend with items: ${cartItems.map((e) => "${e.value.service.serviceId} (x${e.value.quantity})").toList()}');
    emit(CartLoaded(cartItems));
  }

  Future<List<int>> _updateServiceItemsId(int serviceId, {required String userId, required bool add}) async {
    String baseUrl = dotenv.env['BACK_END_API'] ?? 'http://192.168.1.37:3000/api';

    print('CartBloc: Attempting to fetch user data with userId: $userId');

    if (userId.isEmpty) {
      throw Exception('User ID is empty. Please log in again.');
    }

    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/users/$userId'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to fetch user data: ${response.statusCode} - ${response.body}');
        }

        final userData = jsonDecode(response.body);
        List<int> serviceItemsId = [];
        try {
          serviceItemsId = userData['service_items_id'] != null
              ? List<int>.from(jsonDecode(userData['service_items_id']))
              : [];
        } catch (e) {
          throw Exception('Failed to parse service_items_id: $e');
        }

        if (add) {
          serviceItemsId.add(serviceId);
        } else {
          serviceItemsId.remove(serviceId);
        }

        final updateResponse = await http.put(
          Uri.parse('$baseUrl/users/$userId'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'service_items_id': jsonEncode(serviceItemsId)}),
        );

        if (updateResponse.statusCode != 200) {
          throw Exception('Failed to update service_items_id: ${updateResponse.statusCode} - ${updateResponse.body}');
        }

        return serviceItemsId;
      } catch (e) {
        print('CartBloc: Attempt $attempt failed to update service_items_id: $e');
        if (attempt == 3) {
          throw Exception('Failed to update service_items_id after 3 attempts: $e');
        }
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }

    throw Exception('Unexpected error in _updateServiceItemsId');
  }
}