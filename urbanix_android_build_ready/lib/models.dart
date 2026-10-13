import 'dart:convert';

class RouteInfo {
  final String id;
  final String label;
  final String subtitle;
  final String asset;
  final int fareCents;
  final int colorValue;
  const RouteInfo(this.id, this.label, this.subtitle, this.asset,
      this.fareCents, this.colorValue);

  static const all = <RouteInfo>[
    RouteInfo('Metro', 'Metro', 'Metrorrey', 'assets/routes/metro.png', 900, 0xFF2B7FFF),
    RouteInfo('Transmetro', 'Transmetro', 'Metrorrey', 'assets/routes/transmetro.png', 1500, 0xFF13A6CA),
    RouteInfo('Ruta Integrada', 'Ruta Integrada', 'Camión urbano', 'assets/routes/ruta_integrada.png', 1500, 0xFFEB5267),
    RouteInfo('Muevo León', 'Muevo León', 'Camión urbano', 'assets/routes/muevo_leon.png', 1650, 0xFF44CB43),
  ];
  static RouteInfo? find(String name) {
    for (final route in all) {
      if (route.id == name) return route;
    }
    return null;
  }
}

String money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

class WalletEntry {
  final String id;
  final String route;
  final int count;
  final int fareCents;
  final int occurredAt;
  final String kind; // credit | trip

  const WalletEntry({required this.id, required this.route,
    required this.count, required this.fareCents,
    required this.occurredAt, required this.kind});

  Map<String, dynamic> toJson() => {
    'id': id, 'route': route, 'count': count, 'fareCents': fareCents,
    'occurredAt': occurredAt, 'kind': kind,
  };

  factory WalletEntry.fromJson(Map<String, dynamic> value) => WalletEntry(
    id: value['id'] as String,
    route: value['route'] as String,
    count: value['count'] as int,
    fareCents: value['fareCents'] as int,
    occurredAt: value['occurredAt'] as int,
    kind: value['kind'] as String,
  );
}

class ActivePass {
  final String code;
  final String route;
  final int passengers;
  final int expiresAt;
  const ActivePass({required this.code, required this.route,
    required this.passengers, required this.expiresAt});
  Map<String, dynamic> toJson() => {
    'code': code, 'route': route, 'passengers': passengers,
    'expiresAt': expiresAt,
  };
  factory ActivePass.fromJson(Map<String, dynamic> value) => ActivePass(
    code: value['code'] as String,
    route: value['route'] as String,
    passengers: value['passengers'] as int,
    expiresAt: value['expiresAt'] as int,
  );
}

class WalletData {
  final Map<String, int> tickets;
  final List<WalletEntry> entries;
  final ActivePass? activePass;
  final String profileName;
  final String gender;

  const WalletData({required this.tickets, required this.entries,
    required this.activePass, required this.profileName, required this.gender});

  factory WalletData.initial() => WalletData(
    tickets: {for (final route in RouteInfo.all) route.id: 5},
    entries: const [], activePass: null,
    profileName: 'Usuario', gender: 'Sin especificar',
  );

  WalletData copyWith({Map<String, int>? tickets, List<WalletEntry>? entries,
    ActivePass? activePass, bool clearActivePass = false,
    String? profileName, String? gender}) => WalletData(
      tickets: tickets ?? this.tickets,
      entries: entries ?? this.entries,
      activePass: clearActivePass ? null : activePass ?? this.activePass,
      profileName: profileName ?? this.profileName,
      gender: gender ?? this.gender,
    );

  int count(String route) => tickets[route] ?? 0;
  int get totalTickets => tickets.values.fold<int>(0, (a, b) => a + b);
  int get balanceCents => RouteInfo.all.fold<int>(0,
      (a, r) => a + r.fareCents * count(r.id));

  Map<String, dynamic> toJson() => {
    'version': 1, 'tickets': tickets,
    'entries': entries.map((e) => e.toJson()).toList(),
    'activePass': activePass?.toJson(),
    'profileName': profileName, 'gender': gender,
  };
  String encode() => jsonEncode(toJson());

  factory WalletData.decode(String raw) {
    final m = jsonDecode(raw) as Map<String, dynamic>;
    final source = m['tickets'] as Map<String, dynamic>;
    final tickets = <String, int>{};
    for (final route in RouteInfo.all) {
      final count = source[route.id];
      if (count is! int || count < 0 || count > 100000) {
        throw const FormatException('Saldo no válido');
      }
      tickets[route.id] = count;
    }
    return WalletData(
      tickets: tickets,
      entries: ((m['entries'] as List<dynamic>?) ?? [])
          .map((e) => WalletEntry.fromJson(e as Map<String, dynamic>)).toList(),
      activePass: m['activePass'] == null ? null :
          ActivePass.fromJson(m['activePass'] as Map<String, dynamic>),
      profileName: (m['profileName'] as String?) ?? 'Usuario',
      gender: (m['gender'] as String?) ?? 'Sin especificar',
    );
  }
}
