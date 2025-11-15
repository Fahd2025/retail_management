import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../services/image_service.dart';

/// Widget for picking and displaying company logo with Glassmorphism UI
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

  /// Show options to pick image from gallery or camera with Glassmorphism UI
  void _showImageSourceOptions() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return GlassmorphicContainer(
          width: double.infinity,
          height: null,
          borderRadius: 20,
          blur: 25,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.2),
              isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.1),
            ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.1),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Gallery option
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.photo_library, color: Colors.blue),
                    ),
                    title: Text(
                      'Choose from Gallery',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
                // Camera option (not available on web)
                if (!kIsWeb)
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.green),
                      ),
                      title: Text(
                        'Take a Photo',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                // Remove logo option
                if (_imageBytes != null)
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                      title: Text(
                        'Remove Logo',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _removeLogo();
                      },
                    ),
                  ),
                // Cancel option
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.cancel,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    title: Text(
                      'Cancel',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Logo preview container with glassmorphism effect
        GestureDetector(
          onTap: _isLoading ? null : _showImageSourceOptions,
          child: GlassmorphicContainer(
            width: widget.size,
            height: widget.size,
            borderRadius: 12,
            blur: 15,
            alignment: Alignment.center,
            border: 2,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.15),
                isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.white.withOpacity(0.08),
              ],
            ),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
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
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.surface.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.add_photo_alternate,
                              size: 48,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Add Logo',
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
          ),
        ),
        const SizedBox(height: 8),
        // Error message
        if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        // Action buttons with glassmorphism styling
        if (!_isLoading)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _showImageSourceOptions,
                icon: Icon(
                  _imageBytes != null ? Icons.edit : Icons.upload,
                  size: 18,
                  color: colorScheme.onSurface,
                ),
                label: Text(
                  _imageBytes != null ? 'Change' : 'Upload',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              if (_imageBytes != null) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _removeLogo,
                  icon: const Icon(
                    Icons.delete,
                    size: 18,
                    color: Colors.red,
                  ),
                  label: Text(
                    'Remove',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }
}
