import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:user_repository/user_repository.dart';
import 'package:kmplace/models/simplestring.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const AccountState()) {
    on<AccountUsernameChanged>(_onUsernameChanged);
    on<AccountFullnameChanged>(_onFullnameChanged);
    on<AccountImageChanged>(_onImageChanged);
    on<AccountSubmitted>(_onSubmitted);
    on<AccountDelete>(_onDelete);
  }

  final AuthenticationRepository _authenticationRepository;

  void _onUsernameChanged(
      AccountUsernameChanged event,
      Emitter<AccountState> emit,
      ) {
    final info = SimpleString.dirty(event.username);
    emit(state.copyWith(
      username: info,
      status: Formz.validate([info, state.fullname, state.image]),
    ));
  }
  void _onFullnameChanged(
      AccountFullnameChanged event,
      Emitter<AccountState> emit,
      ) {
    final info = SimpleString.dirty(event.fullname);
    emit(state.copyWith(
      fullname: info,
      status: Formz.validate([state.username, info, state.image]),
    ));
  }
  void _onImageChanged(
      AccountImageChanged event,
      Emitter<AccountState> emit,
      ) {
    final info = SimpleString.dirty(event.image);
    emit(state.copyWith(
      image: info,
      status: Formz.validate([state.username, state.fullname, info]),
    ));
  }

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
