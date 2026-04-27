import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/landmark.dart';
import '../bloc/landmark_bloc.dart';
import '../bloc/landmark_event.dart';
import '../bloc/landmark_state.dart';

class ProposeLandmarkPage extends StatefulWidget {
  const ProposeLandmarkPage({super.key});

  @override
  State<ProposeLandmarkPage> createState() => _ProposeLandmarkPageState();
}

class _ProposeLandmarkPageState extends State<ProposeLandmarkPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  LandmarkCategory _selectedCategory = LandmarkCategory.other;

  double? _userLat;
  double? _userLng;
  double? _landmarkLat;
  double? _landmarkLng;
  bool _gettingLocation = false;

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserLocation() async {
    setState(() => _gettingLocation = true);
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      setState(() {
        _userLat = pos.latitude;
        _userLng = pos.longitude;
        _landmarkLat = pos.latitude;
        _landmarkLng = pos.longitude;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo obtener la ubicación GPS')),
        );
      }
    } finally {
      setState(() => _gettingLocation = false);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_userLat == null || _landmarkLat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Se requiere ubicación GPS')),
      );
      return;
    }

    context.read<LandmarkBloc>().add(ProposeLandmarkEvent(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          latitude: _landmarkLat!,
          longitude: _landmarkLng!,
          userLatitude: _userLat!,
          userLongitude: _userLng!,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proponer Landmark')),
      body: BlocConsumer<LandmarkBloc, LandmarkState>(
        listener: (context, state) {
          if (state is LandmarkProposed) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Landmark propuesto! Ya está en votación.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state is LandmarkError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del lugar',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().length < 3) {
                        return 'Mínimo 3 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                    validator: (v) {
                      if (v == null || v.trim().length < 10) {
                        return 'Mínimo 10 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<LandmarkCategory>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                    ),
                    items: LandmarkCategory.values
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.label),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                  const SizedBox(height: 16),
                  if (_gettingLocation)
                    const Center(child: CircularProgressIndicator())
                  else if (_userLat != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ubicación del landmark:\n'
                              '${_landmarkLat!.toStringAsFixed(6)}, '
                              '${_landmarkLng!.toStringAsFixed(6)}\n'
                              '(Debes estar a menos de 50m)',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: _fetchUserLocation,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Obtener ubicación'),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state is LandmarkLoading ? null : _submit,
                      child: state is LandmarkLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Proponer landmark'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
