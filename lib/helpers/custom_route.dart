import 'package:flutter/material.dart';
// Custom route with simple fade in transition animation. We use this in app_drawer.dart wen navigating to orders screen
// You can override all page transitions by defining it in the main.dart theme: props

// The <T> represents the data the page resolves to once the screen pops off
class CustomRoute<T> extends MaterialPageRoute<T> {
  // Forward to parent class, materialpageroute, super() forwards this data so this works just with MaterialPageRoute
  CustomRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  // Controls how the page transition is animated
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Checks if it's the first inital page loading
    if (settings.isInitialRoute) {
      return child;
    }
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

// Used for overriding the whole theme of page transitions
class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Checks if it's the first inital page loading
    if (route.settings.isInitialRoute) {
      return child;
    }
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
