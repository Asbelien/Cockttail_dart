import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/cocktail.dart';
import '../services/db_helper.dart';

class FormScreen extends StatefulWidget {
  final Cocktail? cocktail;
  const FormScreen({super.key, this.cocktail});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DBHelper _dbHelper = DBHelper();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _glassController;
  late TextEditingController _instructionsController;

  String? _imageUrl;   // URL original de la API (si viene de ahí)
  File? _imageFile;    // imagen seleccionada de galería

  bool _isSaving = false;
  bool get _isEditing => widget.cocktail != null;

  @override
  void initState() {
    super.initState();
    final c = widget.cocktail;
    _nameController         = TextEditingController(text: c?.name ?? '');
    _categoryController     = TextEditingController(text: c?.category ?? '');
    _glassController        = TextEditingController(text: c?.glass ?? '');
    _instructionsController = TextEditingController(text: c?.instructions ?? '');
    _imageUrl               = c?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _glassController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _imageUrl = null; // ya no usamos la URL de la API
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    // Guardamos la ruta local si hay imagen nueva, o la URL original si no
    final imagePath = _imageFile?.path ?? _imageUrl ?? '';

    final cocktail = Cocktail(
      id:           widget.cocktail?.id,
      apiId:        widget.cocktail?.apiId,
      name:         _nameController.text.trim(),
      category:     _categoryController.text.trim(),
      glass:        _glassController.text.trim(),
      instructions: _instructionsController.text.trim(),
      imageUrl:     imagePath,
    );

    if (_isEditing) {
      await _dbHelper.updateCocktail(cocktail);
    } else {
      await _dbHelper.insertCocktail(cocktail);
    }

    setState(() => _isSaving = false);
    if (mounted) Navigator.pop(context, true);
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    bool required = true,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(width: 12, height: 1, color: const Color(0xFFC9933A)),
                const SizedBox(width: 6),
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFC9933A),
                    fontSize: 10,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(
              color: Color(0xFFF0E6D3),
              fontSize: 14,
              letterSpacing: 0.5,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF3A3A4A)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            validator: required
                ? (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    final hasImage = _imageFile != null || (_imageUrl != null && _imageUrl!.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(width: 12, height: 1, color: const Color(0xFFC9933A)),
                const SizedBox(width: 6),
                const Text(
                  'IMAGEN',
                  style: TextStyle(
                    color: Color(0xFFC9933A),
                    fontSize: 10,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A24),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: hasImage
                      ? const Color(0xFFC9933A).withOpacity(0.4)
                      : const Color(0xFF2A2A34),
                ),
              ),
              child: hasImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: _imageFile != null
                              ? Image.file(_imageFile!, fit: BoxFit.cover)
                              : Image.network(_imageUrl!, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const _EmptyImagePlaceholder()),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Color(0xFF0A0A0F)],
                              stops: [0.5, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A0A0F).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(color: const Color(0xFFC9933A).withOpacity(0.5)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.photo_library_outlined,
                                    size: 12, color: Color(0xFFC9933A)),
                                SizedBox(width: 4),
                                Text(
                                  'CAMBIAR',
                                  style: TextStyle(
                                    color: Color(0xFFC9933A),
                                    fontSize: 10,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : const _EmptyImagePlaceholder(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: Text(_isEditing ? 'EDITAR CÓCTEL' : 'NUEVO CÓCTEL'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          color: const Color(0xFFC9933A),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImagePicker(),
              _buildField(label: 'Nombre', controller: _nameController),
              _buildField(label: 'Categoría', controller: _categoryController),
              _buildField(label: 'Tipo de vaso', controller: _glassController),
              _buildField(
                label: 'Instrucciones',
                controller: _instructionsController,
                maxLines: 5,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Container(height: 1, color: const Color(0xFF1A1A24))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFFC9933A),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(child: Container(height: 1, color: const Color(0xFF1A1A24))),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Color(0xFF0A0A0F),
                          ),
                        )
                      : Text(
                          _isEditing ? 'GUARDAR CAMBIOS' : 'CREAR CÓCTEL',
                          style: const TextStyle(letterSpacing: 3, fontSize: 13),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyImagePlaceholder extends StatelessWidget {
  const _EmptyImagePlaceholder();
  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.photo_library_outlined, color: Color(0xFF3A3A4A), size: 36),
        SizedBox(height: 10),
        Text(
          'SELECCIONAR IMAGEN',
          style: TextStyle(
            color: Color(0xFF3A3A4A),
            fontSize: 11,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}