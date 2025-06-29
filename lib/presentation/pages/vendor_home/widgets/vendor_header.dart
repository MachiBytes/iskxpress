import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/stall_state_service.dart';
import '../../../../core/services/user_state_service.dart';
import '../../../../core/models/stall_model.dart';

class VendorHeader extends StatefulWidget {
  const VendorHeader({super.key});

  @override
  State<VendorHeader> createState() => _VendorHeaderState();
}

class _VendorHeaderState extends State<VendorHeader> {
  final StallStateService _stallStateService = StallStateService();
  final UserStateService _userStateService = UserStateService();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  bool _isEditing = false;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    // Listen to stall state changes
    _stallStateService.addListener(_updateControllers);
    _updateControllers();
  }

  @override
  void dispose() {
    _stallStateService.removeListener(_updateControllers);
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateControllers() {
    final stall = _stallStateService.currentStall;
    if (stall != null) {
      _nameController.text = stall.name;
      _descriptionController.text = stall.shortDescription;
    }
  }

  Future<void> _selectAndUploadImage() async {
    try {
      // Show selection dialog for camera or gallery
      final source = await _showImageSourceDialog();
      if (source == null) return;

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        requestFullMetadata: false, // Helps with compatibility
      );

      if (image != null) {
        // Validate file type
        if (!_isValidImageFile(image.path)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a valid image file (JPG, JPEG, PNG, HEIC, WEBP)'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        final File imageFile = File(image.path);
        
        // Check file size (limit to 10MB)
        final fileSize = await imageFile.length();
        if (fileSize > 10 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image file is too large. Please select an image smaller than 10MB.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        final success = await _stallStateService.updateStallPicture(imageFile);
        
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Stall picture updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update stall picture. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      String errorMessage = 'Error selecting image';
      
      // Provide more specific error messages
      if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied. Please allow access to photos.';
      } else if (e.toString().contains('not supported')) {
        errorMessage = 'Image format not supported. Please try a different image.';
      } else if (e.toString().contains('cancelled')) {
        return; // User cancelled, don't show error
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  bool _isValidImageFile(String path) {
    final validExtensions = [
      '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.heic', '.heif'
    ];
    
    final lowerCasePath = path.toLowerCase();
    return validExtensions.any((ext) => lowerCasePath.endsWith(ext));
  }

  Future<void> _saveStallInfo() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both name and description'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await _stallStateService.updateStallInfo(
      name: name,
      shortDescription: description,
    );

    if (success) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stall information updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update stall information. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
    });
    _updateControllers(); // Reset controllers to original values
  }

  Future<void> _createStall() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final currentUser = _userStateService.currentUser;

    if (name.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both name and description'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not found. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await _stallStateService.createStall(
      vendorId: currentUser.id,
      name: name,
      shortDescription: description,
    );

    if (success) {
      setState(() {
        _isCreating = false;
      });
      // Clear controllers after successful creation
      _nameController.clear();
      _descriptionController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stall created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create stall. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _cancelCreate() {
    setState(() {
      _isCreating = false;
    });
    _nameController.clear();
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: _stallStateService,
      builder: (context, child) {
        final stall = _stallStateService.currentStall;
        final isLoading = _stallStateService.isLoading;

        if (isLoading && stall == null) {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (stall == null) {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: _isCreating 
                ? _buildCreateStallForm(colorScheme, textTheme)
                : _buildNoStallDisplay(colorScheme, textTheme),
          );
        }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
                  // Stall Logo/Avatar
                  GestureDetector(
                    onTap: _selectAndUploadImage,
                    child: Stack(
                      children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: colorScheme.onPrimary,
                          backgroundImage: stall.pictureUrl != null
                              ? NetworkImage(stall.pictureUrl!)
                              : null,
                          child: stall.pictureUrl == null
                              ? Icon(
                  Icons.store,
                  size: 30,
                  color: colorScheme.primary,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: colorScheme.onSecondary,
                            ),
                          ),
                        ),
                      ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                    child: _isEditing ? _buildEditingForm(colorScheme, textTheme) : _buildDisplayMode(stall, colorScheme, textTheme),
                  ),
                ],
              ),
              if (isLoading) ...[
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  backgroundColor: colorScheme.onPrimary.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDisplayMode(StallModel stall, ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
        Row(
          children: [
            Expanded(
              child: Text(
                stall.name,
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              icon: Icon(
                Icons.edit,
                color: colorScheme.onPrimary,
              ),
            ),
          ],
                    ),
                    const SizedBox(height: 5),
                    Text(
          stall.shortDescription,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary.withOpacity(0.9),
                      ),
                    ),
                  ],
    );
  }

  Widget _buildEditingForm(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameController,
          style: textTheme.headlineSmall?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: 'Stall name',
            hintStyle: TextStyle(
              color: colorScheme.onPrimary.withOpacity(0.7),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: colorScheme.onPrimary),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colorScheme.onPrimary.withOpacity(0.5)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colorScheme.onPrimary),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _descriptionController,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onPrimary.withOpacity(0.9),
          ),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Stall description',
            hintStyle: TextStyle(
              color: colorScheme.onPrimary.withOpacity(0.7),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: colorScheme.onPrimary),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colorScheme.onPrimary.withOpacity(0.5)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colorScheme.onPrimary),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            TextButton(
              onPressed: _cancelEdit,
              child: Text(
                'Cancel',
                style: TextStyle(color: colorScheme.onPrimary),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _saveStallInfo,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.onPrimary,
                foregroundColor: colorScheme.primary,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoStallDisplay(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      children: [
        Icon(
          Icons.store_mall_directory_outlined,
          size: 48,
          color: colorScheme.onPrimary,
        ),
        const SizedBox(height: 10),
        Text(
          'No stall found',
          style: textTheme.headlineSmall?.copyWith(
            color: colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Create your stall to start selling',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onPrimary.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _isCreating = true;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.onPrimary,
            foregroundColor: colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: const Text('Create Stall'),
        ),
      ],
    );
  }

  Widget _buildCreateStallForm(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.store,
              size: 30,
              color: colorScheme.onPrimary,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                'Create Your Stall',
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
                ),
              ),
            ],
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _nameController,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onPrimary,
          ),
          decoration: InputDecoration(
            labelText: 'Stall Name',
            labelStyle: TextStyle(
              color: colorScheme.onPrimary.withOpacity(0.8),
            ),
            hintText: 'Enter your stall name',
            hintStyle: TextStyle(
              color: colorScheme.onPrimary.withOpacity(0.6),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: colorScheme.onPrimary),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colorScheme.onPrimary.withOpacity(0.5)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colorScheme.onPrimary),
            ),
          ),
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _descriptionController,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onPrimary,
          ),
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Stall Description',
            labelStyle: TextStyle(
              color: colorScheme.onPrimary.withOpacity(0.8),
            ),
            hintText: 'Describe what your stall offers',
            hintStyle: TextStyle(
              color: colorScheme.onPrimary.withOpacity(0.6),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: colorScheme.onPrimary),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colorScheme.onPrimary.withOpacity(0.5)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: colorScheme.onPrimary),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            TextButton(
              onPressed: _cancelCreate,
              child: Text(
                'Cancel',
                style: TextStyle(color: colorScheme.onPrimary),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _createStall,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.onPrimary,
                foregroundColor: colorScheme.primary,
              ),
              child: const Text('Create Stall'),
          ),
        ],
      ),
      ],
    );
  }
} 