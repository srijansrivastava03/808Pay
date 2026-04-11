import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/history_screen.dart';
import 'services/pera_wallet_service_v2.dart';
import 'services/settlement_sync_service.dart';
import 'services/transaction_queue_service.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final queueService = TransactionQueueService();
  await queueService.initialize();
  
  final apiService = ApiService();
  final syncService = SettlementSyncService(
    queueService: queueService,
    apiService: apiService,
  );
  await syncService.initialize();
  
  runApp(MyApp(
    queueService: queueService,
    syncService: syncService,
  ));
}

class MyApp extends StatelessWidget {
  final TransactionQueueService queueService;
  final SettlementSyncService syncService;
  
  const MyApp({
    Key? key,
    required this.queueService,
    required this.syncService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => PeraWalletServiceV2(),
        ),
        Provider<TransactionQueueService>(
          create: (context) => queueService,
        ),
        Provider<SettlementSyncService>(
          create: (context) => syncService,
        ),
      ],
      child: MaterialApp(
        title: '808Pay',
        theme: AppTheme.darkTheme,
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PaymentScreen(),
    const HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Pay',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
