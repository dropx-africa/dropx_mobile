import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dropx_mobile/src/core/providers/core_providers.dart';
import 'package:dropx_mobile/src/features/group/data/group_order_repository.dart';
import 'package:dropx_mobile/src/features/group/data/remote_group_order_repository.dart';
import 'package:dropx_mobile/src/features/group/data/dto/group_order_models.dart';

// ── Repository ────────────────────────────────────────────────────────────────

final groupOrderRepositoryProvider = Provider<GroupOrderRepository>((ref) {
  return RemoteGroupOrderRepository(ref.watch(apiClientProvider));
});

// ── Active session state ──────────────────────────────────────────────────────
// Holds the group order ID and participant token for the current session.
// These are set when the host creates a room or a participant joins.

class GroupOrderSession {
  final String groupOrderId;
  final String participantToken;
  final bool isHost;
  final String? inviteUrl;
  final String? vendorId;

  const GroupOrderSession({
    required this.groupOrderId,
    required this.participantToken,
    required this.isHost,
    this.inviteUrl,
    required this.vendorId,
  });
}
final groupOrderSessionProvider =
StateProvider<GroupOrderSession?>((ref) => null);

// ── Room state notifier ───────────────────────────────────────────────────────
// Loads the room and keeps it fresh via SSE. Falls back to manual refresh
// when SSE is unavailable (app backgrounded, weak network, etc).

class GroupOrderNotifier extends AsyncNotifier<GroupOrder?> with WidgetsBindingObserver {
  StreamSubscription<String>? _sseSubscription;
  Timer? _pollTimer;
  @override
  @override
  Future<GroupOrder?> build() async {
    final session = ref.watch(groupOrderSessionProvider);
    if (session == null) return null;

    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() {
      _sseSubscription?.cancel();
      _pollTimer?.cancel();
      WidgetsBinding.instance.removeObserver(this);
    });

    final room = await _loadRoom(session);
    _subscribeToEvents(session);
    return room;
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final session = ref.read(groupOrderSessionProvider);
    if (session == null) return;

