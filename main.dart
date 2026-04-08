import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:math'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // THE HANDSHAKE: PASTE YOUR KEYS HERE
  await Supabase.initialize(
    url: 'https://untkduqczwwwoipscqaz.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVudGtkdXFjend3d29pcHNjcWF6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU2NDAwMDcsImV4cCI6MjA5MTIxNjAwN30.PFCDHHrxZs9SNSc3PRiDAN1pfTfx1AG2tYfn_7pWMiU',
  );

  runApp(const DebtifyApp());
}

class DebtifyApp extends StatelessWidget {
  const DebtifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Debtify',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Roboto Mono',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2.0),
        ),
      ),
      home: const LoginScreen(), 
    );
  }
}

// --- DATA MODEL (Updated for Supabase) ---
class Debt {
  final String id, person, reason, status;
  final double amount;
  final bool isOwedToMe; 
  final DateTime date; 
  
  Debt(this.id, this.person, this.amount, this.reason, this.isOwedToMe, this.date, this.status);

  // Helper to convert Supabase JSON into our Dart Object
  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      json['id'] as String,
      json['person_name'] as String,
      double.parse(json['amount'].toString()),
      json['reason'] ?? '',
      json['is_owed_to_me'] as bool,
      DateTime.parse(json['created_at']),
      json['status'] as String,
    );
  }
}

const Map<String, String> riskProfiles = {
  'RAHUL': 'LOW',
  'SNEHA': 'HIGH',
  'KABIR': 'MED',
};

// --- LOGIN SCREEN ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DEBTIFY.', style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: -1.5)),
                  const SizedBox(height: 8),
                  const Text('IDENTIFY YOURSELF.', style: TextStyle(color: Colors.grey, fontSize: 14, letterSpacing: 2.0)),
                  const SizedBox(height: 60),
                  
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(labelText: 'EMAIL', labelStyle: TextStyle(color: Colors.grey.shade600, letterSpacing: 1.5), enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white))),
                  ),
                  const SizedBox(height: 20),
                  
                  TextField(
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(labelText: 'PASSWORD', labelStyle: TextStyle(color: Colors.grey.shade600, letterSpacing: 1.5), enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white))),
                  ),
                  const SizedBox(height: 50),

                  SizedBox(
                    width: double.infinity, height: 55,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainHostScreen())),
                      child: const Text('AUTHENTICATE', style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2.0, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity, height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainHostScreen())),
                      icon: const Icon(Icons.g_mobiledata, size: 32),
                      label: const Text('CONTINUE WITH GOOGLE', style: TextStyle(fontSize: 14, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- MAIN HOST SCREEN (Now talks to the Cloud!) ---
class MainHostScreen extends StatefulWidget {
  const MainHostScreen({super.key});
  @override
  State<MainHostScreen> createState() => _MainHostScreenState();
}

class _MainHostScreenState extends State<MainHostScreen> {
  int _currentIndex = 0;
  bool _isLoading = true; // Shows spinner while fetching DB

  List<Debt> _activeDebts = [];
  List<Debt> _settledDebts = [];

  final supabase = Supabase.instance.client; // Our direct line to PostgreSQL

  @override
  void initState() {
    super.initState();
    _fetchDebtsFromCloud(); // Grab data as soon as dashboard opens
  }

  // 1. THE READ QUERY (SELECT)
  Future<void> _fetchDebtsFromCloud() async {
    setState(() => _isLoading = true);
    
    // SQL: SELECT * FROM debts ORDER BY created_at DESC;
    final response = await supabase.from('debts').select().order('created_at', ascending: false);
    
    final List<Debt> allDebts = response.map((json) => Debt.fromJson(json)).toList();

    setState(() {
      _activeDebts = allDebts.where((d) => d.status == 'ACTIVE').toList();
      _settledDebts = allDebts.where((d) => d.status == 'SETTLED').toList();
      _isLoading = false;
    });
  }

  // 2. THE CREATE QUERY (INSERT)
  Future<void> _addNewDebt(String name, double amount, String reason, bool isOwedToMe) async {
    // Show instant feedback on UI
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SAVING TO DATABASE...'), duration: Duration(seconds: 1)));

    // SQL: INSERT INTO debts (person_name, amount...) VALUES (...)
    await supabase.from('debts').insert({
      'person_name': name,
      'amount': amount,
      'reason': reason,
      'is_owed_to_me': isOwedToMe,
      'status': 'ACTIVE'
    });

    _fetchDebtsFromCloud(); // Refresh the screen
  }

  // 3. THE UPDATE QUERY (SOFT DELETE / ARCHIVE)
  Future<void> _settleDebt(Debt debt) async {
    // SQL: UPDATE debts SET status = 'SETTLED' WHERE id = 'debt.id';
    await supabase.from('debts').update({'status': 'SETTLED'}).eq('id', debt.id);
    
    _fetchDebtsFromCloud(); // Refresh the screen
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }

    final List<Widget> screens = [
      DashboardScreen(activeDebts: _activeDebts, onAdd: _addNewDebt, onSettle: _settleDebt),
      ArchiveScreen(settledDebts: _settledDebts),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey.shade800,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Active'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Archive'),
        ],
      ),
    );
  }
}

