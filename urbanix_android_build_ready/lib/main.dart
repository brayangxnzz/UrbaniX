import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'models.dart';
import 'signed_pass_service.dart';
import 'trusted_issuers.dart';
import 'wallet_controller.dart';

const purple = Color(0xFF8046F5);
const darkPurple = Color(0xFF4723BA);
const navy = Color(0xFF192445);
const lavender = Color(0xFFF6F3FF);
const blue = Color(0xFF337DFA);
const subtle = Color(0xFF716B87);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UrbanixApp());
}

class UrbanixApp extends StatelessWidget {
  const UrbanixApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Urbanix V3',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: lavender,
      colorScheme: ColorScheme.fromSeed(seedColor: purple, primary: purple,
        surface: Colors.white),
      appBarTheme: const AppBarTheme(backgroundColor: lavender,
        foregroundColor: navy, centerTitle: false),
      cardTheme: const CardThemeData(color: Colors.white, elevation: 0),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        backgroundColor: blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)))),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true, fillColor: Colors.white),
    ),
    home: const UrbanixShell(),
  );
}

class UrbanixShell extends StatefulWidget {
  const UrbanixShell({super.key});
  @override
  State<UrbanixShell> createState() => _UrbanixShellState();
}

class _UrbanixShellState extends State<UrbanixShell> {
  final wallet = WalletController(SignedPassService());
  int tab = 0;
  @override
  void initState() {
    super.initState();
    wallet.addListener(_refresh);
    wallet.initialize();
  }
  void _refresh() { if (mounted) setState(() {}); }
  @override
  void dispose() {
    wallet.removeListener(_refresh);
    wallet.dispose();
    super.dispose();
  }

