import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qwicky/widgets/colors.dart';

class RatingWidget extends StatefulWidget {
  final int bookingId;
  final int userId;
  final int targetId;
  final int serviceId;
  final String targetType;
  final int professionalId;
  final Function(String reviewId, int rating)? onRatingSubmitted;

  const RatingWidget({
    super.key,
    required this.bookingId,
    required this.userId,
    required this.targetId,
    required this.serviceId,
    required this.targetType,
    this.onRatingSubmitted,
    required this.professionalId,
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

  String _getRatingMessage(int rating) {
    switch (rating) {
      case 5:
        return "Thanks for the 5-star rating! 🌟 We’re thrilled you loved our service!";
      case 4:
        return "Thanks for the 4-star rating! 🎉 Hope you enjoyed our services!";
      case 3:
        return "Thanks for the 3-star rating! 😊 Let us know how we can improve.";
      case 2:
        return "Thanks for the 2-star rating. 😔 We’d love your feedback to make things better.";
      case 1:
        return "Sorry to hear about your 1-star rating. 😢 Please share your feedback so we can improve.";
      default:
        return "Thanks for your rating!";
    }
  }

  void _showRatingDialog(int starValue) {
    showDialog(
      context: context,
      builder: (dialogContext) { // Use a separate context for the dialog
        final TextEditingController commentController = TextEditingController();
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 16,
                    right: 16,
                    top: 16,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getRatingMessage(starValue),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: commentController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Comment (Optional)',
                            hintText: 'Enter your feedback here',
                          ),
                          maxLines: 3,
                          minLines: 1,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(),
                              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                            ),
                            ElevatedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      setDialogState(() {
                                        isSubmitting = true;
                                      });
                                      try {
                                        await _submitRating(starValue, commentController.text);
                                        print('Submission successful for ${widget.targetType}, closing dialog...');
                                        if (mounted) {
                                          Navigator.of(dialogContext).pop(); // Use dialogContext to pop
                                        }
                                      } catch (e) {
                                        print('Error during submission: $e');
                                        setDialogState(() {
                                          isSubmitting = false;
                                        });
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Failed to submit ${widget.targetType} rating')),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text(
                                      'Submit',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitRating(int rating, String comment) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _currentRating = rating;
    });

    try {
      final String apiUrl = dotenv.env['BACK_END_API'] ?? 'http://192.168.1.37:3000/api';
      final String endpoint = widget.targetType == 'service' ? 'servicereview' : 'user-review-prof';
      Map<String, dynamic> body;

      if (widget.targetType == 'service') {
        body = {
          'service_id': widget.targetId,
          'user_id': widget.userId,
          'professional_id': widget.professionalId,
          'booking_id': widget.bookingId,
          'rating': rating,
          'comment': comment,
        };
      } else {
        body = {
          'service_id': widget.serviceId,
          'user_id': widget.userId,
          'professional_id': widget.targetId,
          'booking_id': widget.bookingId,
          'rating': rating,
          'review_text': comment,
        };
      }

      print('Submitting ${widget.targetType} rating: $body');

      http.Response response;

      if (_reviewId == null) {
        response = await http.post(
          Uri.parse('$apiUrl/$endpoint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );
        print('POST response status for ${widget.targetType}: ${response.statusCode}');
        print('POST response body for ${widget.targetType}: ${response.body}');

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
        final updateBody = widget.targetType == 'service'
            ? {'rating': rating, 'comment': comment}
            : {'rating': rating, 'review_text': comment};
        response = await http.put(
          Uri.parse('$apiUrl/$endpoint/$_reviewId'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(updateBody),
        );
        print('PUT response status for ${widget.targetType}: ${response.statusCode}');
        print('PUT response body for ${widget.targetType}: ${response.body}');

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
          _currentRating = null;
        });
      }
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return Expanded(
          child: GestureDetector(
            onTap: _isLoading ? null : () => _showRatingDialog(starValue),
            child: Opacity(
              opacity: _isLoading ? 0.6 : 1.0,
              child: Icon(
                _currentRating != null && starValue <= _currentRating! ? Icons.star : Icons.star_border,
                color: _currentRating != null && starValue <= _currentRating! ? Colors.green : Colors.grey,
                size: screenHeight * 0.03,
              ),
            ),
          ),
        );
      }),
    );
  }
}