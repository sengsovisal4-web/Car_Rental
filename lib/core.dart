import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class C {
  static const primary = Color(0xFF2563EB), dark = Color(0xFF1D4ED8), light = Color(0xFFEFF6FF);
  static const bg = Color(0xFFF8FAFC), text = Color(0xFF0F172A), text2 = Color(0xFF64748B);
  static const muted = Color(0xFF94A3B8), border = Color(0xFFE2E8F0);
  static const ok = Color(0xFF16A34A), okBg = Color(0xFFDCFCE7), warn = Color(0xFFF59E0B);
  static const warnBg = Color(0xFFFEF3C7), err = Color(0xFFDC2626), errBg = Color(0xFFFEE2E2);
}

ThemeData buildTheme() {
  final base = ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: C.primary, primary: C.primary, surface: Colors.white));
  final rr = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
  const label = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
  return base.copyWith(
    scaffoldBackgroundColor: C.bg,
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(bodyColor: C.text, displayColor: C.text),
    appBarTheme: const AppBarTheme(backgroundColor: C.bg, foregroundColor: C.text, elevation: 0, scrolledUnderElevation: 0, centerTitle: false, titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: C.text)),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: C.primary, foregroundColor: Colors.white, elevation: 0, shape: rr, textStyle: label)),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(shape: rr, textStyle: label)),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Colors.white, selectedItemColor: C.primary, unselectedItemColor: C.muted, type: BottomNavigationBarType.fixed, selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600), unselectedLabelStyle: TextStyle(fontSize: 12)),
  );
}

// ---------- Models ----------
class Car {
  final String id, name, type, trans, fuel;
  final double rating, price;
  final int reviews, seats, bags;
  final List<String> features;
  const Car(this.id, this.name, this.type, this.rating, this.reviews, this.price, this.trans, this.fuel, this.seats, this.bags, this.features);
}

const cars = [
  Car('1', 'Toyota Camry 2025', 'Sedan', 4.8, 124, 45, 'Automatic', 'Hybrid', 5, 2, ['Air conditioning', 'Bluetooth', 'Backup camera']),
  Car('2', 'Lexus RX 350', 'SUV', 4.9, 86, 92, 'Automatic', 'Petrol', 5, 3, ['Leather seats', 'Sunroof', 'Apple CarPlay']),
  Car('3', 'Honda CR-V 2024', 'SUV', 4.7, 98, 60, 'Automatic', 'Petrol', 5, 3, ['Air conditioning', 'Bluetooth', 'Lane assist']),
  Car('4', 'Toyota Vios', 'Economy', 4.5, 210, 28, 'Manual', 'Petrol', 5, 2, ['Air conditioning', 'USB charging']),
  Car('5', 'Toyota Alphard', 'Van', 4.8, 54, 110, 'Automatic', 'Petrol', 7, 4, ['Captain seats', 'Rear AC', 'Sliding doors']),
  Car('6', 'Tesla Model 3', 'Luxury', 4.9, 67, 120, 'Automatic', 'Electric', 5, 2, ['Autopilot', 'Glass roof', 'Fast charging']),
];

const extrasList = [
  ('Full insurance', 'Covers damage and theft', 12.0),
  ('Additional driver', 'One extra licensed driver', 8.0),
  ('Child seat', 'Ages 1-4', 5.0),
  ('GPS', 'Offline maps included', 4.0),
];

const locations = [
  ('Phnom Penh International Airport', '12 min from city'),
  ('Riverside Office', 'Sisowath Quay'),
  ('Aeon Mall Sen Sok', 'Recent'),
  ('Siem Reap Airport', 'Popular'),
];

class Reservation {
  final String id;
  final Car car;
  final DateTimeRange range;
  final String pickup;
  final double total;
  String status; // Upcoming, Active, Completed, Cancelled
  Reservation(this.id, this.car, this.range, this.pickup, this.total, this.status);
}

