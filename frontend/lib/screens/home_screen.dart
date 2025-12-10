import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/summary_card.dart';
import '../widgets/fund_split_card.dart';
import 'add_transaction_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  final ApiService apiService;

  HomeScreen({super.key, ApiService? apiService})
      : apiService = apiService ?? ApiService();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ApiService _apiService;
  Map<String, double>? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService;
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() => _isLoading = true);
    try {
      final summary = await _apiService.getSummary();
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Thu Chi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_summary != null) ...[
                  SummaryCard(summary: _summary!),
                  const SizedBox(height: 12),
                  FundSplitCard(summary: _summary!),
                ],
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    padding: const EdgeInsets.all(16),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildMenuCard(
                        context,
                        'Thêm Thu',
                        Icons.add_circle,
                        Colors.green,
                        () => _navigateToAdd('income'),
                      ),
                      _buildMenuCard(
                        context,
                        'Thêm Chi',
                        Icons.remove_circle,
                        Colors.red,
                        () => _navigateToAdd('expense'),
                      ),
                      _buildMenuCard(
                        context,
                        'Lịch sử',
                        Icons.history,
                        Colors.blue,
                        () => _navigateToHistory(),
                      ),
                      _buildMenuCard(
                        context,
                        'Làm mới',
                        Icons.refresh,
                        Colors.orange,
                        _loadSummary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAdd(String type) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(type: type),
      ),
    );
    _loadSummary();
  }

  Future<void> _navigateToHistory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryScreen(apiService: _apiService),
      ),
    );
    await _loadSummary();
  }
}