  void openRoute(RouteInfo route) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => JourneyScreen(route: route, wallet: wallet)));
  }
  void openPass(ActivePass pass) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => PassScreen(pass: pass)));
  }
  void openValidator() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ValidatorScreen(service: wallet.passService,
        localQr: wallet.data.activePass?.code)));
  }
  @override
  Widget build(BuildContext context) {
    if (wallet.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (wallet.error != null) {
      return Scaffold(body: Center(child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 45),
          const SizedBox(height: 12),
          const Text('No se pudieron cargar los datos locales',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 19,
              fontWeight: FontWeight.bold)),
          const SizedBox(height: 8), Text(wallet.error!, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text('Tus datos no se borraron. No reinstales ni borres datos.\n'
            'Recupera el respaldo antes de continuar.', textAlign: TextAlign.center),
        ]),
      )));
    }
    final views = <Widget>[
      HomePage(wallet: wallet, onRoute: openRoute,
        onWallet: () => setState(() => tab = 1),
        onValidator: openValidator, onPass: openPass),
      WalletPage(wallet: wallet, onRoute: openRoute),
      HistoryPage(wallet: wallet),
      ProfilePage(wallet: wallet, onValidator: openValidator),
    ];
    return Scaffold(
      body: SafeArea(child: IndexedStack(index: tab, children: views)),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        height: 72,
        indicatorColor: const Color(0xFFE8DEFF),
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number), label: 'Tickets'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart), label: 'Viajes'),
          NavigationDestination(icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person), label: 'Cuenta'),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final WalletController wallet;
  final ValueChanged<RouteInfo> onRoute;
  final VoidCallback onWallet;
  final VoidCallback onValidator;
  final ValueChanged<ActivePass> onPass;
  const HomePage({super.key, required this.wallet, required this.onRoute,
    required this.onWallet, required this.onValidator, required this.onPass});
  @override
  Widget build(BuildContext context) {
    final d = wallet.data;
    final active = d.activePass;
    final showActive = active != null &&
      DateTime.now().millisecondsSinceEpoch < active.expiresAt;
    return ListView(children: [
      Container(
        decoration: const BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF5E3AE6), Color(0xFFA663FA), Color(0xFFCCB1FF)]),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(34))),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const CircleAvatar(backgroundColor: Colors.white24,
              child: Icon(Icons.person_outline, color: Colors.white)),
            const SizedBox(width: 10),
            Expanded(child: Text('¡Hola, ${d.profileName}! 👋',
              style: const TextStyle(color: Colors.white, fontSize: 17,
                fontWeight: FontWeight.w600))),
            const Icon(Icons.directions_transit, color: Colors.white),
          ]),
          const SizedBox(height: 30),
          const Text('Saldo disponible · demo', style: TextStyle(
            color: Color(0xFFEEE5FF), fontSize: 13)),
          const SizedBox(height: 4),
          Text(money(d.balanceCents), style: const TextStyle(
            color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${d.totalTickets} tickets de prueba', style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _HeaderButton(label: 'Mis tickets',
              icon: Icons.confirmation_number_outlined, onTap: onWallet)),
            const SizedBox(width: 10),
            Expanded(child: _HeaderButton(label: 'Validar QR',
              icon: Icons.qr_code_scanner, onTap: onValidator)),
          ]),
        ]),
      ),
      Padding(padding: const EdgeInsets.fromLTRB(20, 26, 20, 8), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Elige tu transporte', style: TextStyle(fontSize: 23,
            fontWeight: FontWeight.w800, color: navy)),
          const SizedBox(height: 5),
          const Text('Metro, Transmetro y rutas urbanas',
            style: TextStyle(color: subtle)),
          const SizedBox(height: 17),
          SizedBox(height: 202, child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: RouteInfo.all.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final route = RouteInfo.all[i];
              return RouteCard(route: route, onTap: () => onRoute(route));
            },
          )),
          if (showActive) ...[
            const SizedBox(height: 22),
            InkWell(onTap: () => onPass(active), borderRadius: BorderRadius.circular(20),
              child: Container(padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: const Color(0xFFE8E1FF),
                  borderRadius: BorderRadius.circular(20)),
                child: const Row(children: [
                  Icon(Icons.qr_code_2, color: darkPurple, size: 34),
                  SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text('Tienes un QR activo',
                      style: TextStyle(fontWeight: FontWeight.bold, color: navy)),
                      Text('Toca para volver a mostrarlo',
                        style: TextStyle(color: subtle))])),
                  Icon(Icons.chevron_right, color: darkPurple),
                ]))),
          ],
          const SizedBox(height: 22),
          Container(padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(gradient: const LinearGradient(
              colors: [Color(0xFF246FF4), Color(0xFF9B3FFD)]),
              borderRadius: BorderRadius.circular(20)),
            child: const Row(children: [
              Icon(Icons.school_outlined, color: Colors.white, size: 38),
              SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text('Tu movilidad, bajo control',
                  style: TextStyle(color: Colors.white, fontSize: 16,
                    fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Consulta tus viajes y gastos estimados.',
                    style: TextStyle(color: Colors.white))])),
            ])),
          const SizedBox(height: 12),
          const Text('ENTORNO DE PRUEBAS · Los QR son válidos dentro de Urbanix V3.',
            style: TextStyle(fontSize: 10, color: subtle)),
        ],
      )),
    ]);
  }
}

class _HeaderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderButton({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap, icon: Icon(icon, size: 18), label: Text(label),
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(0, 46),
      foregroundColor: darkPurple, backgroundColor: Colors.white,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))));
}

class RouteCard extends StatelessWidget {
  final RouteInfo route;
  final VoidCallback onTap;
  const RouteCard({super.key, required this.route, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(22),
    child: Container(width: 170, padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Color(0x110C0A33), blurRadius: 15,
          offset: Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: 98, alignment: Alignment.center,
          decoration: BoxDecoration(color: Color(route.colorValue).withOpacity(0.12),
            borderRadius: BorderRadius.circular(16)),
          child: Image.asset(route.asset, height: 83, fit: BoxFit.contain)),
        const SizedBox(height: 11),
        Text(route.label, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
            color: navy)),
        const SizedBox(height: 3),
        Text('${money(route.fareCents)} MXN', style: TextStyle(
          fontWeight: FontWeight.bold, color: Color(route.colorValue))),
      ])));
}

class WalletPage extends StatelessWidget {
  final WalletController wallet;
  final ValueChanged<RouteInfo> onRoute;
  const WalletPage({super.key, required this.wallet, required this.onRoute});

