import 'package:flutter/material.dart';
import '../core.dart';
import 'booking.dart';

Future<void> pickDates(BuildContext c) async {
  final r = await showDateRangePicker(
    context: c, initialDateRange: booking.range,
    firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)),
    helpText: 'Select rental dates', saveText: 'Confirm',
  );
  if (r != null) booking.update(() => booking.range = r);
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: AnimatedBuilder(
            animation: booking,
            builder: (_, __) => ListView(padding: const EdgeInsets.all(24), children: [
              Row(children: [
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Good morning, John 👋', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Row(children: [Icon(Icons.place_outlined, size: 16, color: C.text2), SizedBox(width: 4), Text('Phnom Penh', style: TextStyle(color: C.text2))]),
                ])),
                Material(color: Colors.white, shape: const CircleBorder(side: BorderSide(color: C.border)), child: IconButton(tooltip: 'Notifications', icon: const Icon(Icons.notifications_none), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())))),
              ]),
              const SizedBox(height: 24),
              AppCard(child: Column(children: [
                FieldBox('Pickup location', booking.pickup, icon: Icons.place_outlined, onTap: () async {
                  final r = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const PickupScreen()));
                  if (r != null) booking.update(() => booking.pickup = r);
                }),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: FieldBox('Pickup', fmt(booking.range.start), icon: Icons.event, onTap: () => pickDates(context))),
                  const SizedBox(width: 12),
                  Expanded(child: FieldBox('Return', fmt(booking.range.end), icon: Icons.event_available, onTap: () => pickDates(context))),
                ]),
                const SizedBox(height: 16),
                Btn('Search cars', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultsScreen()))),
              ])),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: C.primary, borderRadius: BorderRadius.circular(16)),
                child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('20% off weekend rentals', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Text('Applied automatically at checkout.', style: TextStyle(color: Colors.white70)),
                ]),
              ),
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Popular cars', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                TextButton(onPressed: () => booking.update(() => booking.tab = 1), child: const Text('See all')),
              ]),
              for (final c in cars.take(3)) Padding(padding: const EdgeInsets.only(bottom: 16), child: CarCard(c, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailsScreen(c))))),
            ]),
          ),
        ),
      );
}

class ResultsScreen extends StatelessWidget {
  final bool tab;
  const ResultsScreen({super.key, this.tab = false});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(tab ? 'Explore' : 'Available cars'), automaticallyImplyLeading: !tab),
        body: AnimatedBuilder(
          animation: booking,
          builder: (_, __) {
            final list = booking.filtered;
            return Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(children: [
                  Align(alignment: Alignment.centerLeft, child: Text('${fmtRange(booking.range)}  ·  ${booking.pickup}', style: const TextStyle(color: C.text2, fontSize: 13))),
                  const SizedBox(height: 8),
                  Row(children: [
                    Text('${list.length} cars available', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    OutlinedButton.icon(style: OutlinedButton.styleFrom(foregroundColor: C.text, side: const BorderSide(color: C.border)), onPressed: () => showFilters(context), icon: const Icon(Icons.tune, size: 18), label: const Text('Filter')),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(style: OutlinedButton.styleFrom(foregroundColor: C.text, side: const BorderSide(color: C.border)), onPressed: () => showSort(context), icon: const Icon(Icons.sort, size: 18), label: const Text('Sort')),
                  ]),
                ]),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: list.isEmpty
                    ? EmptyState(Icons.directions_car_outlined, 'No cars found', 'There are no available cars for your selected filters. Try changing them.', action: 'Reset filters', onAction: () => booking.update(() { booking.fTypes = {}; booking.fTrans = 'Any'; booking.maxPrice = 130; }))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24), itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (_, i) => CarCard(list[i], onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailsScreen(list[i])))),
                      ),
              ),
            ]);
          },
        ),
      );
}

void showSort(BuildContext c) => showModalBottomSheet(
      context: c, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Padding(padding: EdgeInsets.all(24), child: Align(alignment: Alignment.centerLeft, child: Text('Sort by', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)))),
        for (final s in ['Recommended', 'Price: low to high', 'Top rated'])
          ListTile(title: Text(s), trailing: booking.sort == s ? const Icon(Icons.check, color: C.primary) : null, onTap: () { booking.update(() => booking.sort = s); Navigator.pop(c); }),
        const SizedBox(height: 16),
      ])),
    );

