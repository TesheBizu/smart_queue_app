import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/ticket_provider.dart';

class ProviderScreen extends ConsumerWidget {
  const ProviderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(ticketsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Provider Dashboard"),
        centerTitle: true,
      ),
      body: ticketsAsync.when(
        data: (tickets) {
          final inService =
              tickets.where((t) => t.status == "in_service").toList();
          final called =
              tickets.where((t) => t.status == "called").toList();

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("🟢 In Service",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                const SizedBox(height: 10),

                ...inService.map((t) => Card(
                      child: ListTile(
                        title: Text("Ticket #${t.number}"),
                        trailing: ElevatedButton(
                          onPressed: () {
                            // TODO: finish ticket
                          },
                          child: const Text("Finish"),
                        ),
                      ),
                    )),

                const SizedBox(height: 20),

                const Text("🟡 Waiting (Called)",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                const SizedBox(height: 10),

                ...called.map((t) => Card(
                      child: ListTile(
                        title: Text("Ticket #${t.number}"),
                        trailing: ElevatedButton(
                          onPressed: () {
                            // TODO: claim ticket
                          },
                          child: const Text("Start"),
                        ),
                      ),
                    )),
              ],
            ),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}