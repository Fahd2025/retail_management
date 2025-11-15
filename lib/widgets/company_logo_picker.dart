import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:liquid_glass_ui_design/liquid_glass_ui_design.dart';
import '../services/image_service.dart';

/// Widget for picking and displaying company logo with Liquid Glass UI
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

  /// Show options to pick image from gallery or camera with Liquid Glass UI
  void _showImageSourceOptions() {
    final liquidTheme = LiquidTheme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return LiquidCard(
          borderRadius: 20,
          elevation: 8,
          blur: 25,
          opacity: 0.18,
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
                    color: liquidTheme.textColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Gallery option
                LiquidContainer(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  borderRadius: 12,
                  blur: 10,
                  opacity: 0.1,
                  child: ListTile(
                    leading: LiquidContainer(
                      padding: const EdgeInsets.all(8),
                      borderRadius: 8,
                      blur: 8,
                      opacity: 0.2,
                      child: const Icon(Icons.photo_library, color: Colors.blue),
                    ),
                    title: Text(
                      'Choose from Gallery',
                      style: TextStyle(color: liquidTheme.textColor),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
                // Camera option (not available on web)
                if (!kIsWeb)
                  LiquidContainer(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    borderRadius: 12,
                    blur: 10,
                    opacity: 0.1,
                    child: ListTile(
                      leading: LiquidContainer(
                        padding: const EdgeInsets.all(8),
                        borderRadius: 8,
                        blur: 8,
                        opacity: 0.2,
                        child: const Icon(Icons.camera_alt, color: Colors.green),
                      ),
                      title: Text(
                        'Take a Photo',
                        style: TextStyle(color: liquidTheme.textColor),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                // Remove logo option
                if (_imageBytes != null)
                  LiquidContainer(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    borderRadius: 12,
                    blur: 10,
                    opacity: 0.1,
                    child: ListTile(
                      leading: LiquidContainer(
                        padding: const EdgeInsets.all(8),
                        borderRadius: 8,
                        blur: 8,
                        opacity: 0.2,
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                      title: Text(
                        'Remove Logo',
                        style: TextStyle(color: liquidTheme.textColor),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _removeLogo();
                      },
                    ),
                  ),
                // Cancel option
                LiquidContainer(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  borderRadius: 12,
                  blur: 10,
                  opacity: 0.1,
                  child: ListTile(
                    leading: LiquidContainer(
                      padding: const EdgeInsets.all(8),
                      borderRadius: 8,
                      blur: 8,
                      opacity: 0.2,
                      child: Icon(Icons.cancel, color: liquidTheme.textColor),
                    ),
                    title: Text(
                      'Cancel',
                      style: TextStyle(color: liquidTheme.textColor),
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
    final liquidTheme = LiquidTheme.of(context);

    return Column(
      children: [
        // Logo preview container with Liquid Glass effect
        GestureDetector(
          onTap: _isLoading ? null : _showImageSourceOptions,
          child: LiquidCard(
            width: widget.size,
            height: widget.size,
            borderRadius: 12,
            elevation: 4,
            blur: 15,
            opacity: 0.15,
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: liquidTheme.primaryColor,
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
                          LiquidContainer(
                            padding: const EdgeInsets.all(12),
                            borderRadius: 12,
                            blur: 10,
                            opacity: 0.2,
                            child: Icon(
                              Icons.add_photo_alternate,
                              size: 48,
                              color: liquidTheme.textColor.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Add Logo',
                            style: TextStyle(
                              color: liquidTheme.textColor.withValues(alpha: 0.7),
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
              color: Colors.red.withValues(alpha: 0.1),
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
        // Action buttons with Liquid Glass styling
        if (!_isLoading)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LiquidButton(
                onPressed: _showImageSourceOptions,
                type: LiquidButtonType.outlined,
                size: LiquidButtonSize.small,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _imageBytes != null ? Icons.edit : Icons.upload,
                      size: 18,
                      color: liquidTheme.textColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _imageBytes != null ? 'Change' : 'Upload',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: liquidTheme.textColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (_imageBytes != null) ...[
                const SizedBox(width: 8),
                LiquidButton(
                  onPressed: _removeLogo,
                  type: LiquidButtonType.outlined,
                  size: LiquidButtonSize.small,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.delete,
                        size: 18,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Remove',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
      ],
    );
  }
}
