import 'package:flutter_bloc/flutter_bloc.dart';
import '../firebase/firebase_service.dart';

// Events
abstract class AuthEvent {}
class CheckAuthStatus extends AuthEvent {}
class SignInWithGoogle extends AuthEvent {}
class SignOutUser extends AuthEvent {}

// States
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class Authenticated extends AuthState {
  final String userId;
  final String? email;
  Authenticated({required this.userId, this.email});
}
class Unauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignInWithGoogle>(_onSignInWithGoogle);
    on<SignOutUser>(_onSignOutUser);
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    final user = FirebaseService.currentUser;
    if (user != null) {
      emit(Authenticated(userId: user.uid, email: user.email));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignInWithGoogle(SignInWithGoogle event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final user = await FirebaseService.signInWithGoogle();
    if (user != null) {
      emit(Authenticated(userId: user.uid, email: user.email));
    } else {
      emit(AuthError('Google ile giriş başarısız'));
    }
  }

  Future<void> _onSignOutUser(SignOutUser event, Emitter<AuthState> emit) async {
    await FirebaseService.signOut();
    emit(Unauthenticated());
  }
}