// ---------- State (no external packages) ----------
class BookingState extends ChangeNotifier {
  int tab = 0;
  Car? car;
  late DateTimeRange range = DateTimeRange(start: DateTime.now().add(const Duration(days: 2)), end: DateTime.now().add(const Duration(days: 5)));
  String pickup = locations[0].$1;
  final Set<int> extras = {};
  final Set<String> favorites = {};
  Set<String> fTypes = {};
  String fTrans = 'Any';
  double maxPrice = 130;
  String sort = 'Recommended';
  late final List<Reservation> reservations = [
    Reservation('CR-20310', cars[2], DateTimeRange(start: DateTime.now().subtract(const Duration(days: 1)), end: DateTime.now().add(const Duration(days: 2))), locations[0].$1, 180, 'Active'),
    Reservation('CR-19877', cars[3], DateTimeRange(start: DateTime(2026, 8, 3), end: DateTime(2026, 8, 6)), locations[1].$1, 92, 'Completed'),
  ];

  int get days => range.duration.inDays.clamp(1, 365);
  double get rental => (car?.price ?? 0) * days;
  double get extrasTotal => extras.fold(0.0, (s, i) => s + extrasList[i].$3 * days);
  double get discount => (rental + extrasTotal) * 0.2;
  double get fees => (rental + extrasTotal - discount) * 0.05;
  double get total => rental + extrasTotal - discount + fees;

  List<Car> get filtered {
    final l = cars.where((c) => (fTypes.isEmpty || fTypes.contains(c.type)) && (fTrans == 'Any' || c.trans == fTrans) && c.price <= maxPrice).toList();
    if (sort == 'Price: low to high') l.sort((a, b) => a.price.compareTo(b.price));
    if (sort == 'Top rated') l.sort((a, b) => b.rating.compareTo(a.rating));
    return l;
  }

  void update(void Function() f) { f(); notifyListeners(); }
  void toggleFav(String id) => update(() => favorites.contains(id) ? favorites.remove(id) : favorites.add(id));
  void reset() => update(() { extras.clear(); car = null; });
}

final booking = BookingState();

const _m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
String fmt(DateTime d) => '${d.day} ${_m[d.month - 1]}';
String fmtRange(DateTimeRange r) => '${fmt(r.start)} - ${fmt(r.end)}';
String money(double v) => '\$${v.toStringAsFixed(2)}';

// ---------- Shared widgets ----------
class Btn extends StatelessWidget {
  final String label; final VoidCallback? onTap; final bool outline; final Color? color;
  const Btn(this.label, {super.key, this.onTap, this.outline = false, this.color});
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 52, width: double.infinity,
        child: outline
            ? OutlinedButton(style: OutlinedButton.styleFrom(foregroundColor: color ?? C.primary, side: BorderSide(color: color ?? C.primary)), onPressed: onTap, child: Text(label))
            : ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: color ?? C.primary), onPressed: onTap, child: Text(label)),
      );
}

class AppCard extends StatelessWidget {
  final Widget child; final Color? bg; final Color? borderColor; final EdgeInsets pad; final VoidCallback? onTap;
  const AppCard({super.key, required this.child, this.bg, this.borderColor, this.pad = const EdgeInsets.all(16), this.onTap});
  @override
  Widget build(BuildContext context) => Material(
        color: bg ?? Colors.white, borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16), onTap: onTap,
          child: Container(padding: pad, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor ?? C.border)), child: child),
        ),
      );
}

class Pill extends StatelessWidget {
  final String label; final Color fg, bg; final IconData? icon;
  const Pill(this.label, {super.key, this.fg = C.ok, this.bg = C.okBg, this.icon});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 4)],
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
        ]),
      );
}

class Chip2 extends StatelessWidget {
  final String label; final bool on; final VoidCallback onTap;
  const Chip2(this.label, this.on, this.onTap, {super.key});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44), alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: on ? C.primary : Colors.white, borderRadius: BorderRadius.circular(999), border: Border.all(color: on ? C.primary : C.border)),
          child: Text(label, style: TextStyle(color: on ? Colors.white : C.text, fontWeight: FontWeight.w500)),
        ),
      );
}

