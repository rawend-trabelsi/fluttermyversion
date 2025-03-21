import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/service.dart';
import '../services/ServiceService.dart';

import '../services/auth_service.dart';
import 'AddServicePage.dart';
import 'package:path/path.dart' as path;

import 'UpdateServicePage.dart';
import 'admin_screen.dart';
class ServicePage extends StatefulWidget {
  @override
  _ServicePageState createState() => _ServicePageState();
}
class _ServicePageState extends State<ServicePage> {
  final _serviceService = ServiceService();
  late Future<List<Service>> _services;
  File? _imageFile;
  final _picker = ImagePicker();
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _services = _serviceService.getServicesAdmin();
  }

  // Filtrer les services par titre
  Future<List<Service>> _getFilteredServices() async {
    List<Service> allServices = await _services;
    if (_searchQuery.isEmpty) {
      return allServices;
    }
    return allServices
        .where((service) =>
        service.titre.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }
  Future<void> _deleteService(int serviceId) async {
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
                  'Êtes-vous sûr de vouloir supprimer ce service ?',
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

    // Si l'utilisateur a confirmé la suppression
    if (confirmDelete == true) {
      try {
        // Effectuer la suppression
        await _serviceService.deleteService(serviceId);

        // Mettre à jour l'état pour recharger la liste des services
        setState(() {
          _services = _serviceService.getServicesAdmin();
        });

        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Service supprimé avec succès'),
            backgroundColor: Color(0xFF00BCD0),
            duration: Duration(seconds: 3),

          ),
        );}catch (e) {
        // Afficher un message d'erreur si la suppression échoue
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur: \${e.toString()}'),
        ));
      }
    }
  }


  Future<void> _updateService(int serviceId) async {
    final service = await _serviceService.getServices().then((services) =>
        services.firstWhere((service) => service.id == serviceId));

    // Naviguer vers la page de mise à jour
    final updatedService = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateServicePage(service: service),
      ),
    );

    if (updatedService != null) {
      setState(() {
        _services = _serviceService.getServicesAdmin();
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Liste des services',
          style: TextStyle(
            color: Colors.black, // Couleur du texte en noir
          ),
        ),
        backgroundColor: Color(0xFF00BCD0).withOpacity(0.88), // Couleur de fond avec opacité de 19%

        automaticallyImplyLeading: false,
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
              child: FutureBuilder<List<Service>>(
                future: _getFilteredServices(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Aucun service trouvé'));
                  } else {
                    final services = snapshot.data!;
                    return ListView.builder(
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.only(bottom: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                                color: Color(0xFF00BCD0), width: 2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: service.imageUrl.isNotEmpty
                                        ? Image.memory(
                                      base64Decode(service.imageUrl),
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
                                    Icon(Icons.title, size: 20,
                                        color: Colors.blue),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        service.titre,
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
                                    Icon(Icons.description, size: 20,
                                        color: Colors.orange),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        service.description,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.timer, size: 20,
                                        color: Colors.green),
                                    SizedBox(width: 8),
                                    Text(
                                      "${service.duree} ",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.attach_money, size: 20,
                                        color: Colors.red),
                                    SizedBox(width: 8),
                                    Text(
                                      service.prix == service.prix.toInt()
                                          ? '${service.prix.toInt()} DT'
                                          : '${service.prix.toStringAsFixed(2)} DT',
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
                                      icon: Icon(Icons.edit, color: Colors.white),
                                      label: Text("Éditer", style: TextStyle(
                                          color: Colors.white)),
                                      onPressed: () =>
                                          _updateService(service.id),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      icon: Icon(Icons.delete, color: Colors.white),
                                      label: Text("Supprimer", style: TextStyle(
                                          color: Colors.white)),
                                      onPressed: () =>
                                          _deleteService(service.id),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF00BCD0),
        onPressed: () async {
          final newService = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddServicePage()),
          );
          if (newService != null) {
            setState(() {
              _services = _serviceService.getServices();
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
