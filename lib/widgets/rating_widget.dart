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
  
  // Add unique key for this widget instance
  late final String _widgetKey;

  @override
  void initState() {
    super.initState();
    // Create unique key for this widget instance
    _widgetKey = '${widget.targetType}_${widget.bookingId}_${widget.targetId}';
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

      print('[$_widgetKey] Fetching ${widget.targetType} review for targetId: ${widget.targetId}, userId: ${widget.userId}, bookingId: ${widget.bookingId}');
      print('[$_widgetKey] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> reviews = jsonDecode(response.body);
        
        final review = reviews.firstWhere(
          (r) {
            bool matches = false;
            if (widget.targetType == 'service') {
              matches = r['service_id'] == widget.targetId &&
                       r['user_id'] == widget.userId &&
                       r['booking_id'] == widget.bookingId;
            } else {
              matches = r['professional_id'] == widget.targetId &&
                       r['user_id'] == widget.userId &&
                       r['booking_id'] == widget.bookingId;
            }
            return matches;
          },
          orElse: () => null,
        );
        
        if (review != null && mounted) {
          setState(() {
            _currentRating = review['rating'] as int;
            _reviewId = review[widget.targetType == 'service' ? 'service_review_id' : 'review_id'] as String;
          });
          print('[$_widgetKey] Found ${widget.targetType} review: rating=$_currentRating, reviewId=$_reviewId');
        } else {
          print('[$_widgetKey] No existing review found');
        }
      } else {
        print('[$_widgetKey] Failed to fetch ${widget.targetType} review: ${response.statusCode}');
      }
    } catch (e) {
      print('[$_widgetKey] Error fetching ${widget.targetType} review: $e');
    }
  }

  String _getRatingMessage(int rating) {
    switch (rating) {
      case 5:
        return "Thanks for the 5-star rating! 🌟 We're thrilled you loved our service!";
      case 4:
        return "Thanks for the 4-star rating! 🎉 Hope you enjoyed our services!";
      case 3:
        return "Thanks for the 3-star rating! 😊 Let us know how we can improve.";
      case 2:
        return "Thanks for the 2-star rating. 😔 We'd love your feedback to make things better.";
      case 1:
        return "Sorry to hear about your 1-star rating. 😢 Please share your feedback so we can improve.";
      default:
        return "Thanks for your rating!";
    }
  }

  void _showRatingDialog(int starValue) {
    final TextEditingController commentController = TextEditingController();
    
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return _RatingDialog(
          starValue: starValue,
          commentController: commentController,
          widgetKey: _widgetKey,
          targetType: widget.targetType,
          getRatingMessage: _getRatingMessage,
          onSubmit: (rating, comment) async {
            try {
              await _submitRating(rating, comment);
              print('[$_widgetKey] Rating submitted successfully, closing dialog');
            } catch (e) {
              print('[$_widgetKey] Error in dialog submission: $e');
              // Show error message but still close dialog
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to submit ${widget.targetType} rating: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            } finally {
              // ALWAYS close dialog no matter what happens
              print('[$_widgetKey] Force closing dialog');
              if (Navigator.of(dialogContext).canPop()) {
                Navigator.of(dialogContext).pop();
              }
            }
          },
        );
      },
    );
  }

  Future<int?> _fetchProfessionalId(int bookingId) async {
    try {
      final String apiUrl = dotenv.env['BACK_END_API'] ?? 'http://192.168.1.37:3000/api';
      final response = await http.get(
        Uri.parse('$apiUrl/bookings/$bookingId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('[$_widgetKey] Fetching professional_id for bookingId: $bookingId');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final professionalId = data['professional_id'] as int?;
        return professionalId;
      } else {
        print('[$_widgetKey] Failed to fetch booking details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('[$_widgetKey] Error fetching professional_id: $e');
      return null;
    }
  }

  Future<void> _submitRating(int rating, String comment) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final String apiUrl = dotenv.env['BACK_END_API'] ?? 'http://192.168.1.37:3000/api';
      final String endpoint = widget.targetType == 'service' ? 'servicereview' : 'user-review-prof';

      // Fetch professional_id from bookings table
      final professionalId = await _fetchProfessionalId(widget.bookingId);
      if (professionalId == null && widget.targetType == 'service') {
        throw Exception('No professional assigned to this booking');
      }

      Map<String, dynamic> body;

      if (widget.targetType == 'service') {
        body = {
          'service_id': widget.targetId,
          'user_id': widget.userId,
          'professional_id': professionalId,
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

      print('[$_widgetKey] Submitting ${widget.targetType} rating: $body');

      http.Response response;

      if (_reviewId == null) {
        response = await http.post(
          Uri.parse('$apiUrl/$endpoint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );
        print('[$_widgetKey] POST response status: ${response.statusCode}');

        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          final newReviewId = data[widget.targetType == 'service' ? 'service_review_id' : 'review_id'] as String;
          if (mounted) {
            setState(() {
              _reviewId = newReviewId;
              _currentRating = rating; // Set rating immediately on success
            });
            widget.onRatingSubmitted?.call(newReviewId, rating);
            print('[$_widgetKey] Created ${widget.targetType} review: reviewId=$newReviewId');
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
        print('[$_widgetKey] PUT response status: ${response.statusCode}');

        if (response.statusCode == 200) {
          if (mounted) {
            setState(() {
              _currentRating = rating; // Set rating immediately on success
            });
            widget.onRatingSubmitted?.call(_reviewId!, rating);
            print('[$_widgetKey] Updated ${widget.targetType} review: rating=$rating');
          }
        } else {
          throw Exception('Failed to update review: ${response.statusCode} - ${response.body}');
        }
      }
      
      print('[$_widgetKey] ✅ _submitRating completed successfully');
      
    } catch (e) {
      print('[$_widgetKey] ❌ Error submitting rating: $e');
      if (mounted) {
        setState(() {
          _currentRating = null; // Reset on actual error
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

// Separate dialog widget to isolate state management
class _RatingDialog extends StatefulWidget {
  final int starValue;
  final TextEditingController commentController;
  final String widgetKey;
  final String targetType;
  final String Function(int) getRatingMessage;
  final Future<void> Function(int, String) onSubmit;

  const _RatingDialog({
    required this.starValue,
    required this.commentController,
    required this.widgetKey,
    required this.targetType,
    required this.getRatingMessage,
    required this.onSubmit,
  });

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  bool _isSubmitting = false;

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      print('[${widget.widgetKey}] Starting dialog submission...');
      await widget.onSubmit(widget.starValue, widget.commentController.text);
      print('[${widget.widgetKey}] Dialog submission completed successfully');
      // Dialog will be closed by the parent's onSubmit callback in finally block
    } catch (e) {
      print('[${widget.widgetKey}] Dialog submission failed: $e');
      // Don't reset loading state since dialog will close anyway
    }
    // Note: Loading state will be reset when dialog closes and widget is disposed
  }

  @override
  Widget build(BuildContext context) {
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
                  widget.getRatingMessage(widget.starValue),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: widget.commentController,
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
                      onPressed: _isSubmitting ? null : () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                    ),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSubmitting
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
  }
}