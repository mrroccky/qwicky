import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qwicky/models/service_model.dart';

part 'service_event.dart';
part 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  ServiceBloc() : super(ServiceInitial()) {
    on<LoadServices>(_onLoadServices);
  }

  Future<void> _onLoadServices(LoadServices event, Emitter<ServiceState> emit) async {
    print('ServiceBloc: Loading services...');
    emit(ServiceLoading());
    try {
      // Dummy data with serviceType as Domestic, Commercial, Corporate
      final services = [
        ServiceModel(
          serviceId: 1,
          title: 'Home Cleaning',
          description: 'Deep cleaning\nSanitization\nEco-friendly products',
          image: 'assets/cleaning.jpg',
          serviceType: 'Domestic',
          serviceDuration: '2 hours',
          price: 55.0,
          isActive: true,
          createdAt: DateTime.now(),
          categoryId: 1,
        ),
        ServiceModel(
          serviceId: 2,
          title: 'Plumbing',
          description: 'Leak repair\nPipe installation\nDrain cleaning',
          image: 'assets/plumbing.jpg',
          serviceType: 'Domestic',
          serviceDuration: '3 hours',
          price: 80.0,
          isActive: true,
          createdAt: DateTime.now(),
          categoryId: 2,
        ),
        ServiceModel(
          serviceId: 3,
          title: 'Office Cleaning',
          description: 'Commercial space cleaning\nCarpet cleaning\nWindow washing',
          image: 'assets/office_cleaning.jpg',
          serviceType: 'Commercial',
          serviceDuration: '4 hours',
          price: 120.0,
          isActive: true,
          createdAt: DateTime.now(),
          categoryId: 3,
        ),
        ServiceModel(
          serviceId: 4,
          title: 'Corporate IT Setup',
          description: 'Network setup\nHardware installation\nSecurity systems',
          image: 'assets/it_setup.jpg',
          serviceType: 'Corporate',
          serviceDuration: '5 hours',
          price: 200.0,
          isActive: true,
          createdAt: DateTime.now(),
          categoryId: 4,
        ),
      ];
      print('ServiceBloc: Emitting ServiceLoaded with ${services.length} services');
      emit(ServiceLoaded(services));
    } catch (e) {
      print('ServiceBloc: Error loading services: $e');
      emit(ServiceError('Failed to load services'));
    }
  }
}