/// Runtime client configuration fetched from `/integration/client-config`.
///
/// Drives maintenance mode display, feature gates, and branded error behavior
/// without requiring an app update.
class ClientConfig {
  const ClientConfig({
    required this.maintenanceEnabled,
    required this.maintenanceMode,
    required this.maintenanceMessage,
    required this.maintenanceSupportUrl,
    required this.groupOrdersEnabled,
    required this.socialFeedEnabled,
    required this.contactSyncEnabled,
    required this.brandedErrorsRequired,
  });

  /// `maintenance.enabled` — true when the backend is intentionally down.
  final bool maintenanceEnabled;

  /// `maintenance.mode` — one of: `normal`, `maintenance`, `degraded`, `read_only`.
  final String maintenanceMode;

  /// Human-readable maintenance message to show users.
  final String maintenanceMessage;

  /// Support URL shown on the maintenance screen.
  final String maintenanceSupportUrl;

  /// `features.group_orders` — gate group-order CTAs and routes.
  final bool groupOrdersEnabled;

  /// `features.social_feed` — gate social feed entry points and routes.
  /// Defaults to false: backend-supported but customer UI must remain gated
  /// until product approves the surface.
  final bool socialFeedEnabled;

  /// `features.contact_sync` — gate contact sync entry points and routes.
  /// Defaults to false: contact permission must never be requested when disabled.
  final bool contactSyncEnabled;

  /// `error_experience.branded_errors_required` — use DropX-branded error pages.
  final bool brandedErrorsRequired;

  bool get isFullMaintenance => maintenanceMode == 'maintenance';
  bool get isDegraded => maintenanceMode == 'degraded';
  bool get isReadOnly => maintenanceMode == 'read_only';
  bool get isNormal => maintenanceMode == 'normal' || maintenanceMode.isEmpty;

  /// Safe fallback when the config fetch fails — keeps the app functional.
  /// Social feed and contact sync default to false so they stay gated even
  /// when the config endpoint is temporarily unreachable.
  static const ClientConfig defaults = ClientConfig(
    maintenanceEnabled: false,
    maintenanceMode: 'normal',
    maintenanceMessage: '',
    maintenanceSupportUrl: '',
    groupOrdersEnabled: true,
    socialFeedEnabled: false,
    contactSyncEnabled: false,
    brandedErrorsRequired: true,
  );

  factory ClientConfig.fromJson(Map<String, dynamic> json) {
    final maintenance = json['maintenance'] as Map<String, dynamic>? ?? {};
    final features = json['features'] as Map<String, dynamic>? ?? {};
    final errorExp = json['error_experience'] as Map<String, dynamic>? ?? {};
    return ClientConfig(
      maintenanceEnabled: maintenance['enabled'] == true,
      maintenanceMode: maintenance['mode'] as String? ?? 'normal',
      maintenanceMessage: maintenance['message'] as String? ?? '',
      maintenanceSupportUrl: maintenance['support_url'] as String? ?? '',
      groupOrdersEnabled: features['group_orders'] != false,
      // Social feed and contact sync are opt-in: only enable when explicitly true.
      socialFeedEnabled: features['social_feed'] == true,
      contactSyncEnabled: features['contact_sync'] == true,
      brandedErrorsRequired: errorExp['branded_errors_required'] != false,
    );
  }
}
