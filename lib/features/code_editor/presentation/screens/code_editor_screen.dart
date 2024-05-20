import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_highlight/themes/dracula.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/plaintext.dart';
import 'package:judge0_api_app/features/code_editor/bloc/judge_bloc.dart';
import 'package:judge0_api_app/features/code_editor/data/model/language.model.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:xterm/xterm.dart';
import 'dart:html' as html;

class CodeEditorScreen extends StatefulWidget {
  @override
  _CodeEditorScreenState createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen> {
  final terminal = Terminal(
    maxLines: 10000,
  );
  final _codeController = CodeController(
    language: java,
    text: '''public class Main {
    public static void main(String[] args) {
        System.out.println("Hello");
    }
}
''',
  );
  final terminalController = TerminalController();
  final _stdinController = CodeController(
    language: plaintext,
  );
  final _argsController = TextEditingController();
  final _aiPrompt = TextEditingController();
  Language? _selectedLanguage;
  String _result = '';
  String _err = '';
  String _compileOutput = '';
  bool _isInput = false;
  int _fontSize = 14;
  @override
  void initState() {
    super.initState();
    terminal.write('output\$:');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Judge0 BLoC Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
                flex: 8,
                child: Row(children: [
                  Expanded(
                    flex: 7,
                    child: SizedBox(
                      height: double.infinity,
                      child: CodeTheme(
                        data: const CodeThemeData(styles: draculaTheme),
                        child:
                            CodeField(wrap: true, controller: _codeController),
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            _tabSwitcher(),
                            _isInput
                                ? Column(children: [
                                    CodeField(
                                        maxLines: 16,
                                        minLines: 15,
                                        wrap: true,
                                        background: Colors.transparent,
                                        lineNumbers: true,
                                        controller: _stdinController),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: _argsController,
                                      decoration: const InputDecoration(
                                        hintText: 'Commnd Line Arguments',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ])
                                : BlocBuilder<JudgeBloc, JudgeState>(
                                    builder: (context, state) {
                                      if (state is JudgeLoading) {
                                        return const CircularProgressIndicator();
                                      } else if (state is LanguagesLoaded) {
                                        return DropdownButton<Language>(
                                          hint: const Text('Select Language'),
                                          value: _selectedLanguage,
                                          onChanged: (Language? newValue) {
                                            setState(() {
                                              _selectedLanguage = newValue;
                                            });
                                          },
                                          items: state.languages
                                              .map((Language language) {
                                            return DropdownMenuItem<Language>(
                                              value: language,
                                              child: Text(language.name),
                                            );
                                          }).toList(),
                                        );
                                      } else if (state is JudgeError) {
                                        return Text('Error: ${state.message}');
                                      }
                                      return Container();
                                    },
                                  ),
                            const SizedBox(
                              height: 16,
                            ),
                            if (!_isInput)   const SizedBox(height: 10),
                            if (!_isInput) 
                            TextField(
                              controller: _aiPrompt,
                              decoration: const InputDecoration(
                                hintText: 'eg.Fix this code , explain logs..',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: ShadButton.secondary(
                                    width: double.infinity,
                                    text: const Text('🪄 Explain with AI '),
                                    onPressed: () {
                                     
                                      BlocProvider.of<JudgeBloc>(context).add(GenerateAIOutPut(prompt:  _aiPrompt.text,sourceCode:  _codeController.text,stdin: _stdinController.text,args:  _argsController.text,output:  _result,err:  _err,compile_output:  _compileOutput));
                                      _aiPrompt.text = "Running ai.....";
                                       setState(() {});
                                    },
                                  )),
                                  Expanded(
                                      child: ShadButton.destructive(
                                    width: double.infinity,
                                    icon: const Icon(Icons.clear),
                                    text: const Text('Clear All'),
                                    onPressed: () {
                                      _codeController.clear();
                                      _stdinController.clear();
                                      _argsController.clear();
                                      terminal.deleteLines(10);
                                      terminal.write('output\$:');
                                    },
                                  ))
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: ShadButton(
                                  width: double.infinity,
                                  icon: const Icon(Icons.download),
                                  onPressed: () {
                                    downloadTextFile(
                                        _codeController.text, 'code.txt');
                                  },
                                  text: const Text('Download'),
                                )),
                                Expanded(
                                  child: ShadButton(
                                    backgroundColor: Colors.deepPurple,
                                    width: double.infinity,
                                    icon: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      if (_selectedLanguage != null) {
                                        BlocProvider.of<JudgeBloc>(context).add(
                                          SubmitCode(
                                            sourceCode: _codeController.text,
                                            stdin: _stdinController.text,
                                            languageId: _selectedLanguage!.id,
                                          ),
                                        );
                                      }
                                    },
                                    text: const Text(
                                      'Run code',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ))
                ])),
            const SizedBox(height: 10),
            Expanded(
              flex: 2,
              child: TerminalView(
                terminal,
                controller: terminalController,
                autofocus: true,
                backgroundOpacity: 0.5,
                onSecondaryTapDown: (details, offset) async {
                  final selection = terminalController.selection;
                  if (selection != null) {
                    final text = terminal.buffer.getText(selection);
                    terminalController.clearSelection();
                    await Clipboard.setData(ClipboardData(text: text));
                  } else {
                    final data = await Clipboard.getData('text/plain');
                    final text = data?.text;
                    if (text != null) {
                      terminal.paste(text);
                    }
                  }
                },
              ),
            ),
            BlocListener<JudgeBloc, JudgeState>(
                child: Container(),
                listener: (context, state) {
                  if (state is JudgeLoading) {
                  } else if (state is SubmissionResult) {
                    _result = state.stdout;
                    _err = state.stderr;
                    _compileOutput = state.compile_output;
                    terminal.write(state.stdout);
                    terminal.cursorNextLine(1);
                    terminal.write(state.stderr);
                    terminal.cursorNextLine(1);
                    terminal.write(state.compile_output);
                    
                  } else if(state is AiResponse){
                    _result = state.modified_code;
                    _codeController.text += '''//Modified new code by AI ${state.modified_code}''';
                    _aiPrompt.text = 'eg.Fix this code , explain logs..';
                    setState(() {});
           
                  
                  }
                  
                  
                   else if (state is JudgeError) {
                    terminal.write(state.message);
                  }
                }),
          ],
        ),
      ),
    );
  }

  Widget _tabSwitcher() {
    return SizedBox(
      width: double.infinity,
      child: Row(children: [
        ShadButton.ghost(
          text: const Text('Actions'),
          onPressed: () {
            setState(() {
              _isInput = false;
            });
          },
        ),
        Container(
          color: Colors.grey,
          width: 0.5,
          height: 20,
        ),
        ShadButton.ghost(
          text: const Text('Input'),
          onPressed: () {
            setState(() {
              _isInput = true;
            });
          },
        )
      ]),
    );
  }

  void downloadTextFile(String text, String filename) {
    // Convert text to Blob
    final blob = html.Blob([text]);

    // Create an object URL from the Blob
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create an anchor element
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", filename)
      ..style.display = 'none';

    // Append anchor to the body
    html.document.body!.children.add(anchor);

    // Trigger download
    anchor.click();

    // Remove anchor from the body
    html.document.body!.children.remove(anchor);

    // Revoke the object URL to free up memory
    html.Url.revokeObjectUrl(url);
  }
}