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
    on<ForgottenPasswordCodeChanged>(_onCodeChanged);
    on<ForgottenPasswordPasswordChanged>(_onPasswordChanged);
    on<ForgottenPasswordConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<ForgottenPasswordAskCode>(_onAskForCode);
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
      status: Formz.validate(
          [email, state.forgottenPasswordCode, state.password, state.confirmPassword]),
    ));
  }

  void _onCodeChanged(
    ForgottenPasswordCodeChanged event,
    Emitter<ForgottenPasswordState> emit,
  ) {
    final forgottenPasswordCode = ForgottenPasswordCode.dirty(event.forgottenPasswordCode);
    emit(state.copyWith(
      forgottenPasswordCode: forgottenPasswordCode,
      status: Formz.validate([state.email, forgottenPasswordCode]),
    ));
  }

  void _onPasswordChanged(
    ForgottenPasswordPasswordChanged event,
    Emitter<ForgottenPasswordState> emit,
  ) {
    final password = Password.dirty(event.password);
    final confirmPassword =
        ConfirmedPassword.dirty(password: password.value, value: state.confirmPassword.value);
    emit(state.copyWith(
      password: password,
      confirmPassword: confirmPassword,
      status: Formz.validate([state.email, state.forgottenPasswordCode, password, confirmPassword]),
    ));
  }

  void _onConfirmPasswordChanged(
    ForgottenPasswordConfirmPasswordChanged event,
    Emitter<ForgottenPasswordState> emit,
  ) {
    final confirmPassword =
        ConfirmedPassword.dirty(password: state.password.value, value: event.confirmPassword);
    emit(state.copyWith(
      confirmPassword: confirmPassword,
      status: Formz.validate(
          [state.email, state.forgottenPasswordCode, state.password, confirmPassword]),
    ));
  }

  void _onAskForCode(
    ForgottenPasswordAskCode event,
    Emitter<ForgottenPasswordState> emit,
  ) async {
    if (state.email.value.isNotEmpty) {
      emit(state.copyWith(status: FormzStatus.submissionInProgress));
      try {
        await _authenticationRepository.forgottenPasswordCodeSend(
          email: state.email.value,
        );
        emit(state.copyWith(status: FormzStatus.submissionSuccess, type: "send"));
      } catch (_) {
        emit(state.copyWith(status: FormzStatus.submissionFailure));
      }
    }
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
          code: state.forgottenPasswordCode.value,
          password: state.password.value,
          confirmPassword: state.confirmPassword.value,
        );
        emit(state.copyWith(status: FormzStatus.submissionSuccess));
      } on ActivationException catch (e) {
        emit(state.copyWith(status: FormzStatus.submissionFailure, message: "$e", type: "activation"));
      } on MsgException catch (e) {
        emit(state.copyWith(status: FormzStatus.submissionFailure, message: "$e", type: "msg"));
      } on SettingException catch (e) {
        emit(state.copyWith(status: FormzStatus.submissionFailure, message: "$e", type: "setting"));
      } on ServiceException catch (e) {
        emit(state.copyWith(status: FormzStatus.submissionFailure, message: "$e", type: "service"));
      } catch (_) {
        print(_);
        emit(state.copyWith(status: FormzStatus.submissionFailure));
      }
    }
  }
}
