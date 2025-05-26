import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
      // Get the API URL from .env
      final String apiUrl = dotenv.env['BACK_END_API'] ?? 'http://192.168.1.37:3000/api';
      final response = await http.get(Uri.parse('$apiUrl/services'));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final List<dynamic> jsonData = jsonDecode(response.body);
        final services = jsonData.map((json) {
          // Parse the description field which is a JSON string containing an array
          List<dynamic> descriptionList = [];
          try {
            descriptionList = jsonDecode(json['description'] as String);
          } catch (e) {
            // If parsing fails, treat as single string
            descriptionList = [json['description'] as String];
          }
          
          return ServiceModel(
            serviceId: json['service_id'] as int,
            title: json['service_title'] as String,
            description: descriptionList.join('\n'),
            image: json['service_image'] as String,
            serviceType: json['service_type'] as String,
            serviceDuration: json['service_duration'] as String,
            price: double.parse(json['service_price'] as String),
            isActive: (json['is_active'] as int) == 1,
            createdAt: DateTime.parse(json['created_at'] as String),
            categoryId: json['category_id'] as String,
          );
        }).toList();

        print('ServiceBloc: Emitting ServiceLoaded with ${services.length} services');
        emit(ServiceLoaded(services));
      } else {
        print('ServiceBloc: Failed to load services, status code: ${response.statusCode}');
        emit(ServiceError('Failed to load services: ${response.statusCode}'));
      }
    } catch (e) {
      print('ServiceBloc: Error loading services: $e');
      emit(ServiceError('Failed to load services: $e'));
    }
  }
}