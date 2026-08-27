// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// True when the sign-out was explicitly triggered by the user.
/// When the auth stream transitions to signed-out while this is false,
/// [AppRouter] treats it as an involuntary logout (e.g. account disabled)
/// and shows an explanatory message.

@ProviderFor(VoluntarySignOut)
const voluntarySignOutProvider = VoluntarySignOutProvider._();

/// True when the sign-out was explicitly triggered by the user.
/// When the auth stream transitions to signed-out while this is false,
/// [AppRouter] treats it as an involuntary logout (e.g. account disabled)
/// and shows an explanatory message.
final class VoluntarySignOutProvider
    extends $NotifierProvider<VoluntarySignOut, bool> {
  /// True when the sign-out was explicitly triggered by the user.
  /// When the auth stream transitions to signed-out while this is false,
  /// [AppRouter] treats it as an involuntary logout (e.g. account disabled)
  /// and shows an explanatory message.
  const VoluntarySignOutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'voluntarySignOutProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$voluntarySignOutHash();

  @$internal
  @override
  VoluntarySignOut create() => VoluntarySignOut();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$voluntarySignOutHash() => r'f9a86d27d35a5dfee0654a2f1698c9b22506aa74';

/// True when the sign-out was explicitly triggered by the user.
/// When the auth stream transitions to signed-out while this is false,
/// [AppRouter] treats it as an involuntary logout (e.g. account disabled)
/// and shows an explanatory message.

abstract class _$VoluntarySignOut extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Handles auth mutations (sign-in, sign-out) as a single entry point for
/// all screens. Screens must never import [AuthService] directly.
/// keepAlive: Auth-Zustand muss über den gesamten App-Lebenszyklus bestehen.

@ProviderFor(AuthController)
const authControllerProvider = AuthControllerProvider._();

/// Handles auth mutations (sign-in, sign-out) as a single entry point for
/// all screens. Screens must never import [AuthService] directly.
/// keepAlive: Auth-Zustand muss über den gesamten App-Lebenszyklus bestehen.
final class AuthControllerProvider
    extends $AsyncNotifierProvider<AuthController, void> {
  /// Handles auth mutations (sign-in, sign-out) as a single entry point for
  /// all screens. Screens must never import [AuthService] directly.
  /// keepAlive: Auth-Zustand muss über den gesamten App-Lebenszyklus bestehen.
  const AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();
}

String _$authControllerHash() => r'73577612a7c4b4ddd8b5d6e5c018a527c54ebf66';

/// Handles auth mutations (sign-in, sign-out) as a single entry point for
/// all screens. Screens must never import [AuthService] directly.
/// keepAlive: Auth-Zustand muss über den gesamten App-Lebenszyklus bestehen.

abstract class _$AuthController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}

/// Persists completion of the device-local onboarding flow.

@ProviderFor(OnboardingController)
const onboardingControllerProvider = OnboardingControllerProvider._();

/// Persists completion of the device-local onboarding flow.
final class OnboardingControllerProvider
    extends $AsyncNotifierProvider<OnboardingController, void> {
  /// Persists completion of the device-local onboarding flow.
  const OnboardingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingControllerHash();

  @$internal
  @override
  OnboardingController create() => OnboardingController();
}

String _$onboardingControllerHash() =>
    r'86db4ac0fa372bd4e25111199ccd894f137a9933';

/// Persists completion of the device-local onboarding flow.

abstract class _$OnboardingController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}

/// Subscribes to Firebase's real-time auth state.
/// Emits [null] when signed out, a [User] when signed in.
/// keepAlive: Stream darf nie unterbrochen werden, da Routing darauf basiert.

@ProviderFor(authState)
const authStateProvider = AuthStateProvider._();

/// Subscribes to Firebase's real-time auth state.
/// Emits [null] when signed out, a [User] when signed in.
/// keepAlive: Stream darf nie unterbrochen werden, da Routing darauf basiert.

final class AuthStateProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
  /// Subscribes to Firebase's real-time auth state.
  /// Emits [null] when signed out, a [User] when signed in.
  /// keepAlive: Stream darf nie unterbrochen werden, da Routing darauf basiert.
  const AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<User?> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'717511aaf372cc1336681b0d5d9a60ee40e1fa23';

/// Returns whether the user has completed the onboarding flow at least once.

@ProviderFor(seenOnboarding)
const seenOnboardingProvider = SeenOnboardingProvider._();

/// Returns whether the user has completed the onboarding flow at least once.

final class SeenOnboardingProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Returns whether the user has completed the onboarding flow at least once.
  const SeenOnboardingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'seenOnboardingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seenOnboardingHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return seenOnboarding(ref);
  }
}

String _$seenOnboardingHash() => r'5fa7a229f1b99a0d9223e7c2a3486ea92ab9a415';

/// Public API for other features to get the current user's id — the Auth
/// feature is the sole owner of this. Other features' repositories watch
/// this instead of touching Auth's data layer directly.

@ProviderFor(currentUserId)
const currentUserIdProvider = CurrentUserIdProvider._();

/// Public API for other features to get the current user's id — the Auth
/// feature is the sole owner of this. Other features' repositories watch
/// this instead of touching Auth's data layer directly.

final class CurrentUserIdProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Public API for other features to get the current user's id — the Auth
  /// feature is the sole owner of this. Other features' repositories watch
  /// this instead of touching Auth's data layer directly.
  const CurrentUserIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserIdHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return currentUserId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentUserIdHash() => r'bf0c3288a8ba46c2dbd77015c61125dc151c15a1';
