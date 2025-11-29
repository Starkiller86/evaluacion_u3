import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';

class DeliveryDetailPage extends StatefulWidget {
  final Delivery delivery;

  const DeliveryDetailPage({super.key, required this.delivery});

  @override
  State<DeliveryDetailPage> createState() => _DeliveryDetailPageState();
}

class _DeliveryDetailPageState extends State<DeliveryDetailPage> {
  LatLng? deliveryLatLng;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCoords();
  }

  Future<void> _loadCoords() async {
    try {
      final inputAddress = widget.delivery.destination_address;

      final locations = await locationFromAddress(inputAddress);
      final loc = locations.first;

      setState(() {
        deliveryLatLng = LatLng(loc.latitude, loc.longitude);
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      print("Error geocoding: $e");
    }
  }

  Future<void> openInMaps() async {
    if (deliveryLatLng == null) return;

    final lat = deliveryLatLng!.latitude.toStringAsFixed(6);
    final lon = deliveryLatLng!.longitude.toStringAsFixed(6);

    final url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lon",
    );

    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);

    if (!launched) {
      debugPrint("No se pudo abrir Maps");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Entrega ID ${widget.delivery.id}')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Text(
                    'Dirección: ${widget.delivery.destination_address}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  // MAPA
                  if (deliveryLatLng != null)
                    Expanded(
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: deliveryLatLng!,
                          initialZoom: 16,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: deliveryLatLng!,
                                width: 80,
                                height: 80,
                                child: const Icon(
                                  Icons.location_on,
                                  size: 40,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    const Text("No se pudo obtener la ubicación"),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/photo_page',
                            arguments: {
                              'deliveryId': widget.delivery.id,
                              'deliveryLat': deliveryLatLng?.latitude,
                              'deliveryLon': deliveryLatLng?.longitude,
                            },
                          );
                        },
                        child: const Text('Marcar como entregado'),
                      ),

                      ElevatedButton(
                        onPressed: deliveryLatLng == null ? null : openInMaps,
                        child: const Text("Abrir con Maps"),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
