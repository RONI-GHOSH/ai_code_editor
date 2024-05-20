part of 'judge_bloc.dart';



abstract class JudgeEvent extends Equatable {
  const JudgeEvent();

  @override
  List<Object> get props => [];
}

class LoadLanguages extends JudgeEvent {}

class SubmitCode extends JudgeEvent {
  final String sourceCode;
  final int languageId;
  final String stdin;
  final String args;

  const SubmitCode(
      {required this.sourceCode, required this.languageId, this.stdin ='' ,this.args = ''});

  @override
  List<Object> get props => [sourceCode, languageId, stdin];


}

class GenerateAIOutPut extends JudgeEvent {
  final String prompt;
  final String sourceCode;
  final String stdin;
  final String args;
  final String output;
  final String err;
  final String compile_output;

  const GenerateAIOutPut({required this.prompt, required this.sourceCode, required this.stdin, required this.args, required this.output, required this.err, required this.compile_output});

}
