import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/abonnement.dart';
import '../services/AbonnementService.dart';

import '../services/auth_service.dart';
import 'AddAbonnementPage.dart';
import 'UpdateAbonnementPage.dart';
import 'admin_screen.dart'; // Import the update page

class AbonnementPage extends StatefulWidget {
  @override
  _AbonnementPageState createState() => _AbonnementPageState();
}

class _AbonnementPageState extends State<AbonnementPage> {

  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<List<Abonnement>> _getFilteredAbonnements() async {
    List<Abonnement> allAbonnements = await _abonnements;
    if (_searchQuery.isEmpty) {
      return allAbonnements;
    }
    return allAbonnements
        .where((abonnement) =>
        abonnement.titre.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  final _abonnementService = AbonnementService();
  late Future<List<Abonnement>> _abonnements;

  @override
  void initState() {
    super.initState();
    _abonnements = _abonnementService.getAbonnements();
  }

  Future<void> _deleteAbonnement(int abonnementId) async {
    // Afficher la boîte de dialogue de confirmation avant de supprimer
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 80,
                ),
                SizedBox(height: 20),
                Text(
                  'Confirmation de suppression',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Êtes-vous sûr de vouloir supprimer cet abonnement ?',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Annuler',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Supprimer',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await _abonnementService.deleteAbonnement(abonnementId);
        setState(() {
          _abonnements = _abonnementService.getAbonnements();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Abonnement supprimé avec succès'),
            backgroundColor: Color(0xFF00BCD0),
            duration: Duration(seconds: 3),

          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur: ${e.toString()}'),
        ));
      }
    }
  }

  // Update Abonnement function
  Future<void> _updateAbonnement(int abonnementId) async {
    final abonnement = await _abonnementService.getAbonnements().then((
        abonnements) =>
        abonnements.firstWhere((abonnement) => abonnement.id == abonnementId));

    // Navigate to the update page
    final updatedAbonnement = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateAbonnementPage(abonnement: abonnement),
      ),
    );

    if (updatedAbonnement != null) {
      setState(() {
        _abonnements = _abonnementService.getAbonnements();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des abonnements'),

        backgroundColor: Color(0xFF00BCD0).withOpacity(0.88),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: Builder(
          builder: (context) =>
              IconButton(
                icon: Icon(Icons.menu, color: Colors.black),
                onPressed: () =>
                    Scaffold.of(context).openDrawer(),
              ),
        ),
      ),
      drawer: Sidebar(
        authService: AuthService(),
        onSelectPage: (index) {},
        isDarkMode: false,
        toggleTheme: () {},
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Zone de recherche
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Rechercher par titre',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Abonnement>>(
                future: _getFilteredAbonnements(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Aucun abonnement trouvé'));
                  } else {
                    final abonnements = snapshot.data!;
                    return ListView.builder(
                      itemCount: abonnements.length,
                      itemBuilder: (context, index) {
                        final abonnement = abonnements[index];
                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.only(bottom: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Color(0xFF00BCD0), width: 2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: abonnement.imageUrl.isNotEmpty
                                        ? Image.memory(
                                      base64Decode(abonnement.imageUrl),
                                      width: double.infinity,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    )
                                        : Container(
                                      width: double.infinity,
                                      height: 150,
                                      color: Colors.grey[300],
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey[600],
                                        size: 50,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(Icons.title, size: 20, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        abonnement.titre,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.attach_money, size: 20, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text(
                                      abonnement.prix == abonnement.prix.toInt()
                                          ? '${abonnement.prix.toInt()} DT'
                                          : '${abonnement.prix.toStringAsFixed(2)} DT',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => _updateAbonnement(abonnement.id),
                                      icon: Icon(Icons.edit, color: Colors.white),
                                      label: Text('Éditer', style: TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () => _deleteAbonnement(abonnement.id),
                                      icon: Icon(Icons.delete, color: Colors.white),
                                      label: Text('Supprimer', style: TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                backgroundColor: Color(0xFF00BCD0),
                onPressed: () async {
                  final newAbonnement = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddAbonnementPage()),
                  );
                  if (newAbonnement != null) {
                    setState(() {
                      _abonnements = _abonnementService.getAbonnements();
                    });
                  }
                },
                child: Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}