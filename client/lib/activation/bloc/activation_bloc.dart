import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

part 'activation_event.dart';

part 'activation_state.dart';

class ActivationBloc extends Bloc<ActivationEvent, ActivationState> {
  ActivationBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const ActivationState()) {
    on<ActivationCodeChanged>(_onActivationCodeChanged);
    on<ActivationSubmitted>(_onSubmitted);
    on<ActivationSend>(_onSend);
  }

  final AuthenticationRepository _authenticationRepository;

  void _onActivationCodeChanged(
    ActivationCodeChanged event,
    Emitter<ActivationState> emit,
  ) {
    final activationCode = ActivationCode.dirty(event.activationCode);
    emit(state.copyWith(
      activationCode: activationCode,
      status: Formz.validate([activationCode]),
    ));
  }

  void _onSubmitted(
    ActivationSubmitted event,
    Emitter<ActivationState> emit,
  ) async {
    if (state.status.isValidated) {
      emit(state.copyWith(status: FormzStatus.submissionInProgress));
      try {
        await _authenticationRepository.activate(
          email: event.email,
          password: event.password,
          activation_code: state.activationCode.value,
        );
        emit(state.copyWith(status: FormzStatus.submissionSuccess, type: "activation"));
      } on ActivationException catch (e) {
        emit(state.copyWith(
            status: FormzStatus.submissionFailure, message: "$e", type: "activation"));
      } on SettingException catch (e) {
        emit(state.copyWith(status: FormzStatus.submissionFailure, message: "$e", type: "setting"));
      } on ServiceException catch (e) {
        emit(state.copyWith(status: FormzStatus.submissionFailure, message: "$e", type: "service"));
      } catch (_) {
        emit(state.copyWith(status: FormzStatus.submissionFailure));
      }
    }
  }

  void _onSend(
    ActivationSend event,
    Emitter<ActivationState> emit,
  ) async {
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      await _authenticationRepository.activationSend(
        email: event.email,
        password: event.password,
      );
      emit(state.copyWith(status: FormzStatus.submissionSuccess, type: "send"));
    } on MsgException catch (e) {
      emit(state.copyWith(status: FormzStatus.submissionFailure, message: "$e", type: "msg"));
    } on SettingException catch (e) {
      emit(state.copyWith(status: FormzStatus.submissionFailure, message: "$e", type: "setting"));
    } on ServiceException catch (e) {
      emit(state.copyWith(status: FormzStatus.submissionFailure, message: "$e", type: "service"));
    } catch (_) {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }
}