    if (state == AppLifecycleState.resumed) {
      _silentRefresh(session);
      _subscribeToEvents(session);
    } else if (state == AppLifecycleState.paused) {
      _sseSubscription?.cancel();
      _pollTimer?.cancel();
    }
  }
  void _subscribeToEvents(GroupOrderSession session) {
    _sseSubscription?.cancel();
    _pollTimer?.cancel(); // cancel any existing poll when SSE reconnects
    _sseSubscription = ref
        .read(groupOrderRepositoryProvider)
        .roomEvents(session.groupOrderId, session.participantToken)
        .listen((eventData) {
      try {
        final json = jsonDecode(eventData) as Map<String, dynamic>;
        if (json['type'] == 'heartbeat') return;
      } catch (_) {}
      _silentRefresh(session);
    },
      onError: (e) {
        debugPrint('📡 [GROUP-SSE] error: $e — starting poll fallback');
        _startPollingFallback(session);
      },
      onDone: () {
        debugPrint('📡 [GROUP-SSE] stream closed — starting poll fallback');
        _startPollingFallback(session);
      },
    );
  }
  void _startPollingFallback(GroupOrderSession session) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 8),
          (_) => _silentRefresh(session),
    );
  }

  Future<void> _silentRefresh(GroupOrderSession session) async {
    try {
      final fresh = await _loadRoom(session);
      if (fresh != null) state = AsyncData(fresh);
    } catch (_) {}
  }

  Future<GroupOrder?> _loadRoom(GroupOrderSession session) async {
    return ref.read(groupOrderRepositoryProvider).getGroupOrder(
      session.groupOrderId,
      session.participantToken,
    );
  }

  /// Force reload room from API (polling fallback or post-action refresh).
  Future<void> refresh() async {
    final session = ref.read(groupOrderSessionProvider);
    if (session == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadRoom(session));
  }

  /// Add item and refresh room.
  /// Add item and refresh room.
  /// Add item and refresh room.
  Future<void> addItem({
    required String itemId,
    required String itemName,
    required double unitPriceKobo,
    required int quantity,
    String? note,
    Map<String, dynamic>? configuration,
  }) async {
    final session = ref.read(groupOrderSessionProvider);
    if (session == null) return;

    // Ensure configuration has the correct structure for the API
    final apiConfiguration = configuration != null && configuration.isNotEmpty
        ? configuration
        : {
      'selected_variant': null,
      'selected_addons': [],
    };

    await ref.read(groupOrderRepositoryProvider).addItem(
      session.groupOrderId,
      session.participantToken,
      itemId: itemId,
      quantity: quantity,
      itemName: itemName,
      unitPriceKobo: unitPriceKobo,
      note: note,
      configuration: apiConfiguration,
    );
    await refresh();
  }


  /// Remove item and refresh room.
  Future<void> removeItem(String groupOrderItemId) async {
    final session = ref.read(groupOrderSessionProvider);
    if (session == null) return;
    await ref.read(groupOrderRepositoryProvider).removeItem(
      session.groupOrderId,
      session.participantToken,
      groupOrderItemId,
    );
    await refresh();
  }

  /// Lock room (host only) and refresh.
  Future<void> lock() async {
    final session = ref.read(groupOrderSessionProvider);
    if (session == null) return;
    await ref.read(groupOrderRepositoryProvider).lockGroupOrder(
      session.groupOrderId,
      session.participantToken,
    );
    await refresh();
  }

  /// Unlock room (host only) — reopens for editing.
  Future<void> unlock() async {
    final session = ref.read(groupOrderSessionProvider);
    if (session == null) return;
    await ref.read(groupOrderRepositoryProvider).unlockGroupOrder(
      session.groupOrderId,
      session.participantToken,
    );
    await refresh();
  }

  /// Cancel group order (host only).
  Future<void> cancel() async {
    final session = ref.read(groupOrderSessionProvider);
    if (session == null) return;
    await ref.read(groupOrderRepositoryProvider).cancelGroupOrder(
      session.groupOrderId,
      session.participantToken,
    );
    await refresh();
  }

  /// Estimate — returns result directly, does not mutate room state.
  /// Estimate — returns result directly, does not mutate room state.
  Future<GroupOrderEstimate> estimate() async {
    final session = ref.read(groupOrderSessionProvider);
    if (session == null) throw Exception('No active group order session');

    final sessionService = ref.read(sessionServiceProvider);

    // Build the request body with delivery address from session
    final body = {
      'delivery_address': sessionService.savedAddress.isNotEmpty
          ? sessionService.savedAddress
          : 'Current Location',
      'delivery_lat': sessionService.savedLat,
      'delivery_lng': sessionService.savedLng,
      'service_tier': 'STANDARD',
    };

    // Add delivery_address_id if you have it (optional)
    // You might need to add this to SessionService if required by API
    // if (sessionService.defaultAddressId.isNotEmpty) {
    //   body['delivery_address_id'] = sessionService.defaultAddressId;
    // }

    debugPrint('📊 Estimate request body: $body',wrapWidth: 1024); // Debug log

    return ref.read(groupOrderRepositoryProvider).estimate(
      session.groupOrderId,
      session.participantToken,
      body: body,
    );
  }

  /// Checkout — returns the created draft order ID.
  /// Checkout — returns the created draft order ID.
  Future<GroupOrderCheckoutResponse> checkout() async {
    final session = ref.read(groupOrderSessionProvider);
    if (session == null) throw Exception('No active group order session');

    final sessionService = ref.read(sessionServiceProvider);

    // Build the request body with delivery address from session
    final body = {
      'delivery_address': sessionService.savedAddress.isNotEmpty
          ? sessionService.savedAddress
          : 'Current Location',
      'delivery_lat': sessionService.savedLat,
      'delivery_lng': sessionService.savedLng,
      'service_tier': 'STANDARD',
    };

    // Add delivery_address_id if available
    // if (sessionService.defaultAddressId.isNotEmpty) {
    //   body['delivery_address_id'] = sessionService.defaultAddressId;
    // }

    return ref.read(groupOrderRepositoryProvider).checkout(
      session.groupOrderId,
      session.participantToken,
      body: body,
    );
  }
}

final groupOrderProvider =
AsyncNotifierProvider<GroupOrderNotifier, GroupOrder?>(
  GroupOrderNotifier.new,
);

// ── Invite preview ────────────────────────────────────────────────────────────

final groupOrderInviteProvider =
FutureProvider.family<GroupOrderInvitePreview, String>((ref, token) {
  return ref.watch(groupOrderRepositoryProvider).previewInvite(token);
});