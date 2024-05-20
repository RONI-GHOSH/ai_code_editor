part of 'judge_bloc.dart';


abstract class JudgeState extends Equatable {
  const JudgeState();

  @override
  List<Object> get props => [];
}

class JudgeInitial extends JudgeState {}

class JudgeLoading extends JudgeState {}

class LanguagesLoaded extends JudgeState {
  final List<Language> languages;

  const LanguagesLoaded(this.languages);

  @override
  List<Object> get props => [languages];
}

class SubmissionSuccess extends JudgeState {
  final String token;

  const SubmissionSuccess(this.token);

  @override
  List<Object> get props => [token];
}

class SubmissionResult extends JudgeState {
  final String stdout;
  final String stderr;
  final String compile_output;

  const SubmissionResult(this.stdout, this.stderr, this.compile_output);

  @override
  List<Object> get props => [stdout, stderr];
}

class JudgeError extends JudgeState {
  final String message;

  const JudgeError(this.message);

  @override
  List<Object> get props => [message];
}

class AiResponse extends JudgeState {
  final String modified_code;

  AiResponse({required this.modified_code});
}

class JudgeProcessing extends JudgeState {}

