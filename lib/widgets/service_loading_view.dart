import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../providers/app_language_provider.dart';

class ServiceLoadingView extends StatefulWidget {
  const ServiceLoadingView({
    super.key,
    required this.serviceName,
    required this.icon,
  });

  final String serviceName;
  final IconData icon;

  @override
  State<ServiceLoadingView> createState() => _ServiceLoadingViewState();
}

class _ServiceLoadingViewState extends State<ServiceLoadingView>
    with TickerProviderStateMixin {
  late final AnimationController _orbitController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
      lowerBound: 0.96,
      upperBound: 1.04,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 156,
              height: 156,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  RotationTransition(
                    turns: _orbitController,
                    child: Container(
                      width: 148,
                      height: 148,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.primary.withOpacity(0.13),
                          width: 1.5,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            color: colors.secondary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colors.secondary.withOpacity(0.35),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  ScaleTransition(
                    scale: _pulseController,
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colors.primaryContainer,
                            colors.primaryContainer.withOpacity(0.55),
                          ],
                        ),
                        border: Border.all(
                          color: colors.primary.withOpacity(0.16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withOpacity(0.12),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        size: 44,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              '${context.tr('Loading')} ${context.tr(widget.serviceName)}',
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('Connecting to the service...'),
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 112,
              child: AnimatedBuilder(
                animation: _orbitController,
                builder: (context, child) {
                  final phase = _orbitController.value * math.pi * 2;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final opacity =
                          (0.32 + 0.68 * (1 + math.sin(phase - index)) / 2)
                              .clamp(0.0, 1.0)
                              .toDouble();
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Opacity(
                          opacity: opacity,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: colors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
