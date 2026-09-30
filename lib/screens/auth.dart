import 'package:flutter/material.dart';
import '../core.dart';
import 'home.dart';
import 'account.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController(text: 'john@email.com');
  final pass = TextEditingController();
  bool hide = true;
  String? emailErr;

  void submit() {
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.text.trim());
    setState(() => emailErr = ok ? null : 'Enter a valid email address, like name@email.com.');
    if (ok) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Shell()));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ListView(padding: const EdgeInsets.all(24), children: [
            const SizedBox(height: 32),
            Container(width: 56, height: 56, decoration: BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.directions_car_filled, color: Colors.white, size: 32)),
            const SizedBox(height: 24),
            const Text('Welcome back', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Log in to book your next car.', style: TextStyle(color: C.text2)),
            const SizedBox(height: 24),
            TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: _dec('Email', err: emailErr)),
            const SizedBox(height: 16),
            TextField(controller: pass, obscureText: hide, decoration: _dec('Password', suffix: IconButton(tooltip: 'Show password', icon: Icon(hide ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => hide = !hide)))),
            Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text('Forgot password?'))),
            const SizedBox(height: 8),
            Btn('Log in', onTap: submit),
            const SizedBox(height: 20),
            const Center(child: Text('or continue with', style: TextStyle(color: C.text2))),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52), foregroundColor: C.text, side: const BorderSide(color: C.border)), onPressed: submit, child: const Text('Google'))),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52), foregroundColor: C.text, side: const BorderSide(color: C.border)), onPressed: submit, child: const Text('Apple'))),
            ]),
            const SizedBox(height: 32),
            Center(child: TextButton(onPressed: () {}, child: const Text('New here? Create account'))),
          ]),
        ),
      );

  InputDecoration _dec(String l, {String? err, Widget? suffix}) {
    OutlineInputBorder b(Color c) => OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c));
    return InputDecoration(labelText: l, errorText: err, suffixIcon: suffix, filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.all(16), enabledBorder: b(C.border), focusedBorder: b(C.primary), errorBorder: b(C.err), focusedErrorBorder: b(C.err));
  }
}

class Shell extends StatelessWidget {
  const Shell({super.key});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: booking,
        builder: (_, __) => Scaffold(
          body: IndexedStack(index: booking.tab, children: const [HomeScreen(), ResultsScreen(tab: true), BookingsScreen(), ProfileScreen()]),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: booking.tab,
            onTap: (i) => booking.update(() => booking.tab = i),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Explore'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Bookings'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      );
}
