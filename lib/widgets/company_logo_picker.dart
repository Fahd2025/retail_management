import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../services/image_service.dart';
import 'dart:io';

/// Widget for picking and displaying company logo
/// Supports both web (base64) and mobile (file storage)
class CompanyLogoPicker extends StatefulWidget {
  final String? currentLogoPath;
  final Function(String logoPath) onLogoSelected;
  final Function()? onLogoRemoved;
  final double size;

  const CompanyLogoPicker({
    Key? key,
    this.currentLogoPath,
    required this.onLogoSelected,
    this.onLogoRemoved,
    this.size = 150.0,
  }) : super(key: key);

  @override
  State<CompanyLogoPicker> createState() => _CompanyLogoPickerState();
}

class _CompanyLogoPickerState extends State<CompanyLogoPicker> {
  bool _isLoading = false;
  Uint8List? _imageBytes;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrentLogo();
  }

  @override
  void didUpdateWidget(CompanyLogoPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentLogoPath != oldWidget.currentLogoPath) {
      _loadCurrentLogo();
    }
  }

  /// Load the current logo from storage
  Future<void> _loadCurrentLogo() async {
    if (widget.currentLogoPath == null || widget.currentLogoPath!.isEmpty) {
      setState(() {
        _imageBytes = null;
        _errorMessage = null;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final bytes = await ImageService.getImageBytes(widget.currentLogoPath);

      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load logo';
          _isLoading = false;
        });
      }
    }
  }

  /// Pick and process a new logo
  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Pick image
      final XFile? imageFile = await ImageService.pickImage(source: source);

      if (imageFile == null) {
        // User cancelled
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Process and store image
      final storagePath = await ImageService.processImageForStorage(imageFile);

      // Load the processed image for preview
      final bytes = await ImageService.getImageBytes(storagePath);

      if (mounted) {
        setState(() {
          _imageBytes = bytes;
          _isLoading = false;
        });

        // Notify parent
        widget.onLogoSelected(storagePath);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logo uploaded successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to process image: ${e.toString()}';
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload logo: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Remove the current logo
  void _removeLogo() {
    setState(() {
      _imageBytes = null;
      _errorMessage = null;
    });

    if (widget.onLogoRemoved != null) {
      widget.onLogoRemoved!();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logo removed'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Show options to pick image from gallery or camera
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (!kIsWeb) // Camera not available on web
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.green),
                  title: const Text('Take a Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              if (_imageBytes != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Logo'),
                  onTap: () {
                    Navigator.pop(context);
                    _removeLogo();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.grey),
                title: const Text('Cancel'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo preview container
        GestureDetector(
          onTap: _isLoading ? null : _showImageSourceOptions,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              border: Border.all(
                color: _errorMessage != null ? Colors.red : Colors.grey[300]!,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          _imageBytes!,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add Logo',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
          ),
        ),
        const SizedBox(height: 8),
        // Error message
        if (_errorMessage != null)
          Text(
            _errorMessage!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        // Action buttons
        if (!_isLoading)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: _showImageSourceOptions,
                icon: Icon(_imageBytes != null ? Icons.edit : Icons.upload),
                label: Text(_imageBytes != null ? 'Change' : 'Upload'),
              ),
              if (_imageBytes != null)
                TextButton.icon(
                  onPressed: _removeLogo,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Remove',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
