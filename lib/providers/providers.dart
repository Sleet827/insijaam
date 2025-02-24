import 'package:nebulon/models/channel.dart';
import 'package:nebulon/models/guild.dart';
import 'package:nebulon/models/user.dart';
import 'package:nebulon/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// final apiServiceProvider = Provider<ApiService>((ref) => ApiService(ref: ref));

class ApiServiceNotifier extends StateNotifier<AsyncValue<ApiService>> {
  ApiServiceNotifier(this.ref) : super(AsyncValue.loading());

  final Ref ref;

  void initialize(String token) {
    try {
      final service = ApiService(ref: ref, token: token);
      state = AsyncValue.data(service);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final apiServiceProvider =
    StateNotifierProvider<ApiServiceNotifier, AsyncValue<ApiService>>(
      (ref) => ApiServiceNotifier(ref),
    );

final messageEventStreamProvider = StreamProvider<MessageEvent>((ref) {
  return ref
      .watch(apiServiceProvider)
      .when(
        data: (apiService) => apiService.messageEventStream,
        loading: () => const Stream.empty(),
        error: (err, stack) => Stream.error(err, stack),
      );
});

final connectedUserProvider = StreamProvider<UserModel>((ref) {
  return ref
      .watch(apiServiceProvider)
      .when(
        data: (apiService) => apiService.currentUserStream,
        loading: () => const Stream.empty(),
        error: (err, stack) => Stream.error(err, stack),
      );
});

final guildsProvider = StateProvider<List<GuildModel>>((ref) => []);
final selectedGuildProvider = StateProvider<GuildModel?>((ref) => null);

class SelectedChannelNotifier extends StateNotifier<ChannelModel?> {
  SelectedChannelNotifier() : super(null);

  void set(ChannelModel? newChannel) {
    state = newChannel;
  }
}

final selectedChannelProvider =
    StateNotifierProvider<SelectedChannelNotifier, ChannelModel?>(
      (ref) => SelectedChannelNotifier(),
    );

// final selectedChannelProvider = StateProvider<ChannelModel?>((ref) => null);

final hasDrawerProvider = StateProvider<bool>((ref) => false);
final sidebarWidthProvider = StateProvider<double>((ref) => 320);
final sidebarCollapsedProvider = StateProvider<bool>((ref) => false);
final menuCollapsedProvider = Provider.autoDispose(
  (ref) => !ref.watch(hasDrawerProvider) && ref.watch(sidebarCollapsedProvider),
);
