import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cocktail.dart';
import '../services/db_helper.dart';
import '../services/api_service.dart';
import 'form_screen.dart';
import 'detail_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({
    super.key,
    required this.username,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DBHelper _dbHelper = DBHelper();
  final ApiService _apiService = ApiService();

  List<Cocktail> _cocktails = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_username');

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    final hasData = await _dbHelper.hasData();

    if (!hasData) {
      try {
        final apiCocktails =
            await _apiService.fetchCocktailsByLetter('a');

        for (final cocktail in apiCocktails) {
          await _dbHelper.insertCocktail(cocktail);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar de la API: $e'),
            ),
          );
        }
      }
    }

    await _refreshList();
  }

  Future<void> _refreshList() async {
    final cocktails = await _dbHelper.getAllCocktails();

    setState(() {
      _cocktails = cocktails;
      _isLoading = false;
    });
  }

  Future<void> _deleteCocktail(String id) async {
    await _dbHelper.deleteCocktail(id);
    await _refreshList();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cóctel eliminado'),
        ),
      );
    }
  }

  void _goToForm({Cocktail? cocktail}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormScreen(cocktail: cocktail),
      ),
    );

    if (result == true) {
      _refreshList();
    }
  }

  void _goToDetail(Cocktail cocktail) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(cocktail: cocktail),
      ),
    );

    if (result == true) {
      _refreshList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: const Color(0xFF0A0A0F),
            actions: [
              Padding(
                padding: const EdgeInsets.only(
                  right: 16,
                  top: 8,
                ),
                child: GestureDetector(
                  onTap: _logout,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.logout,
                        size: 16,
                        color: Color(0xFF4A4A5A),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.username,
                        style: const TextStyle(
                          color: Color(0xFF4A4A5A),
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                left: 20,
                bottom: 16,
              ),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'COCTELERÍA',
                    style: TextStyle(
                      color: Color(0xFFC9933A),
                      fontSize: 22,
                      fontWeight: FontWeight.w200,
                      letterSpacing: 8,
                    ),
                  ),
                  Text(
                    '${_cocktails.length} recetas',
                    style: const TextStyle(
                      color: Color(0xFF6A6A7A),
                      fontSize: 11,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              background: Stack(
                children: [
                  Container(
                    color: const Color(0xFF0A0A0F),
                  ),
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFC9933A)
                                .withOpacity(0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFC9933A),
                  strokeWidth: 1,
                ),
              ),
            )
          else if (_cocktails.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'SIN RECETAS\nAgrega tu primer cóctel',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF3A3A4A),
                    letterSpacing: 2,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                100,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final cocktail = _cocktails[index];

                    return _CocktailCard(
                      cocktail: cocktail,
                      index: index,
                      onTap: () => _goToDetail(cocktail),
                      onEdit: () =>
                          _goToForm(cocktail: cocktail),
                      onDelete: () =>
                          _deleteCocktail(cocktail.id!),
                    );
                  },
                  childCount: _cocktails.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToForm(),
        backgroundColor: const Color(0xFFC9933A),
        foregroundColor: const Color(0xFF0A0A0F),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: const Icon(
          Icons.add,
          size: 28,
        ),
      ),
    );
  }
}

class _CocktailCard extends StatelessWidget {
  final Cocktail cocktail;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CocktailCard({
    required this.cocktail,
    required this.index,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return const _PlaceholderIcon();
    }

    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const _PlaceholderIcon(),
      );
    }

    return Image.file(
      File(imageUrl),
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A24),
          borderRadius: BorderRadius.circular(4),
          border: Border(
            left: BorderSide(
              color: const Color(0xFFC9933A)
                  .withOpacity(0.6),
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Center(
                child: Text(
                  (index + 1)
                      .toString()
                      .padLeft(2, '0'),
                  style: const TextStyle(
                    color: Color(0xFF3A3A4A),
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImage(cocktail.imageUrl),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            const Color(0xFF1A1A24)
                                .withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    cocktail.name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFF0E6D3),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cocktail.category,
                    style: const TextStyle(
                      color: Color(0xFF6A6A7A),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderIcon extends StatelessWidget {
  const _PlaceholderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2A2A34),
      child: const Icon(
        Icons.local_bar,
        color: Color(0xFF3A3A4A),
        size: 30,
      ),
    );
  }
}