class ServiceModel{
  final int? serviceId;
  final String title;
  final String description;
  final String? serviceType;
  final String? serviceDuration;
  final double? price;
  final bool? isActive;
  final DateTime? createdAt;
  final int? categoryId;
  final String image; // Added for UI display

  ServiceModel({
    this.serviceId,
    required this.title,
    required this.description,
    this.serviceType,
    this.serviceDuration,
    this.price,
    this.isActive,
    this.createdAt,
    this.categoryId,
    required this.image,
  });

  // Helper to split description into bullet points
  List<String> get descriptionPoints => description.split('\n').where((point) => point.isNotEmpty).toList();

  @override
  List<Object?> get props => [serviceId, title, description, image];

  @override
  bool get stringify => true;
}