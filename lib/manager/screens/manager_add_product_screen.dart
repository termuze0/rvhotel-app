import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/manager_provider.dart';

class ManagerAddProductScreen extends StatefulWidget {
  const ManagerAddProductScreen({super.key});

  @override
  State<ManagerAddProductScreen> createState() =>
      _ManagerAddProductScreenState();
}

class _ManagerAddProductScreenState extends State<ManagerAddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _preparationTimeController = TextEditingController();

  bool _isAvailable = true;
  bool _isSubmitting = false;

  Uint8List? _selectedImageBytes;
  File? _selectedImageFile;
  String? _selectedImageName;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _preparationTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _selectedImageBytes = bytes;
            _selectedImageFile = null;
            _selectedImageName = image.name;
          });
        } else {
          setState(() {
            _selectedImageFile = File(image.path);
            _selectedImageBytes = null;
            _selectedImageName = image.name;
          });
        }
        print('Image selected: $_selectedImageName');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error picking image: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final managerProvider =
        Provider.of<ManagerProvider>(context, listen: false);

    final productData = {
      'name': _nameController.text.trim(),
      'price': double.parse(_priceController.text),
      'category': _categoryController.text.trim(),
      'description': _descriptionController.text.trim(),
      'preparation_time': int.parse(_preparationTimeController.text),
      'is_available': _isAvailable,
    };

    print('=== SUBMITTING PRODUCT ===');
    print('Product data: $productData');
    print('Has image file: ${_selectedImageFile != null}');
    print('Has image bytes: ${_selectedImageBytes != null}');

    bool success;

    if (_selectedImageFile != null || _selectedImageBytes != null) {
      success = await managerProvider.addProductWithImage(
        productData,
        imageFile: _selectedImageFile,
        imageBytes: _selectedImageBytes,
        imageName: _selectedImageName ?? 'product_image.jpg',
      );
    } else {
      success = await managerProvider.addProduct(productData);
    }

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Product added successfully!'),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(managerProvider.error ?? 'Failed to add product'),
            backgroundColor: Colors.red),
      );
    }
  }

  bool get _hasImage =>
      _selectedImageBytes != null || _selectedImageFile != null;

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey.shade500),
        const SizedBox(height: 8),
        Text('Tap to add product image',
            style: GoogleFonts.poppins(color: Colors.grey.shade500)),
        const SizedBox(height: 4),
        Text('JPG, PNG, WEBP up to 2MB',
            style:
                GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _buildImagePreview() {
    if (kIsWeb && _selectedImageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.memory(
          _selectedImageBytes!,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    } else if (_selectedImageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          _selectedImageFile!,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    }
    return _buildImagePlaceholder();
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Enter $label',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange.shade700, width: 2),
        ),
        prefixIcon: Icon(icon, color: Colors.orange.shade700),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (isNumber) {
          if (double.tryParse(value) == null) return 'Enter a valid number';
          if (double.parse(value) <= 0) return 'Must be greater than 0';
        }
        return null;
      },
    );
  }

  Widget _buildAvailabilitySwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.store, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 12),
              Text('Available for order',
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          Switch(
            value: _isAvailable,
            onChanged: (value) => setState(() => _isAvailable = value),
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.shade700,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Add Product',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white)),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Product',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.orange.shade700),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _hasImage
                      ? _buildImagePreview()
                      : _buildImagePlaceholder(),
                ),
              ),
              if (_selectedImageName != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Selected: $_selectedImageName',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.green.shade700),
                  ),
                ),
              const SizedBox(height: 24),
              _buildTextField(_nameController, 'Product Name', Icons.fastfood),
              const SizedBox(height: 16),
              _buildTextField(
                  _priceController, 'Price (ETB)', Icons.attach_money,
                  isNumber: true),
              const SizedBox(height: 16),
              _buildTextField(_categoryController, 'Category', Icons.category),
              const SizedBox(height: 16),
              _buildTextField(_preparationTimeController,
                  'Preparation Time (minutes)', Icons.timer,
                  isNumber: true),
              const SizedBox(height: 16),
              _buildTextField(
                  _descriptionController, 'Description', Icons.description,
                  maxLines: 3),
              const SizedBox(height: 16),
              _buildAvailabilitySwitch(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
}
