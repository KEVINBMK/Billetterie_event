import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/event.dart';
import '../../core/services/firestore_service.dart';
import '../../core/state/auth_state.dart';
import '../../core/widgets/likita_app_bar.dart';

class OrganizerEventFormScreen extends StatefulWidget {
  const OrganizerEventFormScreen({super.key, this.eventId});

  final String? eventId;

  @override
  State<OrganizerEventFormScreen> createState() =>
      _OrganizerEventFormScreenState();
}

class _OrganizerEventFormScreenState extends State<OrganizerEventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _capacityController = TextEditingController(text: '100');
  final _priceController = TextEditingController(text: '0');
  DateTime _date = DateTime.now().add(const Duration(days: 7));
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) _loadEvent();
  }

  Future<void> _loadEvent() async {
    final firestore = context.read<FirestoreService>();
    final event = await firestore.getEventById(widget.eventId!);
    if (event != null && mounted) {
      setState(() {
        _titleController.text = event.title;
        _descController.text = event.description;
        _locationController.text = event.location;
        _capacityController.text = '${event.capacity}';
        _priceController.text = '${event.priceCfa}';
        _date = event.dateTime;
        _imageUrl = event.imageUrl;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final firestore = context.read<FirestoreService>();
    final isEdit = widget.eventId != null;

    return Scaffold(
      appBar: LikitaAppBar(
        title: isEdit ? 'Modifier l\'événement' : 'Nouvel événement',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                maxLines: 3,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Lieu',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(
                  '${_date.day}/${_date.month}/${_date.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacité',
                  prefixIcon: Icon(Icons.people_outline),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requis';
                  if (int.tryParse(v) == null || int.parse(v) < 1) {
                    return 'Nombre invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Prix (USD), 0 = gratuit',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Requis';
                  if (int.tryParse(v) == null || int.parse(v) < 0) {
                    return 'Nombre invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _imageUrl,
                decoration: const InputDecoration(
                  labelText: 'URL image (optionnel)',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
                onChanged: (v) => _imageUrl = v,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final title = _titleController.text.trim();
                  final description = _descController.text.trim();
                  final location = _locationController.text.trim();
                  final capacity = int.parse(_capacityController.text.trim());
                  final priceCfa = int.tryParse(_priceController.text.trim()) ?? 0;
                  final organizerId = auth.user?.id ?? '';
                  final organizerName = auth.user?.displayName ?? '';

                  try {
                    if (isEdit) {
                      await firestore.updateEvent(widget.eventId!, {
                        'title': title,
                        'description': description,
                        'location': location,
                        'capacity': capacity,
                        'priceCfa': priceCfa,
                        'date': Timestamp.fromDate(_date),
                        'imageUrl': _imageUrl,
                      });
                    } else {
                      await firestore.createEvent(
                        title: title,
                        description: description,
                        date: _date,
                        location: location,
                        imageUrl: _imageUrl,
                        capacity: capacity,
                        priceCfa: priceCfa,
                        organizerId: organizerId,
                        organizerName: organizerName,
                      );
                    }
                    if (context.mounted) context.go('/dashboard');
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur: $e')),
                      );
                    }
                  }
                },
                child: Text(isEdit ? 'Enregistrer' : 'Créer l\'événement'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
