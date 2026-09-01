import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_failure.dart';
import '../../../../core/location/location_service.dart';
import '../bloc/places_bloc.dart';

/// Icon + message + optional retry, on a translucent scrim so it stays readable
/// when stacked over the map.
class CenteredMessage extends StatelessWidget {
  const CenteredMessage({
    required this.icon,
    required this.text,
    this.onRetry,
    super.key,
  });

  final IconData icon;
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: scheme.surface.withValues(alpha: 0.88),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: scheme.outline),
              const SizedBox(height: 12),
              Text(text, textAlign: TextAlign.center),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Location-permission / services-off failure. Offers: open settings, retry the
/// location flow, or fall back to an approximate location.
class LocationFailureView extends StatelessWidget {
  const LocationFailureView({required this.failure, super.key});

  final LocationFailure failure;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bloc = context.read<PlacesBloc>();

    return ColoredBox(
      color: scheme.surface.withValues(alpha: 0.88),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_disabled, size: 48, color: scheme.outline),
              const SizedBox(height: 12),
              Text(failure.message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  if (failure.canOpenSettings)
                    FilledButton.tonal(
                      onPressed: () => bloc.add(
                        const PlacesEvent.locationSettingsRequested(),
                      ),
                      child: const Text('Open settings'),
                    ),
                  OutlinedButton(
                    onPressed: () => bloc.add(const PlacesEvent.started()),
                    child: const Text('Try again'),
                  ),
                  TextButton(
                    onPressed: () => bloc.add(
                      PlacesEvent.locationChanged(kFallbackLocation),
                    ),
                    child: const Text('Use approximate location'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
