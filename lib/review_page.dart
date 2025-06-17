import 'dart:async';

import 'package:flutter/material.dart';
import 'models/review.dart';
import 'services/database_helper.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final TextEditingController _commentController = TextEditingController();
  List<Review> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    if (!mounted) return;
    
    try {
      setState(() => _isLoading = true);
      print('Loading reviews...');
      
      final reviews = await DatabaseHelper.instance.getAllReviews()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('Database timeout');
              throw TimeoutException('Database operation timed out');
            },
          );

      print('Reviews loaded: ${reviews.length}');
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error loading reviews: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _reviews = [];
        });
        _showErrorSnackBar('Error loading reviews: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _addReview() async {
    if (_commentController.text.isEmpty) return;

    try {
      final review = Review(
        comment: _commentController.text,
        dateAdded: DateTime.now(),
      );

      await DatabaseHelper.instance.createReview(review);
      _commentController.clear();
      await _loadReviews();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully')),
        );
      }
    } catch (e) {
      print('Error adding review: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding review: $e')),
        );
      }
    }
  }

  Future<void> _editReview(Review review) async {
    if (!mounted) return;
    
    final TextEditingController editController = TextEditingController(text: review.comment);
    
    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Review'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              labelText: 'Review Comment',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(107, 59, 225, 1),
              ),
              child: const Text(
                'Update',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (result ?? false) {
        if (editController.text.isEmpty) {
          _showErrorSnackBar('Review cannot be empty');
          return;
        }

        final updatedReview = Review(
          id: review.id,
          comment: editController.text,
          dateAdded: review.dateAdded,
        );
        
        await DatabaseHelper.instance.updateReview(updatedReview);
        await _loadReviews();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review updated successfully')),
          );
        }
      }
    } catch (e, stackTrace) {
      print('Error updating review: $e');
      print('Stack trace: $stackTrace');
      _showErrorSnackBar('Error updating review: $e');
    } finally {
      editController.dispose();
    }
  }

  Future<void> _deleteReview(Review review) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result ?? false) {
      try {
        await DatabaseHelper.instance.deleteReview(review.id!);
        await _loadReviews();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review deleted successfully')),
          );
        }
      } catch (e) {
        print('Error deleting review: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting review: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Stock Review', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromRGBO(107, 59, 225, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Add Review Comment',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(107, 59, 225, 1),
                
              ),
              
              child: const Text('Submit Review')
              ,
            ),
            const SizedBox(height: 24),
            const Text(
              'Previous Reviews',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading reviews...'),
                        ],
                      ),
                    )
                  : _reviews.isEmpty
                      ? const Center(
                          child: Text('No reviews available'),
                        )
                      : ListView.builder(
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            final review = _reviews[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(review.comment),
                                subtitle: Text(
                                  review.dateAdded.toString().split('.')[0],
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Color.fromRGBO(107, 59, 225, 1),
                                      ),
                                      onPressed: () => _editReview(review),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _deleteReview(review),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
