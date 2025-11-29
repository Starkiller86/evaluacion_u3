import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class DeliveriesPage extends StatefulWidget {
  const DeliveriesPage({super.key});
  @override
  State<DeliveriesPage> createState() => _DeliveriesPageState();
}

class _DeliveriesPageState extends State<DeliveriesPage> {
  final api = ApiService();
  late Future<List<Delivery>> futureList;

  @override
  void initState() {
    super.initState();
    futureList = api.getDeliveries();
  }

  Future<void> _refresh() async {
    setState(() {
      futureList = api.getDeliveries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entregas asignadas'),
        actions: [
          IconButton(onPressed: () async { await api.clearToken(); Navigator.pushReplacementNamed(context, '/login'); }, icon: const Icon(Icons.logout))
        ],
      ),
      body: FutureBuilder<List<Delivery>>(
        future: futureList,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          final list = snap.data ?? [];
          if (list.isEmpty) return Center(child: Text('No hay entregas asignadas'));
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, i) {
                final d = list[i];
                return ListTile(
                  title: Text('ID ${d.id} - ${d.destination_address}'),
                  subtitle: Text('Destinatario: ${d.recipient} - Entregado: ${d.delivered}'),
                  trailing: ElevatedButton(
                    child: const Text('Abrir'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/delivery_detail', arguments: {'delivery': d}).then((_) => _refresh());
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