class BottomBar extends StatelessWidget {
  final Widget child;
  const BottomBar({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: C.border))),
        child: SafeArea(top: false, child: child),
      );
}

class FieldBox extends StatelessWidget {
  final String label, value; final IconData? icon; final VoidCallback? onTap; final bool error;
  const FieldBox(this.label, this.value, {super.key, this.icon, this.onTap, this.error = false});
  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(12), onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: error ? C.errBg : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: error ? C.err : C.border)),
          child: Row(children: [
            if (icon != null) ...[Icon(icon, size: 20, color: C.text2), const SizedBox(width: 12)],
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontSize: 12, color: C.text2)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
            ])),
          ]),
        ),
      );
}

class CarImage extends StatelessWidget {
  final double height; final Widget? overlay;
  const CarImage({super.key, this.height = 132, this.overlay});
  @override
  Widget build(BuildContext context) => Container(
        height: height, width: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [C.light, Color(0xFFDBEAFE)])),
        child: Stack(alignment: Alignment.center, children: [
          Icon(Icons.directions_car_filled_rounded, size: height * 0.6, color: C.primary),
          if (overlay != null) overlay!,
        ]),
      );
}

class CarCard extends StatelessWidget {
  final Car car; final VoidCallback onTap;
  const CarCard(this.car, {super.key, required this.onTap});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: booking,
        builder: (_, __) {
          final fav = booking.favorites.contains(car.id);
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.white,
              child: InkWell(
                onTap: onTap,
                child: Container(
                  decoration: BoxDecoration(border: Border.all(color: C.border), borderRadius: BorderRadius.circular(16)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    CarImage(overlay: Positioned(right: 12, top: 12, child: Material(color: Colors.white, shape: const CircleBorder(), child: IconButton(tooltip: 'Save to favorites', onPressed: () => booking.toggleFav(car.id), icon: Icon(fav ? Icons.favorite : Icons.favorite_border, color: fav ? C.err : C.text2, size: 20))))),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(car.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('★ ${car.rating} (${car.reviews} reviews)', style: const TextStyle(fontSize: 12, color: C.text2)),
                        const SizedBox(height: 8),
                        Wrap(spacing: 12, runSpacing: 4, children: [
                          _spec(Icons.settings, car.trans), _spec(Icons.local_gas_station, car.fuel),
                          _spec(Icons.people, '${car.seats} seats'), _spec(Icons.luggage, '${car.bags} bags'),
                        ]),
                        const SizedBox(height: 12),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text.rich(TextSpan(children: [TextSpan(text: '\$${car.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: C.primary)), const TextSpan(text: ' / day', style: TextStyle(fontSize: 12, color: C.text2))])),
                          const Text('View details', style: TextStyle(color: C.primary, fontWeight: FontWeight.w600)),
                        ]),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),
          );
        },
      );
  Widget _spec(IconData i, String t) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(i, size: 14, color: C.text2), const SizedBox(width: 4), Text(t, style: const TextStyle(fontSize: 12, color: C.text2))]);
}

class EmptyState extends StatelessWidget {
  final IconData icon; final String title, body; final String? action; final VoidCallback? onAction;
  const EmptyState(this.icon, this.title, this.body, {super.key, this.action, this.onAction});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircleAvatar(radius: 48, backgroundColor: C.light, child: Icon(icon, size: 44, color: C.primary)),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(body, textAlign: TextAlign.center, style: const TextStyle(color: C.text2)),
            if (action != null) ...[const SizedBox(height: 24), Btn(action!, onTap: onAction)],
          ]),
        ),
      );
}

Future<bool> confirmDialog(BuildContext c, String title, String body, String ok, {bool danger = false}) async {
  final r = await showDialog<bool>(
    context: c,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title), content: Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Keep')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: danger ? C.err : C.primary), onPressed: () => Navigator.pop(c, true), child: Text(ok)),
      ],
    ),
  );
  return r ?? false;
}

void toast(BuildContext c, String m) => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));
