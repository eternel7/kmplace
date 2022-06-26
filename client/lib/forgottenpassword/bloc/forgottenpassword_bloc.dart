import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '/forgottenpassword/forgottenpassword.dart';
import 'package:formz/formz.dart';

part 'forgottenpassword_event.dart';

part 'forgottenpassword_state.dart';

class ForgottenPasswordBloc extends Bloc<ForgottenPasswordEvent, ForgottenPasswordState> {
  ForgottenPasswordBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const ForgottenPasswordState()) {
    on<ForgottenPasswordEmailChanged>(_onEmailChanged);
    on<ForgottenPasswordSubmitted>(_onSubmitted);
  }

  final AuthenticationRepository _authenticationRepository;

  void _onEmailChanged(
      ForgottenPasswordEmailChanged event,
    Emitter<ForgottenPasswordState> emit,
  ) {
    final email = Email.dirty(event.email);
    emit(state.copyWith(
      email: email,
      status: Formz.validate([email]),
    ));
  }

  void _onSubmitted(
    ForgottenPasswordSubmitted event,
    Emitter<ForgottenPasswordState> emit,
  ) async {
    if (state.status.isValidated) {
      emit(state.copyWith(status: FormzStatus.submissionInProgress));
      try {
        await _authenticationRepository.forgottenPassword(
          email: state.email.value,
        );
        emit(state.copyWith(status: FormzStatus.submissionSuccess));
      } catch (_) {
        emit(state.copyWith(status: FormzStatus.submissionFailure));
      }
    }
  }
}
