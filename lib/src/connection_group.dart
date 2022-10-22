// Copyright (C) 2022 by Voidari LLC or its subsidiaries.
library signals_slots;

import 'package:signals_slots/src/connection.dart';

/// A utility class for tracking connections and provides a way to
/// disconnect all connections on dispose.
class ConnectionGroup {
  /// The list of connections being tracked.
  final List<Connection> _connections = <Connection>[];

  /// Adds a connection to the connection group.
  void add(Connection connection) {
    _connections.add(connection);
  }

  /// Removes a connection from the connection group.
  void remove(Connection connection) {
    _connections.remove(connection);
  }

  /// Disconnects all the connections. Should be called at the end
  /// of the connections' lifecycle for cleanup.
  void disconnectAll() {
    for (Connection connection in _connections) {
      connection.disconnect();
    }
  }
}
