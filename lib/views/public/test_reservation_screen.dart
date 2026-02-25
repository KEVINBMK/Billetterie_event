// lib/views/public/test_reservation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/event_controller.dart';
import '../../controllers/reservation_controller.dart';
import '../../models/event_model.dart';
import '../participant/ticket_screen.dart';

class TestReservationScreen extends StatefulWidget {
  final Event event;
  const TestReservationScreen({Key? key, required this.event}) : super(key: key);

  @override
  _TestReservationScreenState createState() => _TestReservationScreenState();
}

class _TestReservationScreenState extends State<TestReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  int _ticketsCount = 1;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final reservationController = Provider.of<ReservationController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('Réservation pour ${event.title}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Prix : ${event.price == 0 ? "Gratuit" : "${event.price} FC"}'),
              Text('Places disponibles : ${event.capacity}'),
              SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nom complet *'),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email *'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              if (event.price > 0)
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Numéro Mobile Money *'),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('Nombre de tickets :'),
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: _ticketsCount > 1
                        ? () => setState(() => _ticketsCount--)
                        : null,
                  ),
                  Text('$_ticketsCount'),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _ticketsCount < event.capacity
                        ? () => setState(() => _ticketsCount++)
                        : null,
                  ),
                ],
              ),
              SizedBox(height: 30),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isLoading = true);
                          final success = await reservationController.createReservation(
                            event: event,
                            participantName: _nameController.text,
                            participantEmail: _emailController.text,
                            participantPhone: event.price > 0 ? _phoneController.text : null,
                            ticketsCount: _ticketsCount,
                          );
                          setState(() => _isLoading = false);

                          if (success) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TicketScreen(reservation: reservationController.lastReservation!),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Échec de la réservation. Vérifie tes informations.')),
                            );
                          }
                        }
                      },
                      child: Text(event.price > 0 ? 'Payer et réserver' : 'Réserver gratuitement'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}