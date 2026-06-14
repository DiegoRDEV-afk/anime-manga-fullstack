import 'package:flutter/material.dart';

class ExploreFilters extends StatelessWidget {
  const ExploreFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        DropdownButtonFormField(
          decoration: const InputDecoration(
            labelText: 'Estado',
          ),
          items: const [],
          onChanged: (_) {},
        ),

        const SizedBox(height: 15),

        DropdownButtonFormField(
          decoration: const InputDecoration(
            labelText: 'Tipo',
          ),
          items: const [],
          onChanged: (_) {},
        ),

        const SizedBox(height: 15),

        DropdownButtonFormField(
          decoration: const InputDecoration(
            labelText: 'Géneros',
          ),
          items: const [],
          onChanged: (_) {},
        ),
      ],
    );
  }
}