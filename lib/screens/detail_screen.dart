import 'dart:io';
import 'package:flutter/material.dart';
import '../models/cocktail.dart';
import '../services/db_helper.dart';
import 'form_screen.dart';

class DetailScreen extends StatelessWidget {
  final Cocktail cocktail;
  const DetailScreen({super.key, required this.cocktail});

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        color: const Color(0xFF1A1A24),
        child: const Icon(Icons.local_bar, color: Color(0xFF3A3A4A), size: 80),
      );
    }
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFF1A1A24),
          child: const Icon(Icons.local_bar, color: Color(0xFF3A3A4A), size: 80),
        ),
      );
    }
    return Image.file(File(imageUrl), fit: BoxFit.cover);
  }

  Future<void> _delete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: const Text(
          'ELIMINAR',
          style: TextStyle(
            color: Color(0xFFF0E6D3),
            letterSpacing: 3,
            fontSize: 14,
          ),
        ),
        content: Text(
          '¿Eliminar "${cocktail.name}"?\nEsta acción no se puede deshacer.',
          style: const TextStyle(color: Color(0xFF9A9AAA), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'CANCELAR',
              style: TextStyle(
                color: Color(0xFF5A5A6A),
                letterSpacing: 1,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'ELIMINAR',
              style: TextStyle(
                color: Color(0xFF8B1A2F),
                letterSpacing: 1,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DBHelper().deleteCocktail(cocktail.id!);
      if (context.mounted) Navigator.pop(context, true);
    }
  }

  void _edit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormScreen(cocktail: cocktail)),
    );
    if (result == true && context.mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: const Color(0xFF0A0A0F),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 18),
              color: const Color(0xFFC9933A),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                color: const Color(0xFFC9933A),
                onPressed: () => _edit(context),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                color: const Color(0xFF8B1A2F),
                onPressed: () => _delete(context),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(cocktail.imageUrl),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0xFF0A0A0F),
                        ],
                        stops: [0.3, 1.0],
                      ),
                    ),
                  ),
                  // Overlay lateral izquierdo dorado
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 3,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Color(0xFFC9933A),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Nombre
                Text(
                  cocktail.name.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFF0E6D3),
                    fontSize: 26,
                    fontWeight: FontWeight.w200,
                    letterSpacing: 4,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 14),

                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Tag(cocktail.category, icon: Icons.category_outlined),
                    _Tag(cocktail.glass, icon: Icons.local_bar_outlined),
                  ],
                ),
                const SizedBox(height: 36),

                // Ingredientes
                if (cocktail.ingredients.isNotEmpty) ...[
                  const _SectionLabel('INGREDIENTES'),
                  const SizedBox(height: 16),
                  ...cocktail.ingredients.asMap().entries.map((entry) {
                    final i = entry.key;
                    final ingredient = entry.value;
                    return _IngredientRow(
                      ingredient: ingredient,
                      index: i,
                    );
                  }),
                  const SizedBox(height: 36),
                ],

                // Instrucciones
                const _SectionLabel('PREPARACIÓN'),
                const SizedBox(height: 16),
                Text(
                  cocktail.instructions,
                  style: const TextStyle(
                    color: Color(0xFF9A9AAA),
                    fontSize: 15,
                    height: 1.8,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final String ingredient;
  final int index;

  const _IngredientRow({required this.ingredient, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Número
          SizedBox(
            width: 28,
            child: Text(
              '${(index + 1).toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Color(0xFF3A3A4A),
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          // Línea
          Container(
            width: 1,
            height: 20,
            color: const Color(0xFFC9933A).withOpacity(0.3),
          ),
          const SizedBox(width: 14),
          // Ingrediente
          Expanded(
            child: Text(
              ingredient,
              style: const TextStyle(
                color: Color(0xFFF0E6D3),
                fontSize: 14,
                letterSpacing: 0.5,
                height: 1.3,
              ),
            ),
          ),
          // Dot decorativo
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFC9933A).withOpacity(0.4),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Tag(this.label, {required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A24),
        border: Border.all(color: const Color(0xFFC9933A).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFFC9933A)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFC9933A),
              fontSize: 11,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 20, height: 1, color: const Color(0xFFC9933A)),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFFC9933A),
            fontSize: 11,
            letterSpacing: 3,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFF1A1A24),
          ),
        ),
      ],
    );
  }
}