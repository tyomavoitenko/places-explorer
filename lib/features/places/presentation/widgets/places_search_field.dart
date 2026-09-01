import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/places_bloc.dart';

/// Search box. Dispatches on every keystroke — the debounce lives in
/// [PlacesBloc], so the widget stays dumb.
class PlacesSearchField extends StatefulWidget {
  const PlacesSearchField({super.key});

  @override
  State<PlacesSearchField> createState() => _PlacesSearchFieldState();
}

class _PlacesSearchFieldState extends State<PlacesSearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) =>
      context.read<PlacesBloc>().add(PlacesEvent.searchQueryChanged(value));

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search nearby places',
        prefixIcon: const Icon(Icons.search),
        isDense: true,
        border: const OutlineInputBorder(),
        suffixIcon: ValueListenableBuilder(
          valueListenable: _controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear',
              onPressed: () {
                _controller.clear();
                _onChanged('');
              },
            );
          },
        ),
      ),
    );
  }
}