  Future<void> _showAddDialog(BuildContext context) async {
    String route = RouteInfo.all.first.id;
    int amount = 2;
    bool processing = false;
    await showDialog<void>(context: context, builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, update) => AlertDialog(
        title: const Text('Agregar tickets de prueba'),
        content: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('No realiza cobros ni carga tickets de Urbanix V2.',
              style: TextStyle(color: subtle, fontSize: 12)),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: route,
              items: RouteInfo.all.map((r) => DropdownMenuItem(
                value: r.id, child: Text(r.label))).toList(),
              onChanged: processing ? null : (v) => update(() => route = v!),
              decoration: const InputDecoration(labelText: 'Transporte')),
            const SizedBox(height: 12),
            Row(children: [const Text('Tickets'), const Spacer(),
              IconButton(onPressed: processing || amount == 1 ? null :
                () => update(() => amount--), icon: const Icon(Icons.remove_circle_outline)),
              Text('$amount', style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(onPressed: processing || amount == 20 ? null :
                () => update(() => amount++), icon: const Icon(Icons.add_circle_outline))]),
          ]),
        actions: [
          TextButton(onPressed: processing ? null :
            () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          FilledButton(onPressed: processing ? null : () async {
            update(() => processing = true);
            try {
              await wallet.addDemoTickets(route, amount);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              if (context.mounted) showNotice(context, 'Se agregaron $amount tickets de prueba');
            } catch (e) {
              if (dialogContext.mounted) update(() => processing = false);
              if (context.mounted) showNotice(context, '$e');
            }
          }, child: const Text('Agregar')),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) => Column(children: [
    const PageHeader(title: 'Mis Tickets', subtitle: 'Tus pases disponibles'),
    Expanded(child: ListView(padding: const EdgeInsets.all(20), children: [
      Container(padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(color: purple,
          borderRadius: BorderRadius.circular(22)),
        child: Row(children: [
          const Icon(Icons.confirmation_number, color: Colors.white, size: 34),
          const SizedBox(width: 14),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${wallet.data.totalTickets} tickets', style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
            const Text('Saldo local de demostración',
              style: TextStyle(color: Colors.white70)),
          ]),
        ])),
      const SizedBox(height: 22),
      ...RouteInfo.all.map((route) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(onTap: () => onRoute(route),
          borderRadius: BorderRadius.circular(18),
          child: Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              Container(width: 76, height: 62, padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Color(route.colorValue).withOpacity(0.13),
                  borderRadius: BorderRadius.circular(14)),
                child: Image.asset(route.asset)),
              const SizedBox(width: 13),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(route.label, style: const TextStyle(
                  fontWeight: FontWeight.bold, color: navy)),
                  const SizedBox(height: 3),
                  Text('${wallet.data.count(route.id)} tickets disponibles',
                    style: const TextStyle(fontSize: 12, color: subtle))])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 13,
                vertical: 8), decoration: BoxDecoration(
                  color: Color(route.colorValue).withOpacity(0.13),
                  borderRadius: BorderRadius.circular(17)),
                child: Text('${wallet.data.count(route.id)}', style: TextStyle(
                  color: Color(route.colorValue), fontWeight: FontWeight.bold))),
            ]))))),
      const SizedBox(height: 14),
      FilledButton.icon(onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add), label: const Text('Cargar tickets de prueba')),
      const SizedBox(height: 10),
      const Text('Solo funciona dentro de Urbanix V3. No son boletos oficiales.',
        textAlign: TextAlign.center,
        style: TextStyle(color: subtle, fontSize: 12)),
    ])),
  ]);
}

class JourneyScreen extends StatefulWidget {
  final RouteInfo route;
  final WalletController wallet;
  const JourneyScreen({super.key, required this.route, required this.wallet});
  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}
