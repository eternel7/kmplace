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
        String username = state.username.value.isEmpty ? event.user.username : state.username.value;
        String fullname = state.fullname.value.isEmpty ? event.user.fullname : state.fullname.value;
        String image = state.image.value.isEmpty ? event.user.image : state.image.value;
        await _authenticationRepository.updateUserAdditionalInfo(
          email: event.user.email,
          username: username,
          fullname: fullname,
          image: image,
        );
        User user = User(
            event.user.id, event.user.email, username, fullname, image, event.user.login_counts);
        emit(state.copyWith(status: FormzStatus.submissionSuccess, user: user, type: "done"));
      } on SettingException catch (e) {
        emit(state.copyWith(status: FormzStatus.submissionFailure, message: "$e", type: "setting"));
      } on AuthenticationException catch (e) {
        emit(state.copyWith(
            status: FormzStatus.submissionFailure, message: "$e", type: "authentication"));
      } catch (e) {
        emit(state.copyWith(status: FormzStatus.submissionFailure, message: "$e", type: "unknown"));
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
