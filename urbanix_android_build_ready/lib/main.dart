import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'signed_pass_service.dart';
import 'trusted_issuers.dart';

void main() => runApp(const UrbanixApp());

class UrbanixApp extends StatelessWidget {
  const UrbanixApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Urbanix V3 — Entorno interno',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
    home: const HomeScreen(),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final service = SignedPassService();
  final issuers = TrustedIssuers();
  final qrInput = TextEditingController();
  final publicKeyInput = TextEditingController();
  String route = SignedPassService.routes.first;
  int passengers = 1;
  String? issuedQr;
  DateTime? expires;
  String status = '';
  bool busy = false;
  Timer? timer;
  Set<String> trustedKeys = {};

  @override
  void initState() {
    super.initState();
    _loadTrust();
  }

  Future<void> _loadTrust() async {
    final keys = await issuers.load();
    if (mounted) setState(() => trustedKeys = keys);
  }

  @override
  void dispose() {
    timer?.cancel();
    qrInput.dispose();
    publicKeyInput.dispose();
    super.dispose();
  }

  Future<void> _issue() async {
    setState(() => busy = true);
    try {
      final now = DateTime.now();
      final value = await service.issue(route: route, passengers: passengers, now: now);
      if (!mounted) return;
      setState(() {
        issuedQr = value;
        expires = now.add(SignedPassService.validity);
        status = 'Pase V3 emitido. No es compatible con V2.';
      });
      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } catch (e) {
      if (mounted) setState(() => status = 'Error de emisión: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _verify({required bool consume}) async {
    final text = qrInput.text.trim();
    if (text.isEmpty) {
      setState(() => status = 'Pega el contenido de un QR V3');
      return;
    }
    final localKey = await service.exportIssuerPublicKey();
    final result = await service.verify(
      text,
      now: DateTime.now(),
      consume: consume,
      trustedIssuerKeys: {...trustedKeys, localKey},
    );
    if (mounted) setState(() => status = result.message);
  }

  Future<void> _registerIssuer() async {
    final success = await issuers.register(publicKeyInput.text);
    if (success) await _loadTrust();
    if (mounted) {
      setState(() => status = success
          ? 'Emisor registrado. Verifica su identidad por un canal confiable.'
          : 'Clave inválida o error al guardarla');
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = issuedQr != null && expires != null && DateTime.now().isBefore(expires!);
    return Scaffold(
      appBar: AppBar(title: const Text('Urbanix V3 — QR interno')),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        const Text('Emisión y validación interna con firmas Ed25519. No interoperable con Urbanix V2 ni con lectores oficiales.',
          style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 18),
        const Text('Emitir pase', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        DropdownButton<String>(
          isExpanded: true, value: route,
          items: SignedPassService.routes.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
          onChanged: active ? null : (value) => setState(() => route = value!),
        ),
        Row(children: [
          const Text('Pasajeros'),
          IconButton(onPressed: active || passengers <= 1 ? null : () => setState(() => passengers--), icon: const Icon(Icons.remove)),
          Text('$passengers'),
          IconButton(onPressed: active || passengers >= 9 ? null : () => setState(() => passengers++), icon: const Icon(Icons.add)),
        ]),
        FilledButton(onPressed: busy || active ? null : _issue, child: Text(busy ? 'Generando...' : 'Generar QR firmado')),
        if (issuedQr != null) ...[
          const SizedBox(height: 12),
          if (active) Center(child: QrImageView(data: issuedQr!, size: 285, backgroundColor: Colors.white)),
          Text(active ? 'Vence en ${expires!.difference(DateTime.now()).inSeconds}s' : 'QR caducado', textAlign: TextAlign.center),
          OutlinedButton(onPressed: () => Clipboard.setData(ClipboardData(text: issuedQr!)), child: const Text('Copiar contenido del QR')),
          OutlinedButton(onPressed: () => setState(() => qrInput.text = issuedQr!), child: const Text('Pasar al verificador')),
        ],
        const Divider(height: 36),
        const Text('Validar QR recibido', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextField(controller: qrInput, minLines: 2, maxLines: 5, decoration: const InputDecoration(labelText: 'Contenido del QR V3', border: OutlineInputBorder())),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: () => _verify(consume: false), child: const Text('Comprobar firma y vigencia')),
        FilledButton(onPressed: () => _verify(consume: true), child: const Text('Aceptar y registrar uso')),
        const Divider(height: 36),
        const Text('Emisores de confianza', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text('La clave pública debe obtenerse directamente del administrador, no de un QR recibido.'),
        TextField(controller: publicKeyInput, decoration: const InputDecoration(labelText: 'Clave pública de otro emisor', border: OutlineInputBorder())),
        OutlinedButton(onPressed: _registerIssuer, child: const Text('Registrar emisor')),
        Text('Emisores registrados: ${trustedKeys.length}'),
        FutureBuilder<String>(future: service.exportIssuerPublicKey(), builder: (context, snapshot) {
          if (snapshot.hasError) return const Text('No se pudo abrir la identidad de esta instalación');
          if (!snapshot.hasData) return const Text('Cargando identidad...');
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Mi clave pública de emisión:'),
            SelectableText(snapshot.data!, style: const TextStyle(fontSize: 12)),
            OutlinedButton(onPressed: () => Clipboard.setData(ClipboardData(text: snapshot.data!)), child: const Text('Copiar mi clave pública')),
          ]);
        }),
        const Divider(height: 28),
        Text(status, textAlign: TextAlign.center),
        const SizedBox(height: 18),
      ]),
    );
  }
}