class _JourneyScreenState extends State<JourneyScreen> {
  int passengers = 1;
  bool busy = false;
  Future<void> _issue() async {
    setState(() => busy = true);
    try {
      final pass = await widget.wallet.issue(widget.route.id, passengers);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(
        builder: (_) => PassScreen(pass: pass)));
    } catch (e) {
      if (mounted) showNotice(context, e.toString().replaceAll('Bad state: ', ''));
    } finally { if (mounted) setState(() => busy = false); }
  }
  @override
  Widget build(BuildContext context) {
    final route = widget.route;
    final available = widget.wallet.data.count(route.id);
    final total = passengers * route.fareCents;
    return Scaffold(
      appBar: AppBar(title: const Text('Número de pasajeros')),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        const SizedBox(height: 12),
        Center(child: Container(height: 155, width: 220,
          decoration: BoxDecoration(color: Color(route.colorValue).withOpacity(0.13),
            borderRadius: BorderRadius.circular(25)),
          child: Image.asset(route.asset, fit: BoxFit.contain))),
        const SizedBox(height: 25),
        Text(route.label, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28, color: navy, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('Selecciona cuántas personas viajarán',
          textAlign: TextAlign.center, style: TextStyle(color: subtle)),
        const SizedBox(height: 26),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          RoundStep(icon: Icons.remove, enabled: passengers > 1 && !busy,
            onTap: () => setState(() => passengers--), color: Color(route.colorValue)),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text('$passengers', style: const TextStyle(fontSize: 40,
              fontWeight: FontWeight.bold, color: navy))),
          RoundStep(icon: Icons.add, enabled: passengers < 9 && !busy,
            onTap: () => setState(() => passengers++), color: Color(route.colorValue)),
        ]),
        const SizedBox(height: 25),
        Container(padding: const EdgeInsets.all(21),
          decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(23)),
          child: Column(children: [
            DetailLine(label: 'Tarifa', value: money(route.fareCents)),
            const SizedBox(height: 12),
            DetailLine(label: 'Pasajeros', value: '$passengers'),
            const SizedBox(height: 12),
            DetailLine(label: 'Tickets disponibles', value: '$available'),
            const Divider(height: 32),
            DetailLine(label: 'Costo estimado', value: '${money(total)} MXN', strong: true),
            const SizedBox(height: 12),
            DetailLine(label: 'Después del viaje',
              value: '${available - passengers < 0 ? 0 : available - passengers} tickets'),
          ])),
        const SizedBox(height: 24),
        FilledButton.icon(onPressed: busy || available < passengers ? null : _issue,
          icon: const Icon(Icons.qr_code),
          label: Text(busy ? 'Generando pase...' : 'Generar QR (15 min)')),
        const SizedBox(height: 12),
        Text(available < passengers ? 'Créditos insuficientes. Agrega tickets de prueba en Saldo.' :
          'Se descontará un ticket de prueba por pasajero.',
          textAlign: TextAlign.center, style: const TextStyle(color: subtle)),
      ]),
    );
  }
}

class PassScreen extends StatefulWidget {
  final ActivePass pass;
  const PassScreen({super.key, required this.pass});
  @override
  State<PassScreen> createState() => _PassScreenState();
}
class _PassScreenState extends State<PassScreen> {
  Timer? clock;
  @override
  void initState() {
    super.initState();
    clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }
  @override
  void dispose() { clock?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final pass = widget.pass;
    final route = RouteInfo.find(pass.route)!;
    final remaining = pass.expiresAt - DateTime.now().millisecondsSinceEpoch;
    final active = remaining > 0;
    final seconds = active ? (remaining / 1000).ceil() : 0;
    final minutesLabel = '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
    return Scaffold(
      backgroundColor: Color(route.colorValue),
      appBar: AppBar(title: const Text('URBANIX · QR de acceso'),
        foregroundColor: Colors.white, backgroundColor: Color(route.colorValue)),
      body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(22),
        child: Column(children: [
          Container(padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
            decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(26)),
            child: Column(children: [
              SizedBox(height: 53, child: Image.asset(route.asset)),
              const SizedBox(height: 8),
              Text(route.label, style: const TextStyle(fontSize: 19,
                fontWeight: FontWeight.bold, color: navy)),
              Text('× ${pass.passengers} Pasajero(s)',
                style: const TextStyle(color: darkPurple,
                  fontWeight: FontWeight.w700)),
              const SizedBox(height: 18),
              if (active)
                LayoutBuilder(builder: (context, constraints) => QrImageView(
                  data: pass.code, version: QrVersions.auto,
                  size: constraints.maxWidth.clamp(0.0, 330.0).toDouble(),
                  backgroundColor: Colors.white,
                  errorCorrectionLevel: QrErrorCorrectLevel.L))
              else
                const SizedBox(height: 230, child: Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.timer_off_outlined, size: 45, color: subtle),
                    SizedBox(height: 10), Text('QR caducado',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold))]))),
              const SizedBox(height: 15),
              const Divider(thickness: 1.5),
              const SizedBox(height: 8),
              const Text('Código válido durante:',
                style: TextStyle(color: subtle, fontSize: 14)),
              const SizedBox(height: 9),
              Container(padding: const EdgeInsets.symmetric(
                horizontal: 25, vertical: 11),
                decoration: BoxDecoration(color: const Color(0xFFEEE8FF),
                  borderRadius: BorderRadius.circular(30)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.timer_outlined, color: darkPurple),
                  const SizedBox(width: 9),
                  Text(minutesLabel, style: const TextStyle(color: darkPurple,
                    fontWeight: FontWeight.bold, fontSize: 24)),
                ])),
            ])),
          const SizedBox(height: 16),
          const Text('PASE DE PRUEBA · VÁLIDO SOLO EN URBANIX V3',
            style: TextStyle(color: Colors.white, fontSize: 11,
              fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 18),
          FilledButton.icon(onPressed: () => Clipboard.setData(
              ClipboardData(text: pass.code)),
            style: FilledButton.styleFrom(backgroundColor: navy),
            icon: const Icon(Icons.copy), label: const Text('Copiar contenido del QR')),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white70),
              minimumSize: const Size.fromHeight(48)),
            child: const Text('Volver a Urbanix')),
        ]))),
    );
  }
}

