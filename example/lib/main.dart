import 'package:flutter/material.dart';
import 'package:zettle/zettle.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zettle Plugin Example',
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const ZettleExamplePage(),
    );
  }
}

class ZettleExamplePage extends StatefulWidget {
  const ZettleExamplePage({super.key});

  @override
  State<ZettleExamplePage> createState() => _ZettleExamplePageState();
}

class _ZettleExamplePageState extends State<ZettleExamplePage> {
  final _uuid = const Uuid();
  final _logs = <_LogEntry>[];

  // SDK credentials
  final _iosClientIdController = TextEditingController(
    text: const String.fromEnvironment(
      'ZETTLE_IOS_CLIENT_ID',
      defaultValue: '',
    ),
  );
  final _androidClientIdController = TextEditingController(
    text: const String.fromEnvironment(
      'ZETTLE_ANDROID_CLIENT_ID',
      defaultValue: '',
    ),
  );
  final _redirectUrlController = TextEditingController(
    text: const String.fromEnvironment('ZETTLE_REDIRECT_URL', defaultValue: ''),
  );

  // Payment fields
  final _amountController = TextEditingController(text: '1.00');
  bool _enableTipping = false;
  bool _enableInstalments = false;
  bool _enableLogin = true;

  // Refund fields
  final _refundReferenceController = TextEditingController();
  final _refundAmountController = TextEditingController();

  // State
  bool _isInitialized = false;
  bool _isLoggedIn = false;
  bool _loading = false;
  String? _lastPaymentReference;

  void _log(String action, String message, {bool isError = false}) {
    if (!context.mounted) return;
    setState(() {
      _logs.insert(
        0,
        _LogEntry(
          timestamp: DateTime.now(),
          action: action,
          message: message,
          isError: isError,
        ),
      );
    });
  }

  Future<void> _runAction(String label, Future<void> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
    } catch (e) {
      _log(label, e.toString(), isError: true);
    } finally {
      if (context.mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _init() => _runAction('init', () async {
    final iosClientId = _iosClientIdController.text.trim();
    final androidClientId = _androidClientIdController.text.trim();
    final redirectUrl = _redirectUrlController.text.trim();

    if (iosClientId.isEmpty || androidClientId.isEmpty || redirectUrl.isEmpty) {
      _log('init', 'All credential fields are required', isError: true);
      return;
    }

    final response = await Zettle.init(
      iosClientId,
      androidClientId,
      redirectUrl,
    );
    _isInitialized = response.status;
    _log('init', response.toString());
  });

  Future<void> _login() => _runAction('login', () async {
    final response = await Zettle.login();
    _isLoggedIn = response.status;
    _log('login', response.toString());
  });

  Future<void> _logout() => _runAction('logout', () async {
    final response = await Zettle.logout();
    _isLoggedIn = response.status;
    _log('logout', response.toString());
  });

  Future<void> _checkLoggedIn() => _runAction('loggedIn', () async {
    final response = await Zettle.loggedIn();
    _isLoggedIn = response.status;
    _log('loggedIn', response.toString());
  });

  Future<void> _requestPayment() => _runAction('payment', () async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      _log('payment', 'Enter a valid amount', isError: true);
      return;
    }

    final reference = _uuid.v4();
    final response = await Zettle.requestPayment(
      ZettlePaymentRequest(
        amount: amount,
        reference: reference,
        enableLogin: _enableLogin,
        enableTipping: _enableTipping,
        enableInstalments: _enableInstalments,
      ),
    );

    if (response.status == ZettlePluginPaymentStatus.completed) {
      _lastPaymentReference = response.reference ?? reference;
      _refundReferenceController.text = _lastPaymentReference!;
      _refundAmountController.text = amount.toStringAsFixed(2);
    }

    _log('payment', response.toString());
  });

  Future<void> _requestRefund() => _runAction('refund', () async {
    final ref = _refundReferenceController.text.trim();
    if (ref.isEmpty) {
      _log('refund', 'Payment reference is required', isError: true);
      return;
    }

    final refundAmount = double.tryParse(_refundAmountController.text.trim());

    final response = await Zettle.requestRefund(
      ZettleRefundRequest(reference: ref, refundAmount: refundAmount),
    );

    _log('refund', response.toString());
  });

  void _showSettings() {
    try {
      Zettle.showSettings();
      _log('settings', 'Settings screen opened');
    } catch (e) {
      _log('settings', e.toString(), isError: true);
    }
  }

