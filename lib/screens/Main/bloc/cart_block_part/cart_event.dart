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
  final ServiceModel service;

  const RemoveServiceFromCart(this.service);

  @override
  List<Object> get props => [service];
}