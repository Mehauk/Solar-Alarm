import 'package:flutter/material.dart';
import 'package:solar_alarm/utils/logger.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  List<String> _lines = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final lines = await Logger.readAll();
    setState(() {
      _lines =
          lines
              .split('\n')
              .where((s) => s.trim().isNotEmpty)
              .toList()
              .reversed
              .toList();
      _loading = false;
    });
  }

  Future<void> _clear() async {
    await Logger.clear();
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Logs'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
          IconButton(icon: const Icon(Icons.delete_forever), onPressed: _clear),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _lines.isEmpty
              ? const Center(child: Text('No logs'))
              : ListView.builder(
                itemCount: _lines.length,
                itemBuilder: (context, index) {
                  final line = _lines[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Text(
                      line,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  );
                },
              ),
    );
  }
}
