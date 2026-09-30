import 'package:flutter/material.dart';
import '../core.dart';
import 'home.dart';
import 'auth.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});
  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(title: const Text('My bookings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)), bottom: const TabBar(labelColor: C.primary, indicatorColor: C.primary, unselectedLabelColor: C.text2, tabs: [Tab(text: 'Upcoming'), Tab(text: 'Active'), Tab(text: 'Completed')])),
          body: AnimatedBuilder(
            animation: booking,
            builder: (_, __) => TabBarView(children: [
              for (final s in ['Upcoming', 'Active', 'Completed'])
                Builder(builder: (_) {
                  final l = booking.reservations.where((r) => r.status == s).toList();
                  if (l.isEmpty) return EmptyState(Icons.event_busy, 'No $s bookings'.toLowerCase().replaceFirst('no ', 'No '), 'When you book a car, it will show up here.', action: s == 'Upcoming' ? 'Find a car' : null, onAction: () => booking.update(() => booking.tab = 1));
                  return ListView.separated(padding: const EdgeInsets.all(24), itemCount: l.length, separatorBuilder: (_, __) => const SizedBox(height: 12), itemBuilder: (_, i) => _card(context, l[i]));
                }),
            ]),
          ),
        ),
      );

  Widget _card(BuildContext context, Reservation r) {
    final st = {'Upcoming': (C.ok, C.okBg, Icons.check), 'Active': (C.primary, C.light, Icons.directions_car), 'Completed': (C.text2, C.border, Icons.done_all), 'Cancelled': (C.err, C.errBg, Icons.close)}[r.status]!;
    return AppCard(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookingDetailsScreen(r))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(r.car.name, style: const TextStyle(fontWeight: FontWeight.w600)), Pill(r.status, fg: st.$1, bg: st.$2, icon: st.$3)]),
        const SizedBox(height: 6),
        Text('${fmtRange(r.range)}  ·  ${r.pickup}', style: const TextStyle(color: C.text2, fontSize: 13)),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(money(r.total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), const Text('View details', style: TextStyle(color: C.primary, fontWeight: FontWeight.w600))]),
      ]),
    );
  }
}

class BookingDetailsScreen extends StatelessWidget {
  final Reservation r;
  const BookingDetailsScreen(this.r, {super.key});
  Widget _l(String a, String b) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(a, style: const TextStyle(color: C.text2)), Flexible(child: Text(b, style: const TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.right))]));
  @override
  Widget build(BuildContext context) {
    final left = r.range.end.difference(DateTime.now());
    return Scaffold(
      appBar: AppBar(title: Text(r.status == 'Active' ? 'Active rental' : 'Booking details')),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        if (r.status == 'Active') ...[
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Time remaining', style: TextStyle(color: Colors.white70)), Text('${left.inDays}d ${left.inHours % 24}h', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700)), Text('Return ${fmt(r.range.end)}, 10:00 AM', style: const TextStyle(color: Colors.white70))])),
          const SizedBox(height: 16),
        ],
        AppCard(child: Column(children: [_l('Booking ID', '#${r.id}'), _l('Status', r.status), _l('Vehicle', r.car.name), _l('Rental period', fmtRange(r.range)), _l('Pickup', r.pickup), _l('Return', r.pickup), const Divider(height: 24), _l('Paid with', 'Visa •••• 4242'), _l('Total', money(r.total))])),
        const SizedBox(height: 16),
        if (r.status == 'Active') ...[
          Btn('Extend rental', outline: true, onTap: () => toast(context, 'Extension request sent')),
          const SizedBox(height: 12),
        ],
        Btn('Contact support', outline: true, color: C.text2, onTap: () => toast(context, 'Support chat opening...')),
        if (r.status == 'Active') ...[const SizedBox(height: 12), Btn('Emergency support', color: C.err, onTap: () => toast(context, 'Calling emergency line...'))],
        if (r.status == 'Upcoming') ...[
          const SizedBox(height: 12),
          Btn('Cancel booking', outline: true, color: C.err, onTap: () async {
            final ok = await confirmDialog(context, 'Cancel this booking?', 'Free cancellation applies. This cannot be undone.', 'Cancel booking', danger: true);
            if (ok && context.mounted) { booking.update(() => r.status = 'Cancelled'); Navigator.pop(context); toast(context, 'Booking cancelled'); }
          }),
        ],
      ]),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  Widget _group(BuildContext c, List<(IconData, String, Widget?)> rows) => AppCard(
        pad: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(children: [for (final r in rows) ListTile(leading: CircleAvatar(radius: 18, backgroundColor: C.light, child: Icon(r.$1, size: 20, color: C.primary)), title: Text(r.$2, style: const TextStyle(fontWeight: FontWeight.w500)), trailing: const Icon(Icons.chevron_right, color: C.muted), onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => r.$3 ?? SimplePage(r.$2))))]),
      );
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ListView(padding: const EdgeInsets.all(24), children: [
            const Row(children: [CircleAvatar(radius: 32, backgroundColor: C.light, child: Text('JD', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: C.primary))), SizedBox(width: 14), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('John Doe', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)), Text('john@email.com', style: TextStyle(color: C.text2))])]),
            const SizedBox(height: 24),
            _group(context, [(Icons.person_outline, 'Personal information', null), (Icons.badge_outlined, 'Driver license', null), (Icons.credit_card, 'Payment methods', null), (Icons.favorite_border, 'Favorites', const FavoritesScreen())]),
            const SizedBox(height: 16),
            _group(context, [(Icons.history, 'Rental history', null), (Icons.star_outline, 'Reviews', null), (Icons.settings_outlined, 'Settings', null), (Icons.help_outline, 'Help center', null)]),
            const SizedBox(height: 24),
            Btn('Log out', outline: true, color: C.err, onTap: () async {
              final ok = await confirmDialog(context, 'Log out?', 'You will need to log in again to manage bookings.', 'Log out', danger: true);
              if (ok && context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
            }),
          ]),
        ),
      );
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Favorites')),
        body: AnimatedBuilder(
          animation: booking,
          builder: (_, __) {
            final l = cars.where((c) => booking.favorites.contains(c.id)).toList();
            if (l.isEmpty) return const EmptyState(Icons.favorite_border, 'No favorites yet', 'Tap the heart on a car to save it here.');
            return ListView.separated(padding: const EdgeInsets.all(24), itemCount: l.length, separatorBuilder: (_, __) => const SizedBox(height: 16), itemBuilder: (_, i) => CarCard(l[i], onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailsScreen(l[i])))));
          },
        ),
      );
}

/// Placeholder for screens that reuse the same components (edit profile, license, cards, history, reviews, settings, help).
class SimplePage extends StatelessWidget {
  final String title;
  const SimplePage(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title)), body: EmptyState(Icons.construction, title, 'This screen is ready to be built with the shared components.'));
}