class HistoryPage extends StatefulWidget {
  final WalletController wallet;
  const HistoryPage({super.key, required this.wallet});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}
class _HistoryPageState extends State<HistoryPage> {
  bool month = false;
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final min = month ? DateTime(now.year, now.month) :
      now.subtract(const Duration(days: 7));
    final entries = widget.wallet.data.entries;
    final trips = entries.where((e) => e.kind == 'trip' &&
      DateTime.fromMillisecondsSinceEpoch(e.occurredAt).isAfter(min)).toList();
    final total = trips.fold<int>(0, (v, e) => v + e.count * e.fareCents);
    final rides = trips.fold<int>(0, (v, e) => v + e.count);
    return Column(children: [
      const PageHeader(title: 'Mis viajes', subtitle: 'Reporte de movilidad estudiantil'),
      Expanded(child: ListView(padding: const EdgeInsets.all(20), children: [
        SegmentedButton<bool>(segments: const [
          ButtonSegment(value: false, label: Text('Últimos 7 días')),
          ButtonSegment(value: true, label: Text('Este mes')),
        ], selected: {month}, onSelectionChanged: (value) =>
          setState(() => month = value.first)),
        const SizedBox(height: 18),
        Container(padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(gradient: const LinearGradient(
            colors: [purple, darkPurple]), borderRadius: BorderRadius.circular(22)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Gasto estimado en transporte',
              style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            Text('${money(total)} MXN', style: const TextStyle(
              color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('$rides pasajeros registrados · ${trips.length} operaciones',
              style: const TextStyle(color: Colors.white)),
          ])),
        const SizedBox(height: 22),
        const Text('Movimientos', style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: navy)),
        const SizedBox(height: 12),
        if (entries.isEmpty) const Padding(padding: EdgeInsets.all(24),
          child: Center(child: Text('Aún no hay viajes ni recargas de prueba',
            style: TextStyle(color: subtle)))),
        ...entries.take(100).map((entry) {
          final info = RouteInfo.find(entry.route);
          final date = DateTime.fromMillisecondsSinceEpoch(entry.occurredAt);
          return Container(margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white,
              borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              CircleAvatar(backgroundColor: entry.kind == 'trip'
                ? const Color(0xFFEEE8FF) : const Color(0xFFE8F8EE),
                child: Icon(entry.kind == 'trip' ? Icons.directions_bus : Icons.add,
                  color: entry.kind == 'trip' ? purple : Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(entry.route, style: const TextStyle(
                  fontWeight: FontWeight.bold, color: navy)),
                  Text('${date.day}/${date.month}/${date.year} · '
                    '${entry.kind == 'trip' ? 'Viaje de prueba' : 'Recarga de prueba'}',
                    style: const TextStyle(fontSize: 12, color: subtle))])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${entry.kind == 'trip' ? '−' : '+'}${entry.count} tickets',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
                if (entry.kind == 'trip' && info != null)
                  Text(money(entry.fareCents * entry.count),
                    style: const TextStyle(fontSize: 12, color: subtle)),
              ]),
            ]));
        }),
        const SizedBox(height: 18),
        const Text('Importes referenciales de prueba. No representan pagos reales.',
          style: TextStyle(fontSize: 11, color: subtle)),
      ])),
    ]);
  }
}

