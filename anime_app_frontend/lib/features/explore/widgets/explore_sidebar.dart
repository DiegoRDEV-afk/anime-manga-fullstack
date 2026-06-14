import 'package:flutter/material.dart';
import 'explore_filters.dart';

class ExploreSidebar extends StatelessWidget {
  const ExploreSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "EXPLORAR",
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const SizedBox(height: 30),

          TextField(
            decoration: InputDecoration(
              hintText: "Buscar por nombre",
            ),
          ),

          const SizedBox(height: 20),

          ExploreFilters(),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {},
            child: const Text("Buscar"),
          )
        ],
      ),
    );
  }
}