import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';
import 'test_reservation_screen.dart';

class TestEventScreen extends StatefulWidget {
  @override
  _TestEventScreenState createState() => _TestEventScreenState();
}

class _TestEventScreenState extends State<TestEventScreen> {
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();
  final TextEditingController capacityCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthController>(context, listen: false);
      final eventController = Provider.of<EventController>(context, listen: false);
      if (auth.user != null) {
        eventController.loadEventsByOrganizer(auth.user!.uid);
      } else {
        eventController.loadEvents();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final eventController = Provider.of<EventController>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Événements')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (auth.user != null)
              Column(
                children: [
                  TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'Titre')),
                  TextField(controller: descCtrl, decoration: InputDecoration(labelText: 'Description')),
                  TextField(controller: locationCtrl, decoration: InputDecoration(labelText: 'Lieu')),
                  TextField(controller: capacityCtrl, decoration: InputDecoration(labelText: 'Capacité'), keyboardType: TextInputType.number),
                  TextField(controller: priceCtrl, decoration: InputDecoration(labelText: 'Prix (0 pour gratuit)'), keyboardType: TextInputType.number),
                  ElevatedButton(
                    onPressed: () async {
                      final event = Event(
                        id: '',
                        title: titleCtrl.text,
                        description: descCtrl.text,
                        date: selectedDate,
                        location: locationCtrl.text,
                        imageUrl: null,
                        capacity: int.parse(capacityCtrl.text),
                        price: double.parse(priceCtrl.text),
                        organizerId: auth.user!.uid,
                        createdAt: DateTime.now(),
                      );
                      await eventController.addEvent(event);
                      eventController.loadEventsByOrganizer(auth.user!.uid);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Événement ajouté')));
                    },
                    child: Text('Ajouter événement'),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            Expanded(
              child: eventController.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: eventController.events.length,
                      itemBuilder: (ctx, i) {
                        final e = eventController.events[i];
                        return Card(
                          child: ListTile(
                            title: Text(e.title),
                            subtitle: Text('${e.date} - ${e.price == 0 ? "Gratuit" : "${e.price} FC"}'),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TestReservationScreen(event: e),
                                  ),
                                );
                              },
                              child: Text('Réserver'),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    locationCtrl.dispose();
    capacityCtrl.dispose();
    priceCtrl.dispose();
    super.dispose();
  }
}