part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class AddServiceToCart extends CartEvent {
  final ServiceModel service;

  const AddServiceToCart(this.service);

  @override
  List<Object> get props => [service];
}

class RemoveServiceFromCart extends CartEvent {
  final String uniqueKey;

  const RemoveServiceFromCart(this.uniqueKey);

  @override
  List<Object> get props => [uniqueKey];
}

class LoadCartFromBackend extends CartEvent {
  final List<ServiceModel> services;

  const LoadCartFromBackend(this.services);

  @override
  List<Object> get props => [services];
}