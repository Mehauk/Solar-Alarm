import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_alarm/data/services/log_service.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  late final Logger _logger = context.read();

  List<String> _lines = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() async {
    setState(() => _loading = true);
    final lines = _logger.history();
    setState(() {
      _lines = lines;
      _loading = false;
    });
  }

  void _clear() async {
    _logger.clear();
    _refresh();
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
