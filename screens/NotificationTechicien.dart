import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/NotificationsService.dart';
import '../models/technician_notification.dart';

class NotificationScreen extends StatelessWidget {
  final String email;

  const NotificationScreen({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ChangeNotifierProvider(
        create: (context) => NotificationProvider(email: email),
        child: Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (provider.notifications.isEmpty) {
              return Center(child: Text('Aucune notification disponible.'));
            } else {
              return RefreshIndicator(
                onRefresh: provider.fetchNotifications, // Ajout du rafraîchissement
                child: ListView.builder(
                  itemCount: provider.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = provider.notifications[index];
                    return ListTile(
                      title: Text(notification.message),
                      subtitle: Text(
                        "Envoyé le ${notification.dateEnvoi}",
                        style: TextStyle(color: Colors.grey),
                      ),
                      trailing: notification.isRead
                          ? Icon(Icons.done, color: Colors.green)
                          : IconButton(
                        icon: Icon(Icons.mark_as_unread, color: Colors.red),
                        onPressed: () {
                          provider.markAsRead(notification.id);
                        },
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class NotificationProvider with ChangeNotifier {
  final String email;
  List<TechnicianNotification> _notifications = [];
  bool _isLoading = true;
  final NotificationService _service = NotificationService('http://10.0.2.2:8085');

  NotificationProvider({required this.email}) {
    fetchNotifications();
  }

  List<TechnicianNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  Future<void> fetchNotifications() async {
    try {
      _isLoading = true;
      notifyListeners();

      final fetchedNotifications = await _service.getNotifications();
      print("📩 Notifications reçues : $fetchedNotifications"); // 🔥 Vérification

      _notifications = fetchedNotifications;

    } catch (e) {
      print("❌ Erreur : $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> markAsRead(int notificationId) async {
    try {
      await _service.markNotificationAsRead(notificationId);
      await fetchNotifications(); // Rafraîchir après mise à jour
    } catch (e) {
      print("Erreur lors de la mise à jour de la notification : $e");
    }
  }
}
