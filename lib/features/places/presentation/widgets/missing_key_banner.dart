import 'package:flutter/material.dart';

/// Shown when the app was built without `GEOAPIFY_API_KEY`, so the API calls
/// would fail with an opaque 401. Only rendered in that case.
class MissingKeyBanner extends StatelessWidget {
  const MissingKeyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.key_off, size: 20, color: scheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No Geoapify API key. Run with '
                '--dart-define-from-file=dart_define.json (see README).',
                style: TextStyle(color: scheme.onErrorContainer, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
