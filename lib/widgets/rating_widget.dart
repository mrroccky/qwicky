import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RatingWidget extends StatefulWidget {
  final int bookingId;
  final int userId;
  final int targetId;
  final int serviceId; // Added for professional review
  final String targetType; // "service" or "professional"
  final Function(String reviewId, int rating)? onRatingSubmitted;

  const RatingWidget({
    super.key,
    required this.bookingId,
    required this.userId,
    required this.targetId,
    required this.serviceId,
    required this.targetType,
    this.onRatingSubmitted,
  });

  @override
  State<RatingWidget> createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  int? _currentRating;
  String? _reviewId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchExistingReview();
  }

  Future<void> _fetchExistingReview() async {
    try {
      final String apiUrl = dotenv.env['BACK_END_API'] ?? 'http://192.168.1.37:3000/api';
      final String endpoint = widget.targetType == 'service' ? 'servicereview' : 'user-review-prof';
      final response = await http.get(
        Uri.parse('$apiUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Fetching ${widget.targetType} review for targetId: ${widget.targetId}, userId: ${widget.userId}, bookingId: ${widget.bookingId}');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> reviews = jsonDecode(response.body);
        final review = reviews.firstWhere(
          (r) =>
              r[widget.targetType == 'service' ? 'service_id' : 'professional_id'] == widget.targetId &&
              r['user_id'] == widget.userId &&
              (widget.targetType == 'professional' ? r['booking_id'] == widget.bookingId : true),
          orElse: () => null,
        );
        if (review != null && mounted) {
          setState(() {
            _currentRating = review['rating'] as int;
            _reviewId = review[widget.targetType == 'service' ? 'service_review_id' : 'review_id'] as String;
          });
          print('Found ${widget.targetType} review: rating=$_currentRating, reviewId=$_reviewId');
        }
      } else {
        print('Failed to fetch ${widget.targetType} review: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ${widget.targetType} review: $e');
    }
  }

  Future<void> _submitRating(int rating) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _currentRating = rating; // Optimistic UI update
    });

    try {
      final String apiUrl = dotenv.env['BACK_END_API'] ?? 'http://192.168.1.37:3000/api';
      final String endpoint = widget.targetType == 'service' ? 'servicereview' : 'user-review-prof';
      Map<String, dynamic> body;

      if (widget.targetType == 'service') {
        body = {
          'service_id': widget.targetId,
          'user_id': widget.userId,
          'professional_id': widget.targetId == widget.serviceId ? widget.targetId : widget.serviceId, // Use serviceId as professional_id if needed
          'rating': rating,
          'comment': '',
        };
      } else {
        body = {
          'service_id': widget.serviceId,
          'user_id': widget.userId,
          'professional_id': widget.targetId,
          'booking_id': widget.bookingId,
          'rating': rating,
          'review_text': '',
        };
      }

      print('Submitting ${widget.targetType} rating: $body');

      http.Response response;

      if (_reviewId == null) {
        // Create new review
        response = await http.post(
          Uri.parse('$apiUrl/$endpoint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );
        print('POST response status: ${response.statusCode}');
        print('POST response body: ${response.body}');

        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          final newReviewId = data[widget.targetType == 'service' ? 'service_review_id' : 'review_id'] as String;
          if (mounted) {
            setState(() {
              _reviewId = newReviewId;
            });
            widget.onRatingSubmitted?.call(newReviewId, rating);
            print('Created ${widget.targetType} review: reviewId=$newReviewId');
          }
        } else {
          throw Exception('Failed to create review: ${response.statusCode} - ${response.body}');
        }
      } else {
        // Update existing review
        final updateBody = widget.targetType == 'service'
            ? {'rating': rating, 'comment': ''}
            : {'rating': rating, 'review_text': ''};
        response = await http.put(
          Uri.parse('$apiUrl/$endpoint/$_reviewId'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(updateBody),
        );
        print('PUT response status: ${response.statusCode}');
        print('PUT response body: ${response.body}');

        if (response.statusCode == 200 && mounted) {
          widget.onRatingSubmitted?.call(_reviewId!, rating);
          print('Updated ${widget.targetType} review: rating=$rating');
        } else {
          throw Exception('Failed to update review: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('Error submitting ${widget.targetType} rating: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit ${widget.targetType} rating')),
        );
        setState(() {
          _currentRating = null; // Revert to no rating
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return GestureDetector(
          onTap: _isLoading ? null : () => _submitRating(starValue),
          child: Opacity(
            opacity: _isLoading ? 0.6 : 1.0,
            child: Icon(
              _currentRating != null && starValue <= _currentRating! ? Icons.star : Icons.star_border,
              color: _currentRating != null && starValue <= _currentRating! ? Colors.green : Colors.grey,
              size: screenHeight * 0.03,
            ),
          ),
        );
      }),
    );
  }
}