class ProfilePage extends StatefulWidget {
  final WalletController wallet;
  final VoidCallback onValidator;
  const ProfilePage({super.key, required this.wallet, required this.onValidator});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  late final Future<String> keyFuture;
  @override
  void initState() { super.initState(); keyFuture = widget.wallet.passService.exportIssuerPublicKey(); }
  Future<void> editProfile() async {
    final name = TextEditingController(text: widget.wallet.data.profileName);
    String gender = widget.wallet.data.gender;
    try {
      await showDialog<void>(context: context, builder: (dialogContext) =>
        StatefulBuilder(builder: (dialogContext, update) => AlertDialog(
          title: const Text('Configurar perfil'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Nombre')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(value: gender,
              items: const ['Sin especificar', 'Femenino', 'Masculino']
                .map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (v) => update(() => gender = v!),
              decoration: const InputDecoration(labelText: 'Género')),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar')),
            FilledButton(onPressed: () async {
              try {
                await widget.wallet.setProfile(name.text, gender);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              } catch (e) {
                if (dialogContext.mounted) showNotice(dialogContext, '$e');
              }
            }, child: const Text('Guardar')),
          ],
        )));
    } finally { name.dispose(); }
  }
  @override
  Widget build(BuildContext context) => Column(children: [
    const PageHeader(title: 'Mi cuenta', subtitle: 'Configuración del usuario'),
    Expanded(child: ListView(padding: const EdgeInsets.all(20), children: [
      Center(child: CircleAvatar(radius: 47,
        backgroundColor: const Color(0xFFE9DEFF),
        child: const Icon(Icons.person, size: 51, color: darkPurple))),
      const SizedBox(height: 13),
      Text(widget.wallet.data.profileName, textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: navy)),
      const SizedBox(height: 23),
      FilledButton.icon(onPressed: editProfile,
        icon: const Icon(Icons.edit_outlined), label: const Text('Modificar perfil')),
      const SizedBox(height: 25),
      const Text('Tarifas de referencia', style: TextStyle(
        fontSize: 19, fontWeight: FontWeight.bold, color: navy)),
      const SizedBox(height: 12),
      Container(padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(19)),
        child: Column(children: RouteInfo.all.map((route) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: DetailLine(label: route.label,
            value: money(route.fareCents)))).toList())),
      const SizedBox(height: 25),
      const Text('Herramientas de validación', style: TextStyle(
        fontSize: 19, fontWeight: FontWeight.bold, color: navy)),
      const SizedBox(height: 12),
      OutlinedButton.icon(onPressed: widget.onValidator,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Verificar un QR de Urbanix V3')),
      const SizedBox(height: 12),
      FutureBuilder<String>(future: keyFuture, builder: (context, snapshot) {
        if (snapshot.hasError) return const Text('Error al consultar clave pública');
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return Container(padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.white,
            borderRadius: BorderRadius.circular(18)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Mi clave pública de emisor', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 9),
            SelectableText(snapshot.data!, style: const TextStyle(fontSize: 11)),
            TextButton.icon(onPressed: () {
              Clipboard.setData(ClipboardData(text: snapshot.data!));
              showNotice(context, 'Clave pública copiada');
            }, icon: const Icon(Icons.copy), label: const Text('Copiar clave pública')),
          ]));
      }),
      const SizedBox(height: 25),
      const Text('Urbanix V3 · Entorno de pruebas local',
        textAlign: TextAlign.center, style: TextStyle(color: subtle, fontSize: 11)),
    ])),
  ]);
}

