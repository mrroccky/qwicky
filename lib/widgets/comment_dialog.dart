import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:qwicky/widgets/colors.dart';

class CommentDialog extends StatefulWidget {
  final String serviceReviewId;
  final String professionalReviewId;
  final int serviceRating;
  final int professionalRating;

  const CommentDialog({
    super.key,
    required this.serviceReviewId,
    required this.professionalReviewId,
    required this.serviceRating,
    required this.professionalRating,
  });

  @override
  State<CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog> {
  final TextEditingController _commentController = TextEditingController();
  bool isSubmitting = false;

  Future<void> _submitComment() async {
    if (_commentController.text.isEmpty) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      final String apiUrl = dotenv.env['BACK_END_API'] ?? 'http://192.168.1.37:3000/api';

      final serviceResponse = await http.put(
        Uri.parse('$apiUrl/servicereview/${widget.serviceReviewId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'rating': widget.serviceRating,
          'comment': _commentController.text,
        }),
      );
      print('Service comment update status: ${serviceResponse.statusCode}');
      print('Service comment update body: ${serviceResponse.body}');

      final professionalResponse = await http.put(
        Uri.parse('$apiUrl/user-review-prof/${widget.professionalReviewId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'rating': widget.professionalRating,
          'review_text': _commentController.text,
        }),
      );
      print('Professional comment update status: ${professionalResponse.statusCode}');
      print('Professional comment update body: ${professionalResponse.body}');

      if (serviceResponse.statusCode == 200 && professionalResponse.statusCode == 200 && mounted) {
        Navigator.of(context).pop();
      } else {
        throw Exception('Failed to update comments');
      }
    } catch (e) {
      print('Error submitting comment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit comment')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
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
            constraints: BoxConstraints(maxWidth: 400, maxHeight: screenHeight * 0.4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Your Comment',
                  style: TextStyle(
                    fontSize: screenHeight * 0.025,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Comment',
                    hintText: 'Enter your comment here',
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                    ),
                    ElevatedButton(
                      onPressed: isSubmitting ? null : _submitComment,
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
  }
}