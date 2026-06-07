import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  Uint8List? _selectedImageBytes;
  File? _selectedImageFile;
  String? _selectedImageName;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _phoneController.text = user.phone;
      _emailController.text = user.email;
    }
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
        await _uploadProfileImage();
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

  Future<void> _uploadProfileImage() async {
    if (_selectedImageFile == null && _selectedImageBytes == null) return;

    setState(() => _isUploadingImage = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userData = {
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'phone': _phoneController.text.trim(),
    };

    bool success;
    if (kIsWeb) {
      success = await authProvider.updateProfileWithImageBytes(
        userData,
        imageBytes: _selectedImageBytes!,
        imageName: _selectedImageName ?? 'profile_image.jpg',
      );
    } else {
      success = await authProvider.updateProfileWithImage(
        userData,
        imagePath: _selectedImageFile!.path,
      );
    }

    setState(() => _isUploadingImage = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Profile picture updated successfully!'
            : authProvider.error ?? 'Failed to update profile picture'),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
    if (success) _loadUserData();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.updateProfile({
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'phone': _phoneController.text.trim(),
    });

    setState(() {
      _isLoading = false;
      _isEditing = false;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Profile updated successfully!'
            : authProvider.error ?? 'Failed to update profile'),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
    if (success) _loadUserData();
  }

  Future<void> _logout() async {
    // Capture the screen-level context BEFORE opening the dialog
    final screenContext = context;

    final confirmed = await showDialog<bool>(
      context: screenContext,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red.shade600),
            const SizedBox(width: 8),
            Text('Logout',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('Are you sure you want to logout?',
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            // Return false — user cancelled
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            // Return true — user confirmed
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    // Dialog is closed; now act on the result using the screen's context
    if (confirmed != true) return;
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  ImageProvider? _resolveImage() {
    if (kIsWeb && _selectedImageBytes != null) {
      return MemoryImage(_selectedImageBytes!);
    } else if (!kIsWeb && _selectedImageFile != null) {
      return FileImage(_selectedImageFile!);
    }
    return null;
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.orange.shade700,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          if (!_isEditing)
            TextButton.icon(
              onPressed: () => setState(() => _isEditing = true),
              icon: Icon(Icons.edit, color: Colors.orange.shade700, size: 18),
              label: Text('Edit',
                  style: GoogleFonts.poppins(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600)),
            ),
          if (_isEditing)
            TextButton(
              onPressed: () => setState(() {
                _isEditing = false;
                _loadUserData();
              }),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(
                      color: Colors.red.shade600, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final content = _buildScrollableContent(user);
                if (constraints.maxWidth > 600) {
                  return Center(child: SizedBox(width: 560, child: content));
                }
                return content;
              },
            ),
    );
  }

  Widget _buildScrollableContent(dynamic user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildProfileImage(),
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
            _buildStatsSection(user),
            const SizedBox(height: 24),
            _buildPersonalInfoSection(),
            const SizedBox(height: 24),
            if (_isEditing) _buildActionButtons(),
            if (!_isEditing) _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    final imageProvider = _resolveImage();
    return GestureDetector(
      onTap: _isEditing ? _pickImage : null,
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.orange.shade300, Colors.deepOrange.shade600],
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.orange.shade200,
                    blurRadius: 15,
                    offset: const Offset(0, 5)),
              ],
            ),
            child: CircleAvatar(
              radius: 58,
              backgroundColor: Colors.white,
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? Icon(Icons.person, size: 60, color: Colors.orange.shade700)
                  : null,
            ),
          ),
          if (_isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade700,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: _isUploadingImage
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.camera_alt,
                        size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange.shade50, Colors.deepOrange.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.shopping_bag, 'Total Orders', '12'),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _buildStatItem(Icons.star, 'Loyalty Points',
              user?.loyaltyPoints.toString() ?? '0'),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _buildStatItem(Icons.favorite, 'Favorites', '5'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.orange.shade700),
        const SizedBox(height: 8),
        Text(value,
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: const Color(0xFF1A1A1A))),
        Text(label,
            style:
                GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal Information',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: const Color(0xFF1A1A1A))),
          const SizedBox(height: 16),
          _buildTextField(
              controller: _firstNameController,
              label: 'First Name',
              icon: Icons.person_outline,
              enabled: _isEditing),
          const SizedBox(height: 16),
          _buildTextField(
              controller: _lastNameController,
              label: 'Last Name',
              icon: Icons.person_outline,
              enabled: _isEditing),
          const SizedBox(height: 16),
          _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              enabled: _isEditing),
          const SizedBox(height: 16),
          _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              enabled: false),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.poppins(
          fontSize: 14,
          color: enabled ? const Color(0xFF1A1A1A) : Colors.grey.shade600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            GoogleFonts.poppins(fontSize: 12, color: Colors.orange.shade700),
        prefixIcon: Icon(icon, size: 20, color: Colors.orange.shade700),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.orange.shade700, width: 2)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (!enabled) return null;
        if (value == null || value.isEmpty) return 'Please enter $label';
        return null;
      },
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.shade700,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text('Save Changes',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white)),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: _logout,
      icon: const Icon(Icons.logout),
      label: Text('Logout',
          style:
              GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade600,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }
}
