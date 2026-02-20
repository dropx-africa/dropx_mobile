import 'package:flutter/material.dart';

/// Centralised navigation helper for consistent routing throughout the app.
///
/// All methods delegate to [Navigator] named-routes so the physical back
/// button still triggers standard [pop] behaviour.
class AppNavigator {
  AppNavigator._();

  /// Push a named route onto the stack.
  static Future<T?> push<T>(
    BuildContext context,
    String route, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, route, arguments: arguments);
  }

  /// Pop the current route off the stack.
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  /// Replace the current route with a named route.
  static Future<T?> pushReplacement<T, TO>(
    BuildContext context,
    String route, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.pushReplacementNamed<T, TO>(
      context,
      route,
      arguments: arguments,
      result: result,
    );
  }

  /// Push a named route and remove all previous routes.
  static Future<T?> pushAndRemoveAll<T>(
    BuildContext context,
    String route, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      route,
      (route) => false,
      arguments: arguments,
    );
  }
}