  @override
  void dispose() {
    _iosClientIdController.dispose();
    _androidClientIdController.dispose();
    _redirectUrlController.dispose();
    _amountController.dispose();
    _refundReferenceController.dispose();
    _refundAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zettle Example'),
        actions: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Status banner ---
          Card(
            color: _isInitialized
                ? (_isLoggedIn ? Colors.green.shade50 : Colors.orange.shade50)
                : Colors.grey.shade100,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    _isInitialized
                        ? (_isLoggedIn ? Icons.check_circle : Icons.warning)
                        : Icons.info_outline,
                    color: _isInitialized
                        ? (_isLoggedIn ? Colors.green : Colors.orange)
                        : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isInitialized
                        ? (_isLoggedIn
                              ? 'SDK ready & logged in'
                              : 'SDK initialized (not logged in)')
                        : 'SDK not initialized',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- Initialization ---
          _SectionHeader(title: 'SDK Initialization'),
          TextField(
            controller: _iosClientIdController,
            decoration: const InputDecoration(
              labelText: 'iOS Client ID',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            enabled: !_isInitialized,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _androidClientIdController,
            decoration: const InputDecoration(
              labelText: 'Android Client ID',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            enabled: !_isInitialized,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _redirectUrlController,
            decoration: const InputDecoration(
              labelText: 'Redirect URL',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            enabled: !_isInitialized,
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _isInitialized || _loading ? null : _init,
            icon: const Icon(Icons.rocket_launch),
            label: Text(_isInitialized ? 'Initialized' : 'Initialize SDK'),
          ),
          const SizedBox(height: 24),

          // --- Authentication ---
          _SectionHeader(title: 'Authentication'),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: !_isInitialized || _loading ? null : _login,
                  icon: const Icon(Icons.login),
                  label: const Text('Login'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: !_isInitialized || _loading ? null : _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton.icon(
                  onPressed: !_isInitialized || _loading
                      ? null
                      : _checkLoggedIn,
                  icon: const Icon(Icons.person_search),
                  label: const Text('Status'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- Payment ---
          _SectionHeader(title: 'Payment'),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '\u00A3 ',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            children: [
              FilterChip(
                label: const Text('Tipping'),
                selected: _enableTipping,
                onSelected: (v) => setState(() => _enableTipping = v),
              ),
              FilterChip(
                label: const Text('Instalments'),
                selected: _enableInstalments,
                onSelected: (v) => setState(() => _enableInstalments = v),
              ),
              FilterChip(
                label: const Text('Login prompt'),
                selected: _enableLogin,
                onSelected: (v) => setState(() => _enableLogin = v),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: !_isInitialized || _loading ? null : _requestPayment,
            icon: const Icon(Icons.payment),
            label: const Text('Request Payment'),
          ),
          const SizedBox(height: 24),

          // --- Refund ---
          _SectionHeader(title: 'Refund'),
          TextField(
            controller: _refundReferenceController,
            decoration: const InputDecoration(
              labelText: 'Payment reference',
              helperText: 'Auto-filled after a successful payment',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _refundAmountController,
            decoration: const InputDecoration(
              labelText: 'Refund amount',
              prefixText: '\u00A3 ',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: !_isInitialized || _loading ? null : _requestRefund,
            icon: const Icon(Icons.undo),
            label: const Text('Request Refund'),
          ),
          const SizedBox(height: 24),

          // --- Settings ---
          _SectionHeader(title: 'Card Reader'),
          OutlinedButton.icon(
            onPressed: !_isInitialized || _loading ? null : _showSettings,
            icon: const Icon(Icons.settings),
            label: const Text('Open Settings'),
          ),
          const SizedBox(height: 24),

          // --- Log ---
          _SectionHeader(title: 'Log'),
          if (_logs.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => _logs.clear()),
              child: const Text('Clear'),
            ),
          ..._logs.map((entry) => _LogTile(entry: entry)),
          if (_logs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No activity yet',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small helper widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _LogEntry {
  _LogEntry({
    required this.timestamp,
    required this.action,
    required this.message,
    this.isError = false,
  });

  final DateTime timestamp;
  final String action;
  final String message;
  final bool isError;
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.entry});
  final _LogEntry entry;

  @override
  Widget build(BuildContext context) {
    final time =
        '${entry.timestamp.hour.toString().padLeft(2, '0')}:'
        '${entry.timestamp.minute.toString().padLeft(2, '0')}:'
        '${entry.timestamp.second.toString().padLeft(2, '0')}';

    return Card(
      color: entry.isError ? Colors.red.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  entry.action,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: entry.isError ? Colors.red : null,
                  ),
                ),
                const Spacer(),
                Text(time, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 4),
            Text(entry.message, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
