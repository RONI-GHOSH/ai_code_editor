import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:judge0_api_app/features/code_editor/data/model/language.model.dart';
import 'package:judge0_api_app/features/code_editor/data/model/submission.model.dart';

part 'judge_event.dart';
part 'judge_state.dart';

class JudgeBloc extends Bloc<JudgeEvent, JudgeState> {
  final String baseUrl = 'https://judge0-extra-ce.p.rapidapi.com';

  JudgeBloc() : super(JudgeInitial()) {
    on<LoadLanguages>(_onLoadLanguages);
    on<SubmitCode>(_onSubmitCode);
    on<GenerateAIOutPut>(_onGenerateAIOutPut);
  }

  Future<void> _onLoadLanguages(
      LoadLanguages event, Emitter<JudgeState> emit) async {
    try {
      emit(JudgeLoading());
      final response =
          await http.get(Uri.parse('$baseUrl/languages'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'content-type': 'application/json',
        'X-RapidAPI-Key': '275d5fb451msha4d8c58626ccf27p1a6688jsn62b6427cb1cf',
        'X-RapidAPI-Host': 'judge0-extra-ce.p.rapidapi.com',
      });
      if (response.statusCode == 200) {
        final List<dynamic> languagesJson = json.decode(response.body);
        final languages = languagesJson
            .map((languageJson) => Language.fromJson(languageJson))
            .toList();
        emit(LanguagesLoaded(languages));
      } else {
        emit(const JudgeError('Failed to load languages'));
      }
    } catch (error) {
      emit(JudgeError('Failed to load languages: $error'));
    }
  }

  Future<void> _onSubmitCode(SubmitCode event, Emitter<JudgeState> emit) async {
    try {
      emit(JudgeLoading());
      final response = await http.post(
        Uri.parse('$baseUrl/submissions'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'content-type': 'application/json',
          'X-RapidAPI-Key':
              '275d5fb451msha4d8c58626ccf27p1a6688jsn62b6427cb1cf',
          'X-RapidAPI-Host': 'judge0-extra-ce.p.rapidapi.com',
        },
        body: json.encode({
          'source_code': event.sourceCode,
          'language_id': event.languageId,
          'stdin': event.stdin,
          'command_line_arguments': event.args
        }),
      );

      print('submission response body: ${response.body}');

      if (response.statusCode == 201) {
        final submission = Submission.fromJson(json.decode(response.body));
        emit(SubmissionSuccess(submission.token));
        await _checkSubmissionStatus(submission.token, emit);
      } else {
        emit(const JudgeError('Failed to submit code'));
      }
    } catch (error) {
      emit(JudgeError('Failed to submit code: $error'));
    }
  }

  Future<void> _checkSubmissionStatus(
      String token, Emitter<JudgeState> emit) async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      final response =
          await http.get(Uri.parse('$baseUrl/submissions/$token'), headers: {
        'X-RapidAPI-Key': '275d5fb451msha4d8c58626ccf27p1a6688jsn62b6427cb1cf',
        'X-RapidAPI-Host': 'judge0-extra-ce.p.rapidapi.com'
      });

      print('submission status response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final status = result['status']['id'];
        if (status == 1 || status == 2) {
          return await _checkSubmissionStatus(token, emit);
        }
        emit(SubmissionResult(result['stdout'] ?? '', result['stderr'] ?? '',
            result['compile_output'] ?? ''));
      } else {
        emit(const JudgeError('Failed to fetch submission result'));
      }
    } catch (error) {
      emit(JudgeError('Failed to fetch submission result: $error'));
    }
  }

  FutureOr<void> _onGenerateAIOutPut(
      GenerateAIOutPut event, Emitter<JudgeState> emit) async {
    final gemini = Gemini.instance;

    var response =await gemini
        .text("You have beed integrated in a code editor / ide as an ai code asistant , heres some context of the code : user prompot to you for aisistant with code - ${event.prompt} , user written code is - ${event.sourceCode} , user stdin (input to the prograam if needed is - ${event.stdin}), and command line arrguments when runnig the programme if needed is - ${event.args}.user ran the programme (null or empty values indicate user dosen't run the programme yet) then the output is - ${event.output} and if output conatins error then the error is - ${event.err} and the compile output is - ${event.compile_output}. you have to generate or modify or explain (in comments)  the code with comments that will be directly inserted to to users code editor (make sure your response doesn't contain any special characters that will be interpreted by the code editor or the language syntax provided) , if your response contain any plain text like then make htem commented in the code respective to the language (provided in user written source code) syntax. ");
    emit(AiResponse(modified_code: '${response?.output}'));
   
  }
}
