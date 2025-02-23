import 'dart:convert';
import 'package:danyator/widgets/editor/editors/css_editor.dart';
import 'package:danyator/widgets/editor/editors/html_editor.dart';
import 'package:danyator/widgets/editor/editors/js_editor.dart';
import 'package:danyator/widgets/editor/notifiers/code_theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'package:danyator/enums/available_languages.dart';
import 'package:danyator/widgets/editor/languages_code_content.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CodeThemeNotifier(),
      child: MyApp()
    )
  );
}

class LogEntry {
  final String type;
  final String message;
  final String timestamp;

  LogEntry(
      {required this.type, required this.message, required this.timestamp});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Code Runner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late LanguagesCodeContent codeInput;
  late TabController _tabController;
  final List<LogEntry> logs = [];
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    codeInput = LanguagesCodeContent();
    _tabController = TabController(length: 3, vsync: this);

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            debugPrint('Finished loading: $url');
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final Map<String, dynamic> data = jsonDecode(message.message);
            String type = data['type'];
            String msg = data['message'].toString();
            setState(() {
              logs.add(LogEntry(
                type: type,
                message: msg,
                timestamp: TimeOfDay.now().format(context),
              ));
            });
          } catch (e) {
            // Handle error if message format is unexpected
          }
        },
      );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void runCode() {
    String htmlContent = codeInput.getLangContent(AvailableLanguages.html);

    String cssContent = codeInput.getLangContent(AvailableLanguages.css);
    String jsContent = codeInput.getLangContent(AvailableLanguages.js);

    // JavaScript to override console functions and send messages back via FlutterChannel
    String overrideConsoleScript = """
    <script>
      (function() {
        var oldLog = console.log;
        var oldError = console.error;
        var oldWarn = console.warn;
        console.log = function(message) {
          FlutterChannel.postMessage(JSON.stringify({type: 'log', message: message}));
          oldLog.apply(console, arguments);
        };
        console.error = function(message) {
          FlutterChannel.postMessage(JSON.stringify({type: 'error', message: message}));
          oldError.apply(console, arguments);
        };
        console.warn = function(message) {
          FlutterChannel.postMessage(JSON.stringify({type: 'warn', message: message}));
          oldWarn.apply(console, arguments);
        };
      })();
    </script>
    """;

    String fullContent = """
    $htmlContent
    <style>$cssContent</style>
    $overrideConsoleScript
    <script>
      $jsContent
    </script>
    """;

    _webViewController.loadHtmlString(fullContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Code Runner'),
      ),
      body: Row(
        children: [
          // Left: Code Editors
          Expanded(
              flex: 1,
              child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(text: 'HTML'),
                        Tab(text: 'CSS'),
                        Tab(text: 'JS'),
                      ],
                    ),
                    Expanded(
                      flex: 1,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:HTMLEditor(
                                initialCode: codeInput.getLangContent(AvailableLanguages.html),
                                onCodeChanged: (String code) => codeInput.setContent(language: AvailableLanguages.html, input: code)
                            )
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CSSEditor(
                              initialCode: codeInput.getLangContent(AvailableLanguages.css),
                              onCodeChanged: (String code) => codeInput.setContent(language: AvailableLanguages.css, input: code)
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: JSEditor(
                                initialCode: codeInput.getLangContent(AvailableLanguages.js),
                                onCodeChanged: (String code) => codeInput.setContent(language: AvailableLanguages.js, input: code)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
              )
          ),
          // Right: Preview and Logs
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Run Button
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: ElevatedButton(
                    onPressed: runCode,
                    child: Text("Run Code"),
                  ),
                ),
                // WebView Preview
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(15.0)
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
                        const Radius.circular(15.0)
                      ),
                      child: WebViewWidget(controller: _webViewController),
                    )
                  ),
                ),
                // Logs Console
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView.separated(
                      itemCount: logs.length,
                      separatorBuilder: (context, index) => Divider(),
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        return Text("[${log.timestamp}] (${log.type}) ${log
                            .message}");
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
