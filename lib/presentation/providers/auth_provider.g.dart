// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Handles auth mutations (sign-in, sign-out) as a single entry point for
/// all screens. Screens must never import [AuthService] directly.

@ProviderFor(AuthController)
const authControllerProvider = AuthControllerProvider._();

/// Handles auth mutations (sign-in, sign-out) as a single entry point for
/// all screens. Screens must never import [AuthService] directly.
final class AuthControllerProvider
    extends $AsyncNotifierProvider<AuthController, void> {
  /// Handles auth mutations (sign-in, sign-out) as a single entry point for
  /// all screens. Screens must never import [AuthService] directly.
  const AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();
}

String _$authControllerHash() => r'859275534bdb64f36b99ddd52e2af9edaa512c0f';

/// Handles auth mutations (sign-in, sign-out) as a single entry point for
/// all screens. Screens must never import [AuthService] directly.

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

/// Subscribes to Firebase's real-time auth state.
/// Emits [null] when signed out, a [User] when signed in.

@ProviderFor(authState)
const authStateProvider = AuthStateProvider._();

/// Subscribes to Firebase's real-time auth state.
/// Emits [null] when signed out, a [User] when signed in.

final class AuthStateProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
  /// Subscribes to Firebase's real-time auth state.
  /// Emits [null] when signed out, a [User] when signed in.
  const AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: true,
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

String _$authStateHash() => r'927895b94ff0712062703c206b12f21fe19a0288';

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
