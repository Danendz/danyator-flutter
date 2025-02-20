import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MyApp());
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
  late TabController _tabController;
  late TextEditingController htmlController;
  late TextEditingController cssController;
  late TextEditingController jsController;
  final List<LogEntry> logs = [];
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    htmlController = TextEditingController(text: "<h1>Hello, Flutter!</h1>");
    cssController = TextEditingController(text: "h1 { color: blue; }");
    jsController = TextEditingController(text: "console.log('Hello from JS');");

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
    htmlController.dispose();
    cssController.dispose();
    jsController.dispose();
    super.dispose();
  }

  void runCode() {
    String htmlContent = htmlController.text;
    String cssContent = cssController.text;
    String jsContent = jsController.text;

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
    <script>
      $jsContent
    </script>
    $overrideConsoleScript
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
                            child: TextField(
                              controller: htmlController,
                              maxLines: null,
                              expands: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "HTML",
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: cssController,
                              maxLines: null,
                              expands: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "CSS",
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: jsController,
                              maxLines: null,
                              expands: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "JavaScript",
                              ),
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
                    margin: const EdgeInsets.all(0.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: WebViewWidget(controller: _webViewController),
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
