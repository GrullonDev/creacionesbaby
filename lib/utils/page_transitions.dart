import 'package:flutter/material.dart';

/// Smooth page transitions for navigation
class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SmoothPageRoute({required this.page})
    : super(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: Curves.easeInOutCubic));

          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(
              opacity: animation.drive(
                Tween(
                  begin: 0.5,
                  end: 1.0,
                ).chain(CurveTween(curve: Curves.easeIn)),
              ),
              child: child,
            ),
          );
        },
      );
}

/// Fade-only route for modal-like screens
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
    : super(
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
            child: child,
          );
        },
      );
}
