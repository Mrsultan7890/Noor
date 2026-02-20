import 'package:flutter/material.dart';
import '../../services/names_service.dart';

class NamesScreen extends StatefulWidget {
  const NamesScreen({super.key});

  @override
  State<NamesScreen> createState() => _NamesScreenState();
}

class _NamesScreenState extends State<NamesScreen> {
  final NamesService _service = NamesService();
  List<Map<String, String>> _names = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNames();
  }

  Future<void> _loadNames() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final names = await _service.get99Names();
      setState(() {
        _names = names;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('99 Names of Allah - اسماء الحسنیٰ')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadNames, child: const Text('Retry')),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _names.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final name = _names[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(name['number']!, style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(
                          name['name']!,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              name['transliteration']!,
                              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              name['meaning']!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}
