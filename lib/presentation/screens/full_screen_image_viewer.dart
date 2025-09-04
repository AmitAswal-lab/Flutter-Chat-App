import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart';

class FullScreenImageViewer extends StatefulWidget {
  const FullScreenImageViewer({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  bool _isLoading = false;

  Future<void> _saveImage() async {
    setState(() {
      _isLoading = true;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    try {
      // Request permissions
      final hasAccess = await Gal.requestAccess();
      if (!hasAccess) {
        throw Exception('Storage permission not granted');
      }

      // Download the image
      final response = await http.get(Uri.parse(widget.imageUrl));
      if (!mounted) return;
      if (response.statusCode != 200) {
        throw Exception('Failed to download image');
      }

      // Save the image using Gal's simple API
      await Gal.putImageBytes(response.bodyBytes);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image saved to gallery!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withAlpha(127),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Hero(
          tag: widget.imageUrl,
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _saveImage,
        backgroundColor: Colors.teal,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.download, color: Colors.white),
      ),
    );
  }
}
