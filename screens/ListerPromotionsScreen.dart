import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/PromotionDTO.dart';
import '../models/ServiceDTO.dart';
import '../services/PromotionService.dart';
import '../services/auth_service.dart';

import 'AjouterPromotionScreen.dart';
import 'EditPromotionScreen.dart';
import 'admin_screen.dart';

class ListerPromotionsScreen extends StatefulWidget {
  @override
  _ListerPromotionsScreenState createState() => _ListerPromotionsScreenState();
}

class _ListerPromotionsScreenState extends State<ListerPromotionsScreen> {
  final PromotionService _promotionService = PromotionService();
  List<PromotionDTO> _promotions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPromotions();
  }

  Future<void> _fetchPromotions() async {
    try {
      List<PromotionDTO> promotions = await _promotionService.getPromotions();
      setState(() {
        _promotions = promotions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erreur: Impossible de récupérer les promotions')),
      );
    }
  }

  Future<void> _deletePromotion(int promotionId) async {
    try {
      await _promotionService.deletePromotion(promotionId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('promotion supprimé'),
          backgroundColor: Color(0xFF00BCD0), // Couleur de fond personnalisée
          duration: Duration(seconds: 3), // Durée d'affichage
          behavior: SnackBarBehavior.floating, // Style flottant
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Coins arrondis
          ),
        ),
      );
      _fetchPromotions(); // Rafraîchir la liste après suppression
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression: $e')),
      );
    }
  }

  String _formatDate(DateTime date) {
    // Fixer l'heure à 23:00 (en interne)
    DateTime newDate = DateTime(date.year, date.month, date.day, 23, 0);

    // Formater uniquement la date (sans l'heure)
    return "${newDate.day.toString().padLeft(2, '0')}-${newDate.month.toString().padLeft(2, '0')}-${newDate.year}";
  }

  // Méthode pour formater la valeur de réduction
  String _formatReduction(double valeurReduction) {
    // Vérifie si la valeur est entière ou décimale
    if (valeurReduction == valeurReduction.toInt()) {
      // Si c'est un nombre entier, l'affiche sans décimales
      return valeurReduction.toInt().toString();
    } else {
      // Si c'est un nombre décimal, remplace le point par une virgule
      return valeurReduction.toStringAsFixed(2).replaceAll('.', ',');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des promotions'),
        backgroundColor: Color(0xFF00BCD0).withOpacity(0.88),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Sidebar(
        authService: AuthService(),
        onSelectPage: (index) {},
        isDarkMode: false,
        toggleTheme: () {},
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _promotions.isEmpty
              ? Center(child: Text('Aucune promotion disponible'))
              : ListView.builder(
                  itemCount: _promotions.length,
                  itemBuilder: (context, index) {
                    final promo = _promotions[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Color(0xFF00BCD0), width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      child: ListTile(
                        title: Row(
                          children: [
                            // Icône pour la réduction
                            SizedBox(width: 8),
                            Expanded(
                              // Pour éviter le débordement si le texte est trop long
                              child: Text(
                                "Réduction: ${_formatReduction(promo.valeurReduction)} (${promo.typeReduction})",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date de début et de fin avec des icônes
                            Row(
                              children: [
                                Icon(Icons.date_range,
                                    color: Colors
                                        .orange), // Icône pour la date de début
                                SizedBox(width: 8),
                                Text(
                                  _formatDate(promo
                                      .dateDebut), // Afficher uniquement la date
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.6),
                                      fontSize: 14),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.date_range,
                                    color: Colors
                                        .red), // Icône pour la date de fin
                                SizedBox(width: 8),
                                Text(
                                  _formatDate(promo
                                      .dateFin), // Afficher uniquement la date
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.6),
                                      fontSize: 14),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),

                            // Affichage des services associés avec une icône moderne simple
                            promo.servicesDTO?.isNotEmpty == true
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.build,
                                              color: Colors
                                                  .blueAccent), // Icône des services
                                          SizedBox(width: 8),
                                          Text(
                                            'Services associés:',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      ...promo.servicesDTO!.map((service) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          child: Row(
                                            children: [
                                              Icon(Icons.check_circle,
                                                  color: Color(
                                                      0xFF00BCD0)), // Icône pour chaque service
                                              SizedBox(width: 8),
                                              Expanded(
                                                // Pour éviter que le texte dépasse
                                                child: Text(
                                                  service.titre,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  )
                                : Text(
                                    "Aucun service associé", // Message si aucun service n'est associé
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                  ),
                            SizedBox(height: 8),

                            // Affichage du code promo, si disponible
                            if (promo.codePromo?.isNotEmpty ?? false) ...[
                              Row(
                                children: [
                                  Icon(Icons.card_giftcard,
                                      color: Colors
                                          .red), // Icône cadeau pour le code promo
                                  SizedBox(width: 8),
                                  Text(
                                    "Code Promo: ${promo.codePromo}",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Bouton d'édition
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditPromotionScreen(promotion: promo),
                                  ),
                                );

                                if (result == true) {
                                  _fetchPromotions();
                                }
                              },
                            ),
                            // Bouton de suppression
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
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
                                            Icon(Icons.warning_amber_rounded,
                                                color: Colors.redAccent,
                                                size: 80),
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
                                              'Êtes-vous sûr de vouloir supprimer cette promotion ?',
                                              style: TextStyle(fontSize: 16),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(false); // Annuler
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.grey,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 20,
                                                            vertical: 12),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Annuler',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop(
                                                        true); // Confirmer la suppression
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.redAccent,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 20,
                                                            vertical: 12),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    'Supprimer',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.white),
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

                                // Si l'utilisateur confirme la suppression, on appelle _deletePromotion
                                if (confirmDelete == true) {
                                  _deletePromotion(promo.id);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AjouterPromotionScreen()),
          );

          if (result == true) {
            _fetchPromotions();
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Color(0xFF00BCD0),
      ),
    );
  }
}
