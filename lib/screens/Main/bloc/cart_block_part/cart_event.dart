part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class AddServiceToCart extends CartEvent {
  final ServiceModel service;
  final String userId; // Add userId

  const AddServiceToCart(this.service, this.userId);

  @override
  List<Object> get props => [service, userId];
}

class RemoveServiceFromCart extends CartEvent {
  final String uniqueKey;
  final String userId; // Add userId

  const RemoveServiceFromCart(this.uniqueKey, this.userId);

  @override
  List<Object> get props => [uniqueKey, userId];
}

class LoadCartFromBackend extends CartEvent {
  final List<ServiceModel> services;

  const LoadCartFromBackend(this.services);

  @override
  List<Object> get props => [services];
}