import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qwicky/models/service_model.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitial()) {
    on<AddServiceToCart>(_onAddServiceToCart);
    on<RemoveServiceFromCart>(_onRemoveServiceFromCart);
  }

  Future<void> _onAddServiceToCart(AddServiceToCart event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      final updatedItems = List<MapEntry<ServiceModel, int>>.from(currentState.items);
      // Check if service already exists
      final existingIndex = updatedItems.indexWhere((item) => item.key.serviceId == event.service.serviceId);
      if (existingIndex != -1) {
        // Increment quantity
        updatedItems[existingIndex] = MapEntry(
          updatedItems[existingIndex].key,
          updatedItems[existingIndex].value + 1,
        );
      } else {
        // Add new service with quantity 1
        updatedItems.add(MapEntry(event.service, 1));
      }
      emit(CartLoaded(updatedItems));
    } else {
      // Initialize with one service
      emit(CartLoaded([MapEntry(event.service, 1)]));
    }
  }

  Future<void> _onRemoveServiceFromCart(RemoveServiceFromCart event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is CartLoaded) {
      final updatedItems = List<MapEntry<ServiceModel, int>>.from(currentState.items);
      final existingIndex = updatedItems.indexWhere((item) => item.key.serviceId == event.service.serviceId);
      if (existingIndex != -1) {
        final currentQuantity = updatedItems[existingIndex].value;
        if (currentQuantity > 1) {
          // Decrement quantity
          updatedItems[existingIndex] = MapEntry(
            updatedItems[existingIndex].key,
            currentQuantity - 1,
          );
        } else {
          // Remove service entirely
          updatedItems.removeAt(existingIndex);
        }
        emit(CartLoaded(updatedItems));
      }
    }
  }
}