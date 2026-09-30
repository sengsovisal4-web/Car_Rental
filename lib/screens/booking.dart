import 'package:flutter/material.dart';
import '../core.dart';
import 'home.dart';

class PickupScreen extends StatefulWidget {
  const PickupScreen({super.key});
  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  String sel = booking.pickup;
  String q = '';
  @override
  Widget build(BuildContext context) {
    final list = locations.where((l) => l.$1.toLowerCase().contains(q.toLowerCase())).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Pickup location')),
      body: ListView(padding: const EdgeInsets.symmetric(horizontal: 24), children: [
        TextField(onChanged: (v) => setState(() => q = v), decoration: InputDecoration(hintText: 'Search location', prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.border)))),
        const SizedBox(height: 16),
        Container(height: 150, decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(16)), child: const Center(child: Icon(Icons.location_on, size: 44, color: C.primary))), // TODO: replace with google_maps_flutter
        const SizedBox(height: 16),
        const Text('Popular pickup locations', style: TextStyle(fontWeight: FontWeight.w600)),
        for (final l in list)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(backgroundColor: C.light, child: const Icon(Icons.place_outlined, color: C.primary, size: 20)),
            title: Text(l.$1, style: const TextStyle(fontWeight: FontWeight.w500)), subtitle: Text(l.$2),
            trailing: sel == l.$1 ? const Icon(Icons.check_circle, color: C.primary) : null,
            onTap: () => setState(() => sel = l.$1),
          ),
      ]),
      bottomNavigationBar: BottomBar(child: Btn('Confirm location', onTap: () => Navigator.pop(context, sel))),
    );
  }
}

