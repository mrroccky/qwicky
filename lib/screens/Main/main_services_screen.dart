import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qwicky/screens/Main/bloc/service_part/service_bloc.dart';
import 'package:qwicky/widgets/app_bart.dart';
import 'package:qwicky/widgets/service_card.dart';

class MainServicesScreen extends StatefulWidget {
  final String address;
  final String serviceType;
  final String city; // Add city parameter

  const MainServicesScreen({
    super.key,
    required this.address,
    required this.serviceType,
    required this.city, // Require city
  });

  @override
  State<MainServicesScreen> createState() => _MainServicesScreenState();
}

class _MainServicesScreenState extends State<MainServicesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ServiceBloc>().add(LoadServices());
  }

  // Helper method to get category ID based on service type
  String getCategoryId(String serviceType) {
    switch (serviceType) {
      case 'Domestic':
        return '1';
      case 'Commercial':
        return '2';
      case 'Corporate':
        return '3';
      case 'Extended':
        return '4';
      case 'Quick':
        return '5';
      default:
        return '1'; // Default to Domestic
    }
  }

  @override
  Widget build(BuildContext context) {
    String title;
    switch (widget.serviceType) {
      case 'Domestic':
        title = 'Domestic Services';
        break;
      case 'Commercial':
        title = 'Commercial Services';
        break;
      case 'Corporate':
        title = 'Corporate Services';
        break;
      case 'Extended':
        title = 'Extended Services';
        break;
      case 'Quick':
        title = 'Quick Services';
        break;
      default:
        title = 'Services';
    }

    return Scaffold(
      appBar: CustomAppBar(
        address: widget.address,
        isBackButtonVisible: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<ServiceBloc, ServiceState>(
              builder: (context, state) {
                if (state is ServiceLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ServiceLoaded) {
                  // Filter services by category_id
                  final targetCategoryId = getCategoryId(widget.serviceType);
                  var filteredServices = state.services
                      .where((service) => service.categoryId == targetCategoryId)
                      .toList();

                  // Further filter by location
                  filteredServices = filteredServices.where((service) {
                    // If service location is null or empty, show the service
                    if (service.location == null || service.location!.isEmpty) {
                      return true;
                    }
                    // Otherwise, only show if the service's location matches the user's city
                    return service.location!.toLowerCase() == widget.city.toLowerCase();
                  }).toList();

                  if (filteredServices.isEmpty) {
                    return const Center(child: Text('No services available for this category or location'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = filteredServices[index];
                      return ServiceCard(service: service);
                    },
                  );
                } else if (state is ServiceError) {
                  return Center(child: Text(state.message));
                }
                return const Center(child: Text('No services available'));
              },
            ),
          ),
        ],
      ),
    );
  }
}