import 'package:flutter/material.dart';

class FilterOption {
  final String value;
  final String title;
  final String subtitle;

  const FilterOption({
    required this.value,
    required this.title,
    required this.subtitle,
  });
}

class FilterStrip extends StatelessWidget {
  final String sortValue;
  final Function(String value) onChanged;
  final List<FilterOption> filters;

  const FilterStrip({
    super.key,
    required this.sortValue,
    required this.onChanged,
    required this.filters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: Row(
        children: [
          _buildChip(
            context: context,
            label: 'Default',
            isSelected: sortValue == filters.first.value,
            iconSelected: Icons.check_rounded,
            iconUnselected: Icons.filter_alt_rounded,
            onTap: () => onChanged(filters.first.value),
          ),
          const SizedBox(width: 8),
          _buildChip(
            context: context,
            label: 'Filter',
            isSelected: sortValue != filters.first.value,
            iconSelected: Icons.check_rounded,
            iconUnselected: Icons.filter_list_rounded,
            onTap: () => _openFilterDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required IconData iconSelected,
    required IconData iconUnselected,
    required VoidCallback onTap,
  }) {
    final color = Theme.of(context).colorScheme;

    return RawChip(
      backgroundColor:
          isSelected ? color.secondaryContainer : color.surfaceContainer,
      side: BorderSide.none,
      labelStyle: TextStyle(color: color.onPrimaryContainer),
      iconTheme: IconThemeData(color: color.onPrimaryContainer),
      onPressed: onTap,
      avatar: Icon(isSelected ? iconSelected : iconUnselected),
      label: Text(label),
    );
  }

  void _openFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Filters',
            style: TextStyle(fontFamily: 'ClashGrotesk'),
          ),
          contentPadding: const EdgeInsets.all(0),
          content: SizedBox(
            height: 260,
            child: SingleChildScrollView(
              child: Column(
                children: filters.map((filter) {
                  return ListTile(
                    leading: Radio<String>(
                      value: filter.value,
                      groupValue: sortValue,
                      onChanged: (val) {
                        onChanged(val!);
                        Navigator.pop(context);
                      },
                    ),
                    title: Text(filter.title),
                    subtitle: Text(filter.subtitle),
                    onTap: () {
                      onChanged(filter.value);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