class OptionsScreen extends StatelessWidget {
  const OptionsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Add extras')),
        body: AnimatedBuilder(
          animation: booking,
          builder: (_, __) => ListView(padding: const EdgeInsets.all(24), children: [
            for (var i = 0; i < extrasList.length; i++) ...[
              AppCard(
                bg: booking.extras.contains(i) ? C.light : Colors.white,
                borderColor: booking.extras.contains(i) ? C.primary : C.border,
                onTap: () => booking.update(() => booking.extras.contains(i) ? booking.extras.remove(i) : booking.extras.add(i)),
                child: Row(children: [
                  Checkbox(value: booking.extras.contains(i), onChanged: (_) => booking.update(() => booking.extras.contains(i) ? booking.extras.remove(i) : booking.extras.add(i))),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(extrasList[i].$1, style: const TextStyle(fontWeight: FontWeight.w600)), Text(extrasList[i].$2, style: const TextStyle(fontSize: 12, color: C.text2))])),
                  Text('+\$${extrasList[i].$3.toStringAsFixed(0)}/day', style: const TextStyle(fontWeight: FontWeight.w600)),
                ]),
              ),
              const SizedBox(height: 12),
            ],
          ]),
        ),
        bottomNavigationBar: BottomBar(
          child: AnimatedBuilder(
            animation: booking,
            builder: (_, __) => Row(children: [
              Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Extras', style: TextStyle(fontSize: 12, color: C.text2)), Text(money(booking.extrasTotal), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))]),
              const SizedBox(width: 24),
              Expanded(child: Btn('Review booking', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SummaryScreen())))),
            ]),
          ),
        ),
      );
}

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});
  Widget _line(String l, String v, {Color? c}) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l, style: const TextStyle(color: C.text2)), Text(v, style: TextStyle(fontWeight: FontWeight.w600, color: c))]));
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: booking,
        builder: (_, __) {
          final car = booking.car!;
          return Scaffold(
            appBar: AppBar(title: const Text('Booking summary')),
            body: ListView(padding: const EdgeInsets.all(24), children: [
              AppCard(child: Row(children: [const Icon(Icons.directions_car_filled, size: 44, color: C.primary), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(car.name, style: const TextStyle(fontWeight: FontWeight.w600)), Text('${fmtRange(booking.range)}  ·  ${booking.days} days', style: const TextStyle(fontSize: 12, color: C.text2))])), TextButton(onPressed: () => pickDates(context), child: const Text('Edit'))])),
              const SizedBox(height: 12),
              AppCard(child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Pickup & return', style: TextStyle(fontSize: 12, color: C.text2)), Text(booking.pickup, style: const TextStyle(fontWeight: FontWeight.w600))])), TextButton(onPressed: () async { final r = await Navigator.push<String>(context, MaterialPageRoute(builder: (_) => const PickupScreen())); if (r != null) booking.update(() => booking.pickup = r); }, child: const Text('Edit'))])),
              const SizedBox(height: 12),
              AppCard(child: Column(children: [
                _line('Rental (${booking.days} × \$${car.price.toStringAsFixed(0)})', money(booking.rental)),
                _line('Extras', money(booking.extrasTotal)),
                _line('Discount WEEKEND20', '-${money(booking.discount)}', c: C.ok),
                _line('Taxes & fees', money(booking.fees)),
                const Divider(height: 24),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [const Text('Total', style: TextStyle(fontSize: 16)), Text(money(booking.total), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: C.primary))]),
              ])),
            ]),
            bottomNavigationBar: BottomBar(child: Btn('Continue to payment', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentScreen())))),
          );
        },
      );
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int method = 0;
  bool failNext = false; // set true to preview the failure state

  Future<void> pay() async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const PopScope(canPop: false, child: AlertDialog(content: Row(children: [CircularProgressIndicator(), SizedBox(width: 20), Expanded(child: Text("Processing payment\nPlease don't close the app."))]))));
    await Future.delayed(const Duration(seconds: 2)); // TODO: call payment API
    if (!mounted) return;
    Navigator.pop(context);
    if (failNext) return _failed();
    final r = Reservation('CR-${20000 + booking.reservations.length * 7 + 481}', booking.car!, booking.range, booking.pickup, booking.total, 'Upcoming');
    booking.update(() => booking.reservations.insert(0, r));
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => SuccessScreen(r)), (route) => route.isFirst);
  }

  void _failed() => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: const CircleAvatar(radius: 32, backgroundColor: C.errBg, child: Icon(Icons.priority_high, color: C.err, size: 32)),
          title: const Text('Payment failed', textAlign: TextAlign.center),
          content: const Text("We couldn't process your payment. Check your card details or try another method.", textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.center,
          actionsOverflowDirection: VerticalDirection.down,
          actions: [SizedBox(width: double.infinity, child: Btn('Try again', onTap: () { Navigator.pop(context); setState(() => failNext = false); })), const SizedBox(height: 8), SizedBox(width: double.infinity, child: Btn('Change payment method', outline: true, onTap: () => Navigator.pop(context)))],
        ),
      );

  @override
  Widget build(BuildContext context) {
    const opts = [(Icons.credit_card, 'Visa •••• 4242', 'Expires 08/28'), (Icons.add_card, 'Add new card', 'Credit or debit'), (Icons.qr_code_2, 'QR / mobile payment', 'ABA, Wing, KHQR')];
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        AppCard(child: Column(children: [const Text('Total amount', style: TextStyle(color: C.text2)), Text(money(booking.total), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700))])),
        const SizedBox(height: 16),
        for (var i = 0; i < opts.length; i++) ...[
          AppCard(
            bg: method == i ? C.light : Colors.white, borderColor: method == i ? C.primary : C.border, onTap: () => setState(() => method = i),
            child: Row(children: [Icon(opts[i].$1, color: C.primary), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(opts[i].$2, style: const TextStyle(fontWeight: FontWeight.w600)), Text(opts[i].$3, style: const TextStyle(fontSize: 12, color: C.text2))])), Icon(method == i ? Icons.radio_button_checked : Icons.radio_button_off, color: method == i ? C.primary : C.muted)]),
          ),
          const SizedBox(height: 12),
        ],
        const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.lock_outline, size: 14, color: C.text2), SizedBox(width: 6), Text('Payments are encrypted and secure.', style: TextStyle(fontSize: 12, color: C.text2))]),
      ]),
      bottomNavigationBar: BottomBar(child: Btn('Pay ${money(booking.total)}', onTap: pay)),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  final Reservation r;
  const SuccessScreen(this.r, {super.key});
  Widget _l(String a, String b) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(a, style: const TextStyle(color: C.text2)), Flexible(child: Text(b, style: const TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.right))]));
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const Spacer(),
              const CircleAvatar(radius: 44, backgroundColor: C.okBg, child: Icon(Icons.check, size: 48, color: C.ok)),
              const SizedBox(height: 20),
              const Text('Booking confirmed', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text("We've sent the details to your email.", style: TextStyle(color: C.text2)),
              const SizedBox(height: 24),
              AppCard(child: Column(children: [_l('Booking ID', '#${r.id}'), _l('Vehicle', r.car.name), _l('Period', fmtRange(r.range)), _l('Pickup', r.pickup), const Divider(height: 24), _l('Total paid', money(r.total))])),
              const Spacer(),
              Btn('View booking', onTap: () { booking.update(() => booking.tab = 2); Navigator.popUntil(context, (route) => route.isFirst); }),
              const SizedBox(height: 12),
              Btn('Back to home', outline: true, onTap: () { booking.update(() => booking.tab = 0); Navigator.popUntil(context, (route) => route.isFirst); }),
            ]),
          ),
        ),
      );
}