class ValidatorScreen extends StatefulWidget {
  final SignedPassService service;
  final String? localQr;
  const ValidatorScreen({super.key, required this.service, this.localQr});
  @override
  State<ValidatorScreen> createState() => _ValidatorScreenState();
}
class _ValidatorScreenState extends State<ValidatorScreen> {
  final input = TextEditingController();
  final newIssuer = TextEditingController();
  final trust = TrustedIssuers();
  PassCheck? result;
  bool working = false;
  Set<String> trustedKeys = {};
  @override
  void initState() {
    super.initState();
    if (widget.localQr != null) input.text = widget.localQr!;
    trust.load().then((value) {
      if (mounted) setState(() => trustedKeys = value);
    });
  }
  @override
  void dispose() { input.dispose(); newIssuer.dispose(); super.dispose(); }
  Future<void> check({required bool consume}) async {
    if (working) return;
    setState(() => working = true);
    try {
      final local = await widget.service.exportIssuerPublicKey();
      final output = await widget.service.verify(input.text.trim(),
        now: DateTime.now(), consume: consume,
        trustedIssuerKeys: {...trustedKeys, local});
      if (mounted) setState(() => result = output);
    } finally { if (mounted) setState(() => working = false); }
  }
  Future<void> registerIssuer() async {
    final ok = await trust.register(newIssuer.text.trim());
    if (!mounted) return;
    if (ok) {
      final keys = await trust.load();
      setState(() {trustedKeys = keys; newIssuer.clear();});
    }
    showNotice(context, ok ? 'Emisor autorizado localmente' : 'Clave pública no válida');
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Verificador de QR')),
    body: ListView(padding: const EdgeInsets.all(21), children: [
      Container(padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: const Color(0xFFEAE3FF),
          borderRadius: BorderRadius.circular(17)),
        child: const Text('Verifica la firma de un QR Urbanix V3, su vigencia y '
          'si ya fue registrado como utilizado en este teléfono.',
          style: TextStyle(color: navy))),
      const SizedBox(height: 22),
      TextField(controller: input, minLines: 3, maxLines: 7,
        decoration: const InputDecoration(labelText: 'Contenido del QR',
          hintText: 'UV3....')),
      const SizedBox(height: 10),
      OutlinedButton.icon(onPressed: () async {
        final data = await Clipboard.getData('text/plain');
        if (mounted) setState(() => input.text = data?.text ?? '');
      }, icon: const Icon(Icons.content_paste),
        label: const Text('Pegar desde portapapeles')),
      const SizedBox(height: 10),
      FilledButton.icon(onPressed: working ? null : () => check(consume: false),
        icon: const Icon(Icons.verified_user_outlined),
        label: const Text('Comprobar autenticidad')),
      const SizedBox(height: 10),
      FilledButton.icon(onPressed: working ? null : () => check(consume: true),
        style: FilledButton.styleFrom(backgroundColor: darkPurple),
        icon: const Icon(Icons.done_all),
        label: const Text('Aceptar y registrar uso')),
      if (result != null) ...[
        const SizedBox(height: 18),
        Container(padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: result!.valid
            ? const Color(0xFFE0F6E8) : const Color(0xFFFFE4E4),
            borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            Icon(result!.valid ? Icons.check_circle : Icons.error_outline,
              color: result!.valid ? Colors.green : Colors.red),
            const SizedBox(width: 12),
            Expanded(child: Text(result!.message,
              style: const TextStyle(fontWeight: FontWeight.bold))),
          ])),
      ],
      const SizedBox(height: 28),
      const Text('Emisores de confianza',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      const SizedBox(height: 10),
      const Text('En otro dispositivo registra primero su clave pública, '
        'obtenida de una fuente de confianza. No confíes automáticamente en '
        'la clave incluida dentro del QR.',
        style: TextStyle(fontSize: 12, color: subtle)),
      const SizedBox(height: 12),
      TextField(controller: newIssuer,
        decoration: const InputDecoration(labelText: 'Clave pública de emisor')),
      const SizedBox(height: 8),
      OutlinedButton(onPressed: registerIssuer,
        child: const Text('Registrar emisor')),
      Text('${trustedKeys.length} emisores adicionales registrados',
        style: const TextStyle(fontSize: 12, color: subtle)),
    ]),
  );
}

class PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const PageHeader({super.key, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity, padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
    decoration: const BoxDecoration(gradient: LinearGradient(
      colors: [purple, Color(0xFFB17EF8)]),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(28))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Colors.white,
        fontSize: 29, fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      Text(subtitle, style: const TextStyle(color: Colors.white70)),
    ]));
}

class RoundStep extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final Color color;
  const RoundStep({super.key, required this.icon, required this.enabled,
    required this.onTap, required this.color});
  @override
  Widget build(BuildContext context) => IconButton.filled(
    onPressed: enabled ? onTap : null, icon: Icon(icon),
    style: IconButton.styleFrom(backgroundColor: color,
      disabledBackgroundColor: Colors.grey.shade300,
      minimumSize: const Size(47, 47)));
}

class DetailLine extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;
  const DetailLine({super.key, required this.label, required this.value,
    this.strong = false});
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text(label, style: TextStyle(color: strong ? navy : subtle,
      fontWeight: strong ? FontWeight.bold : FontWeight.normal))),
    Text(value, style: TextStyle(fontWeight: FontWeight.bold,
      fontSize: strong ? 18 : 14, color: strong ? purple : navy)),
  ]);
}

void showNotice(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}