void showFilters(BuildContext c) {
  var types = {...booking.fTypes};
  var trans = booking.fTrans;
  var price = booking.maxPrice;
  showModalBottomSheet(
    context: c, isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => StatefulBuilder(
      builder: (ctx, set) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)), const Spacer(),
              TextButton(onPressed: () => set(() { types = {}; trans = 'Any'; price = 130; }), child: const Text('Reset')),
            ]),
            const Text('Max price per day', style: TextStyle(fontWeight: FontWeight.w600)),
            Slider(value: price, min: 20, max: 130, divisions: 11, label: '\$${price.round()}', onChanged: (v) => set(() => price = v)),
            const Text('Vehicle type', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [for (final t in ['Economy', 'Sedan', 'SUV', 'Luxury', 'Van']) Chip2(t, types.contains(t), () => set(() => types.contains(t) ? types.remove(t) : types.add(t)))]),
            const SizedBox(height: 16),
            const Text('Transmission', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [for (final t in ['Any', 'Automatic', 'Manual']) Chip2(t, trans == t, () => set(() => trans = t))]),
            const SizedBox(height: 24),
            Btn('Show results', onTap: () { booking.update(() { booking.fTypes = types; booking.fTrans = trans; booking.maxPrice = price; }); Navigator.pop(ctx); }),
          ]),
        ),
      ),
    ),
  );
}

class CarDetailsScreen extends StatelessWidget {
  final Car car;
  const CarDetailsScreen(this.car, {super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Car details')),
        body: ListView(children: [
          const CarImage(height: 220),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(car.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700))),
                const Pill('Available', icon: Icons.check_circle),
              ]),
              const SizedBox(height: 4),
              Text('★ ${car.rating}  ·  ${car.reviews} reviews', style: const TextStyle(color: C.text2)),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 3.2, mainAxisSpacing: 12, crossAxisSpacing: 12,
                children: [
                  for (final s in [(Icons.settings, car.trans), (Icons.local_gas_station, car.fuel), (Icons.people, '${car.seats} seats'), (Icons.luggage, '${car.bags} bags')])
                    AppCard(pad: const EdgeInsets.symmetric(horizontal: 12), child: Row(children: [Icon(s.$1, size: 20, color: C.primary), const SizedBox(width: 8), Text(s.$2)])),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: [for (final f in car.features) Chip(label: Text(f), backgroundColor: Colors.white, side: const BorderSide(color: C.border))]),
              const SizedBox(height: 16),
              const Text('A comfortable, well-maintained vehicle for city trips and long drives. Free cancellation up to 24 hours before pickup.', style: TextStyle(color: C.text2, height: 1.5)),
            ]),
          ),
        ]),
        bottomNavigationBar: BottomBar(
          child: Row(children: [
            Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Price', style: TextStyle(fontSize: 12, color: C.text2)),
              Text.rich(TextSpan(children: [TextSpan(text: '\$${car.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)), const TextSpan(text: ' / day', style: TextStyle(fontSize: 12, color: C.text2))])),
            ]),
            const SizedBox(width: 24),
            Expanded(child: Btn('Book now', onTap: () { booking.update(() { booking.car = car; booking.extras.clear(); }); Navigator.push(context, MaterialPageRoute(builder: (_) => const OptionsScreen())); })),
          ]),
        ),
      );
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Widget row(IconData i, String t, String s) => ListTile(leading: CircleAvatar(backgroundColor: C.light, child: Icon(i, color: C.primary, size: 20)), title: Text(t, style: const TextStyle(fontWeight: FontWeight.w500)), subtitle: Text(s));
    Widget head(String t) => Padding(padding: const EdgeInsets.fromLTRB(24, 16, 24, 4), child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600, color: C.text2)));
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(children: [
        head('Today'), row(Icons.check_circle_outline, 'Payment successful', 'Your payment was received.'), row(Icons.alarm, 'Pickup reminder', 'Pickup is in 2 days at 10:00 AM.'),
        head('Yesterday'), row(Icons.local_offer_outlined, '20% off weekend rentals', 'Applied automatically at checkout.'),
        head('Earlier'), row(Icons.star_outline, 'How was your last trip?', 'Leave a review for Toyota Vios.'),
      ]),
    );
  }
}
