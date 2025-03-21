import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/user.dart';
import '../services/EquipeService.dart';
import '../services/auth_service.dart';
import 'admin_screen.dart';

class AddEquipeScreen extends StatefulWidget {
  @override
  _AddEquipeScreenState createState() => _AddEquipeScreenState();
}

class _AddEquipeScreenState extends State<AddEquipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final EquipeService equipeService = EquipeService();
  final AuthService _authService = AuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? role;

  get hintText => null; // Role is initially null

  void _showToast(String message, {Color? color}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: color ?? Colors.red,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      appBar: AppBar(title: Text('Ajouter Membre'),   centerTitle: true,
        backgroundColor: Color(0xFF00BCD0).withOpacity(0.88),),
      drawer: Sidebar(
        authService: AuthService(),
        onSelectPage: (index) {},
        isDarkMode: false,
        toggleTheme: () {},
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildInputField('Nom du membre', _usernameController, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nom d\'utilisateur requis';
                  } else if (value.length < 3 || value.length > 50) {
                    return 'Le nom d\'utilisateur doit comporter entre 3 et 50 caractères';
                  }
                  return null;
                }),
                SizedBox(height: 16),
                _buildInputField('Email', _emailController, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email requis';
                  } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(value)) {
                    return 'Adresse email invalide';
                  }
                  return null;
                }),
                SizedBox(height: 16),
                _buildInputField('Numéro de téléphone', _phoneController, (value) {
                  if (value == null || value.isEmpty) {
                    return 'Numéro de téléphone requis';
                  } else if (!RegExp(r"^[0-9]{8}$").hasMatch(value)) {
                    return 'Le numéro de téléphone doit comporter exactement 8 chiffres';
                  }
                  return null;
                }),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: role,
                  onChanged: (value) {
                    setState(() {
                      role = value;
                    });
                  },
                  items: ['ADMIN', 'TECHNICIEN']
                      .map((role) => DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  ))
                      .toList(),
                  decoration: InputDecoration(labelText: 'Rôle', contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF00BCD0)), // Couleur de la ligne quand désactivé
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF00BCD0), width: 2), // Couleur de la ligne quand en focus
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF00BCD0)), // Bordure par défaut
                      )),
                  validator: (value) {
                    if (value == null) {
                      return 'Veuillez sélectionner un rôle';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF00BCD0),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (role == null) {
                          _showToast('Veuillez sélectionner un rôle');
                          return;
                        }

                        // Validate email and phone for uniqueness
                        bool emailExists = await _authService.checkEmail(_emailController.text);
                        bool phoneExists = await _authService.checkPhone(_phoneController.text);
                        if (emailExists) {
                          _showToast('Cet email est déjà utilisé. Veuillez en choisir un autre.');
                          return;
                        }
                        if (phoneExists) {
                          _showToast('Ce numéro de téléphone est déjà utilisé. Veuillez en choisir un autre.');
                          return;
                        }

                        User newUser = User(
                          username: _usernameController.text,
                          email: _emailController.text,
                          phone: _phoneController.text,
                          role: role!,
                        );

                        equipeService.addUser(newUser).then((_) {
                          // Afficher un AlertDialog pour informer de l'ajout réussi
                          showDialog(
                            context: context,
                            builder: (context) {
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
                                        Icons.check_circle_outline,
                                        color: Color(0xFF00BCD0),
                                        size: 80,
                                      ),
                                      SizedBox(height: 20),
                                      Text(
                                        'Succès',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF00BCD0),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Le membre a été ajouté avec succès!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context); // Ferme le dialog
                                          Navigator.pop(context, true); // Retourne à la page précédente
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF00BCD0),
                                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                        child: Text(
                                          'OK',
                                          style: TextStyle(fontSize: 18, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        });
                      }
                    },
                    child: Text('Ajouter'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
      String label, TextEditingController controller, String? Function(String?) validator) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label,hintText: hintText,
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00BCD0)), // Couleur de la ligne quand désactivé
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00BCD0), width: 2), // Couleur de la ligne quand en focus
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00BCD0)), // Bordure par défaut
        ),),
      validator: validator,
    );
  }
}
