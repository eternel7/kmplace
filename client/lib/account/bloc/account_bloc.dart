import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:user_repository/user_repository.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const AccountState()) {
    on<AccountSubmitted>(_onSubmitted);
    on<AccountDelete>(_onDelete);
  }

  final AuthenticationRepository _authenticationRepository;

  void _onSubmitted(
    AccountSubmitted event,
    Emitter<AccountState> emit,
  ) async {
    if (state.status.isValidated) {
      emit(state.copyWith(status: FormzStatus.submissionInProgress));
      try {
        emit(state.copyWith(status: FormzStatus.submissionSuccess));
      } catch (e) {
        emit(state.copyWith(status: FormzStatus.submissionFailure, message: "$e", type: "account"));
      }
    }
  }

  void _onDelete(
    AccountDelete event,
    Emitter<AccountState> emit,
  ) async {
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    try {
      emit(state.copyWith(status: FormzStatus.submissionSuccess, type: "send"));
    } catch (_) {
      emit(state.copyWith(status: FormzStatus.submissionFailure));
    }
  }
}
