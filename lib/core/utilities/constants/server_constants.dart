/// Ordered list of HiveAuth websocket endpoints.
///
/// The primary endpoint is HiveAuth host. The legacy other
/// instance remains as a fallback so logins continue to work if the primary
/// host is unreachable or during phased migrations.
const List<String> socketServers = <String>[
  'wss://hive-auth.arcange.eu',
  'wss://ha.ecency.com',
];
