// Copyright (C) 2022 by Voidari LLC or its subsidiaries.
library signals_slots;

import 'package:signals_slots/src/connection.dart';

/// A signal is created and subscribed to by external sources,
/// which will receive the emitted signal when sent.
class Signal {
  /// The list of functions registered to the signal
  final Map<int, List<Connection>> _connectionMap = <int, List<Connection>>{};

  /// Provides the means to connect a slot [function] to a signal.
  /// Signals emitted will execute each [group] in acending order
  /// with the default of 0. The [insertAtIndex] can be used to specify
  /// where in the group the function should be added. If left null, it
  /// will insert at the end of the group. A [Connection] is returned to
  /// track the connection and disconnect the slot.
  Connection connect(Function function,
      {final int group = 0, int? insertAtIndex}) {
    // Create the connection
    Connection connection = Connection(this, function);
    reconnect(connection, group: group, insertAtIndex: insertAtIndex);
    return connection;
  }

  /// Provides the means to reconnect a slot [connection] to a signal.
  /// Signals emitted will execute each [group] in acending order
  /// with the default of 0. The [insertAtIndex] can be used to specify
  /// where in the group the function should be added. If left null, it
  /// will insert at the end of the group. Although not typical, it is valid
  /// to create a connection use the function to associate it with this signal.
  void reconnect(Connection connection,
      {final int group = 0, int? insertAtIndex}) {
    // Disconnect the connection if it's already connected
    disconnect(connection);
    // Reset the signal
    connection.signal = this;
    // Create the group if it doesn't exist
    if (!_connectionMap.containsKey(group)) {
      _connectionMap[group] = <Connection>[];
    }
    // Validate the index
    if (insertAtIndex != null && insertAtIndex < 0) {
      insertAtIndex = 0;
    } else if (insertAtIndex != null &&
        _connectionMap[group]!.length < insertAtIndex) {
      insertAtIndex = _connectionMap[group]!.length;
    }
    // Add the connection to the map
    if (insertAtIndex == null ||
        _connectionMap[group]!.isEmpty ||
        _connectionMap[group]!.length < insertAtIndex) {
      _connectionMap[group]!.add(connection);
    } else {
      _connectionMap[group]!.insert(insertAtIndex, connection);
    }
  }

  /// Determines if the [connection] is actually connected.
  bool isConnected(Connection connection) {
    for (int key in _connectionMap.keys.toList()) {
      for (Connection conn in _connectionMap[key]!) {
        if (connection == conn) {
          return true;
        }
      }
    }
    return false;
  }

  /// Disconnects a subscribed function from the signal.
  void disconnect(Connection connection) {
    _connectionMap.forEach((key, value) {
      _connectionMap[key]!.remove(connection);
    });
  }

  /// Used by the signal manager to send a signal to all subscribed connections.
  /// The parameters should match the expected registered functions with the
  /// signal. The optional result of all returned values will be included in
  /// the returned list, if the function returns a value at all.
  Future<List<dynamic>> emit(
      [dynamic p0,
      dynamic p1,
      dynamic p2,
      dynamic p3,
      dynamic p4,
      dynamic p5,
      dynamic p6,
      dynamic p7,
      dynamic p8,
      dynamic p9]) async {
    // The list of returned values from each function
    List<dynamic> retList = <dynamic>[];
    // Iterate over each subscribed function after sorting the
    // order of groups.
    List<int> groups = _connectionMap.keys.toList();
    groups.sort();
    for (int group in groups) {
      for (Connection connection in _connectionMap[group]!) {
        // Skip if the connection is blocked
        if (connection.blocked) {
          continue;
        }
        dynamic ret;
        if (p0 == null) {
          ret = connection.function();
        } else if (p1 == null) {
          ret = connection.function(p0);
        } else if (p2 == null) {
          ret = connection.function(p0, p1);
        } else if (p3 == null) {
          ret = connection.function(p0, p1, p2);
        } else if (p4 == null) {
          ret = connection.function(p0, p1, p2, p3);
        } else if (p5 == null) {
          ret = connection.function(p0, p1, p2, p3, p4);
        } else if (p6 == null) {
          ret = connection.function(p0, p1, p2, p3, p4, p5);
        } else if (p7 == null) {
          ret = connection.function(p0, p1, p2, p3, p4, p5, p6);
        } else if (p8 == null) {
          ret = connection.function(p0, p1, p2, p3, p4, p5, p6, p7);
        } else if (p9 == null) {
          ret = connection.function(p0, p1, p2, p3, p4, p5, p6, p7, p8);
        } else {
          ret = connection.function(p0, p1, p2, p3, p4, p5, p6, p7, p8, p9);
        }
        retList.add(ret);
      }
    }
    return retList;
  }

  /// Provides a method of destructing the signal and canceling all the
  /// connections subscribed to it. This function must be called on the
  /// destruction of the signal.
  void dispose() {
    _connectionMap.forEach((key, value) {
      for (Connection connection in value) {
        connection.detach();
      }
    });
  }
}
