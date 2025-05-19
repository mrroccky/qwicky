part of 'cart_bloc.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

class CartInitial extends CartState {}

class CartLoaded extends CartState {
  final List<MapEntry<ServiceModel, int>> items; // Service and quantity

  const CartLoaded(this.items);

  @override
  List<Object> get props => [items];
}