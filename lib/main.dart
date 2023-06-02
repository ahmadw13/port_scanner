import 'package:flutter/material.dart';
import 'package:tcp_scanner/tcp_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Port Scanner',
      home: PortScannerScreen(),
    );
  }
}

class PortScannerScreen extends StatefulWidget {
  const PortScannerScreen({Key? key}) : super(key: key);

  @override
  _PortScannerScreenState createState() => _PortScannerScreenState();
}

class _PortScannerScreenState extends State<PortScannerScreen> {
  final _ipController = TextEditingController();
  final _portsController =
      TextEditingController(text: '10-999, 5000, 1100, 1110');

  final String _report = '';
  String _status = '';

  Future<void> _scanPorts() async {
    final host = _ipController.text.trim();
    final ports = _portsController.text
        .split(',')
        .expand((part) => part.contains('-')
            ? Iterable.generate(
                int.parse(part.split('-')[1]) -
                    int.parse(part.split('-')[0]) +
                    1,
                (i) => int.parse(part.split('-')[0]) + i)
            : [int.parse(part)])
        .toList();
    final stopwatch = Stopwatch()..start();

    setState(() => _status = 'Scanning...');

    final report = await TcpScannerTask(
      host,
      ports,
      shuffle: true,
      parallelism: 1,
    ).start();

    setState(() => _status = 'Scan completed\n'
        'Host ${report.host} scan completed\n'
        'Scanned ports:\t${report.ports.length}\n'
        'Open ports:\t${report.openPorts}\n'
        'Elapsed:\t${stopwatch.elapsed}\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Port Scanner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'IP address',
                hintText: 'Enter IP address to scan',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _portsController,
              decoration: const InputDecoration(
                labelText: 'Ports',
                hintText: 'Enter port range to scan (e.g. 10-100, 5000)',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _scanPorts,
              child: const Text('Scan Ports'),
            ),
            const SizedBox(height: 16),
            Text(_status,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text(_report),
          ],
        ),
      ),
    );
  }
}