// --- ACTIVE DASHBOARD SCREEN ---
class DashboardScreen extends StatelessWidget {
  final List<Debt> activeDebts;
  final Function(String, double, String, bool) onAdd;
  final Function(Debt) onSettle;

  const DashboardScreen({super.key, required this.activeDebts, required this.onAdd, required this.onSettle});

  Future<bool> _showRiskWarning(BuildContext context, String name) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.redAccent, width: 2), borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
            SizedBox(width: 10),
            Text('HIGH RISK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('$name has a history of delayed payments or partial settlements. Are you sure you want to lend them more money?', style: const TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL', style: TextStyle(color: Colors.white))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('PROCEED ANYWAY'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showAddDebtSheet(BuildContext context) {
    final personController = TextEditingController();
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    bool isOwedToMe = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('NEW ENTRY.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                  const SizedBox(height: 20),
                  
                  TextField(controller: personController, decoration: const InputDecoration(labelText: 'FRIEND NAME', enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)))),
                  TextField(controller: reasonController, decoration: const InputDecoration(labelText: 'REASON', enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)))),
                  TextField(controller: amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'AMOUNT (₹)', enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)))),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isOwedToMe ? 'THEY OWE ME' : 'I OWE THEM', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Switch(activeColor: Colors.white, value: isOwedToMe, onChanged: (val) => setModalState(() => isOwedToMe = val)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity, height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white)),
                      onPressed: () async {
                        if (personController.text.isEmpty || amountController.text.isEmpty) return;
                        
                        String upperName = personController.text.toUpperCase();
                        
                        if (isOwedToMe && riskProfiles[upperName] == 'HIGH') {
                          bool proceed = await _showRiskWarning(context, upperName);
                          if (!proceed) return; 
                        }
                        
                        // Fire to the database!
                        onAdd(upperName, double.parse(amountController.text), reasonController.text.toUpperCase(), isOwedToMe);
                        Navigator.pop(context); 
                      },
                      child: const Text('ADD TO LEDGER', style: TextStyle(color: Colors.white, letterSpacing: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalOwedToMe = 0;
    double totalIOwe = 0;
    
    for (var debt in activeDebts) {
      if (debt.isOwedToMe) totalOwedToMe += debt.amount;
      else totalIOwe += debt.amount;
    }
    double netBalance = totalOwedToMe - totalIOwe;

    List<Debt> sortedByDate = List.from(activeDebts)..sort((a, b) => a.date.compareTo(b.date));
    List<double> balanceHistory = [0.0]; 
    double runningBalance = 0.0;
    
    for (var debt in sortedByDate) {
      if (debt.isOwedToMe) runningBalance += debt.amount;
      else runningBalance -= debt.amount;
      balanceHistory.add(runningBalance);
    }

    List<Debt> priorityLedger = List.from(activeDebts)..sort((a, b) {
      if (a.isOwedToMe && !b.isOwedToMe) return -1;
      if (!a.isOwedToMe && b.isOwedToMe) return 1;
      return b.amount.compareTo(a.amount); 
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('DEBTIFY.'),
        actions: [
          IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 28), onPressed: () => _showAddDebtSheet(context)),
          IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()))),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text('NET BALANCE', style: TextStyle(color: Colors.grey, fontSize: 14, letterSpacing: 1.5)),
            const SizedBox(height: 5),
            Text('₹ ${netBalance.toStringAsFixed(2)}', style: TextStyle(color: netBalance >= 0 ? Colors.white : Colors.redAccent, fontSize: 42, fontWeight: FontWeight.w300, letterSpacing: -2.0)),
            const SizedBox(height: 30),
            
            const Text('TREND LINE', style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5)),
            const SizedBox(height: 10),
            Container(
              height: 100, 
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: CustomPaint(painter: TrendLinePainter(balanceHistory)),
            ),
            const SizedBox(height: 30),
            
            const Text('PRIORITY LEDGER', style: TextStyle(color: Colors.grey, fontSize: 14, letterSpacing: 1.5)),
            const SizedBox(height: 10),
            
            // Show message if DB is empty
            if (priorityLedger.isEmpty)
              const Expanded(child: Center(child: Text('NO DEBTS FOUND.', style: TextStyle(color: Colors.white24, letterSpacing: 2.0))))
            else
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: priorityLedger.length, 
                  itemBuilder: (context, index) {
                    final debt = priorityLedger[index];
                    final color = debt.isOwedToMe ? Colors.white : Colors.redAccent;
                    final prefix = debt.isOwedToMe ? '+' : '-';
                    
                    String riskScore = riskProfiles[debt.person] ?? 'NEW';
                    Color riskColor = Colors.grey;
                    if (riskScore == 'HIGH') riskColor = Colors.redAccent;
                    if (riskScore == 'MED') riskColor = Colors.orangeAccent;
                    if (riskScore == 'LOW') riskColor = Colors.greenAccent;
                    
                    return Dismissible(
                      key: Key(debt.id), 
                      direction: DismissDirection.endToStart, 
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(color: Colors.green.shade800, borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.check_circle, color: Colors.white, size: 32),
                      ),
                      onDismissed: (direction) {
                        onSettle(debt); // Trigger the database UPDATE!
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SETTLED: ${debt.person}'), backgroundColor: Colors.grey[900], duration: const Duration(seconds: 2), behavior: SnackBarBehavior.floating));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(border: Border.all(color: Colors.white24, width: 1.5), borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(debt.person, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                    const SizedBox(width: 8),
                                    Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: riskColor)),
                                  ],
                                ),
                                Text(debt.reason, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, letterSpacing: 1.0)),
                              ],
                            ),
                            Text('$prefix₹${debt.amount}', style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- ARCHIVE SCREEN ---
class ArchiveScreen extends StatelessWidget {
  final List<Debt> settledDebts;
  const ArchiveScreen({super.key, required this.settledDebts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ARCHIVE.')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text('SETTLED TRANSACTIONS', style: TextStyle(color: Colors.grey, fontSize: 14, letterSpacing: 1.5)),
            const SizedBox(height: 20),
            
            settledDebts.isEmpty 
              ? const Center(child: Text('NO HISTORY YET', style: TextStyle(color: Colors.white24, letterSpacing: 2.0)))
              : Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: settledDebts.length,
                    itemBuilder: (context, index) {
                      final debt = settledDebts[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(border: Border.all(color: Colors.white12, width: 1.5), borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(debt.person, style: const TextStyle(color: Colors.white38, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                Text(debt.reason, style: const TextStyle(color: Colors.white24, fontSize: 12, letterSpacing: 1.0)),
                              ],
                            ),
                            Text('₹${debt.amount}', style: const TextStyle(color: Colors.white38, fontSize: 20, fontWeight: FontWeight.bold, decoration: TextDecoration.lineThrough)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

// --- THE CUSTOM CANVAS PAINTER ENGINE ---
class TrendLinePainter extends CustomPainter {
  final List<double> dataPoints;
  TrendLinePainter(this.dataPoints);

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final linePaint = Paint()..color = Colors.white..strokeWidth = 3.0..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    final double maxVal = dataPoints.reduce(max);
    final double minVal = dataPoints.reduce(min);
    final double range = maxVal - minVal == 0 ? 1 : maxVal - minVal;
    final path = Path();
    final double stepX = size.width / (dataPoints.length > 1 ? dataPoints.length - 1 : 1);

    for (int i = 0; i < dataPoints.length; i++) {
      final double x = i * stepX;
      final double normalizedY = (dataPoints[i] - minVal) / range;
      final double y = size.height - (normalizedY * size.height);

      if (i == 0) path.moveTo(x, y); 
      else path.lineTo(x, y); 
      
      canvas.drawCircle(Offset(x, y), 4.0, Paint()..color = Colors.white);
    }
    canvas.drawPath(path, linePaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true; 
}