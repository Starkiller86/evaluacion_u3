import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';

class PhotoPage extends StatefulWidget {
  final int deliveryId;
  final double? deliveryLat;
  final double? deliveryLon;

  const PhotoPage({
    super.key,
    required this.deliveryId,
    required this.deliveryLat,
    required this.deliveryLon,
  });

  @override
  State<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  XFile? _picked;
  final ImagePicker picker = ImagePicker();
  bool uploading = false;
  final api = ApiService();
  double? lat;
  double? lon;
  final descController = TextEditingController();

  Future<void> takePhoto() async {
    final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (file != null) {
      setState(() => _picked = file);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto tomada')));
    }
  }

  Future<void> getLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      lat = pos.latitude;
      lon = pos.longitude;
    });
  }

  double calculateDistanceMeters() {
    if (widget.deliveryLat == null || widget.deliveryLon == null || lat == null || lon == null) {
      return 99999;
    }

    return Geolocator.distanceBetween(
      widget.deliveryLat!,
      widget.deliveryLon!,
      lat!,
      lon!,
    );
  }

  Future<void> upload() async {
    if (_picked == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Toma una foto primero')));
      return;
    }
    if (lat == null || lon == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Obtén ubicación primero')));
      return;
    }

    final distance = calculateDistanceMeters();
    if (distance > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estás demasiado lejos del punto de entrega (${distance.toStringAsFixed(1)} mts).')),
      );
      return;
    }

    setState(() => uploading = true);
    try {
      await api.markDelivered(
        deliveryId: widget.deliveryId,
        photo: File(_picked!.path),
        lat: lat!,
        lon: lon!,
        description: descController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entrega registrada')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evidencia de entrega')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _picked == null ? const Text('No hay foto') : Image.file(File(_picked!.path), height: 250),
            const SizedBox(height: 8),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Descripción')),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(onPressed: takePhoto, child: const Text('Tomar foto')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: getLocation, child: const Text('Obtener ubicación')),
              ],
            ),
            const SizedBox(height: 8),
            if (lat != null && lon != null) Text('Lat: $lat, Lon: $lon'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: uploading ? null : upload,
              child: uploading ? const CircularProgressIndicator() : const Text('Subir y marcar entregado'),
            ),
          ],
        ),
      ),
    );
  }
}
