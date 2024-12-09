// Copyright (C) 2022 by Voidari LLC or its subsidiaries.
library signals_slots;

import 'package:signals_slots/src/connection.dart';

/// Internal use only. Use the typed signals classes only.
class Signal {
  /// The list of functions registered to the signal
  final Map<int, List<Connection>> _connectionMap = <int, List<Connection>>{};

  /// The blocked status of the signal. Signals that are blocked will
  /// return an empty list.
  bool blocked = false;

  /// Provides the means to connect a slot [function] to a signal.
  /// Signals emitted will execute each [group] in acending order
  /// with the default of 0. The [insertAtIndex] can be used to specify
  /// where in the group the function should be added. If left null, it
  /// will insert at the end of the group. A [Connection] is returned to
  /// track the connection and disconnect the slot.
  Connection _connect(Function function,
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

  /// An emit helper that will setup the groups in the correct
  /// order for iteration, or an empty group list if the signal
  /// is blocked.
  List<int> _createEmitGroup() {
    // Determine if the signal has been blocked.
    if (blocked) {
      return <int>[];
    }
    // Iterate over each subscribed function after sorting the
    // order of groups.
    List<int> groups = _connectionMap.keys.toList();
    groups.sort();
    return groups;
  }

  /// Disconnects a subscribed function from the signal.
  void disconnect(Connection connection) {
    _connectionMap.forEach((key, value) {
      _connectionMap[key]!.remove(connection);
    });
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

/// A signal is created and subscribed to by external sources,
/// which will receive the emitted signal when sent.
class Signal0 extends Signal {
  /// Provides the means to connect a slot [function] to a signal.
  /// Signals emitted will execute each [group] in acending order
  /// with the default of 0. The [insertAtIndex] can be used to specify
  /// where in the group the function should be added. If left null, it
  /// will insert at the end of the group. A [Connection] is returned to
  /// track the connection and disconnect the slot.
  Connection connect(Function() function,
      {final int group = 0, int? insertAtIndex}) {
    return _connect(function, group: group, insertAtIndex: insertAtIndex);
  }

  /// Used by the signal manager to send a signal to all subscribed connections.
  /// The optional result of all returned values will be included in
  /// the returned list, if the function returns a value at all.
  Future<List<dynamic>> emit() async {
    // The list of returned values from each function
    List<dynamic> retList = <dynamic>[];
    // Iterate over each subscribed function.
    for (int group in _createEmitGroup()) {
      List<Connection>? connections = _connectionMap[group];
      if (connections == null) continue;
      for (Connection connection in List.from(connections)) {
        // Skip if the connection is blocked
        if (connection.blocked) {
          continue;
        }
        retList.add(connection.function());
      }
    }
    return retList;
  }
}

/// A signal is created and subscribed to by external sources,
/// which will receive the emitted signal when sent.
class Signal1<T0> extends Signal {
  /// Provides the means to connect a slot [function] to a signal.
  /// Signals emitted will execute each [group] in acending order
  /// with the default of 0. The [insertAtIndex] can be used to specify
  /// where in the group the function should be added. If left null, it
  /// will insert at the end of the group. A [Connection] is returned to
  /// track the connection and disconnect the slot.
  Connection connect(Function(T0) function,
      {final int group = 0, int? insertAtIndex}) {
    return _connect(function, group: group, insertAtIndex: insertAtIndex);
  }

  /// Used by the signal manager to send a signal to all subscribed connections.
  /// The optional result of all returned values will be included in
  /// the returned list, if the function returns a value at all.
  Future<List<dynamic>> emit(T0 p0) async {
    // The list of returned values from each function
    List<dynamic> retList = <dynamic>[];
    // Iterate over each subscribed function.
    for (int group in _createEmitGroup()) {
      List<Connection>? connections = _connectionMap[group];
      if (connections == null) continue;
      for (Connection connection in List.from(connections)) {
        // Skip if the connection is blocked
        if (connection.blocked) {
          continue;
        }
        retList.add(connection.function(p0));
      }
    }
    return retList;
  }
}

/// A signal is created and subscribed to by external sources,
/// which will receive the emitted signal when sent.
class Signal2<T0, T1> extends Signal {
  /// Provides the means to connect a slot [function] to a signal.
  /// Signals emitted will execute each [group] in acending order
  /// with the default of 0. The [insertAtIndex] can be used to specify
  /// where in the group the function should be added. If left null, it
  /// will insert at the end of the group. A [Connection] is returned to
  /// track the connection and disconnect the slot.
  Connection connect(Function(T0, T1) function,
      {final int group = 0, int? insertAtIndex}) {
    return _connect(function, group: group, insertAtIndex: insertAtIndex);
  }

  /// Used by the signal manager to send a signal to all subscribed connections.
  /// The optional result of all returned values will be included in
  /// the returned list, if the function returns a value at all.
  Future<List<dynamic>> emit(T0 p0, T1 p1) async {
    // The list of returned values from each function
    List<dynamic> retList = <dynamic>[];
    // Iterate over each subscribed function.
    for (int group in _createEmitGroup()) {
      List<Connection>? connections = _connectionMap[group];
      if (connections == null) continue;
      for (Connection connection in List.from(connections)) {
        // Skip if the connection is blocked
        if (connection.blocked) {
          continue;
        }
        retList.add(connection.function(p0, p1));
      }
    }
    return retList;
  }
}

/// A signal is created and subscribed to by external sources,
/// which will receive the emitted signal when sent.
class Signal3<T0, T1, T2> extends Signal {
  /// Provides the means to connect a slot [function] to a signal.
  /// Signals emitted will execute each [group] in acending order
  /// with the default of 0. The [insertAtIndex] can be used to specify
  /// where in the group the function should be added. If left null, it
  /// will insert at the end of the group. A [Connection] is returned to
  /// track the connection and disconnect the slot.
  Connection connect(Function(T0, T1, T2) function,
      {final int group = 0, int? insertAtIndex}) {
    return _connect(function, group: group, insertAtIndex: insertAtIndex);
  }

  /// Used by the signal manager to send a signal to all subscribed connections.
  /// The optional result of all returned values will be included in
  /// the returned list, if the function returns a value at all.
  Future<List<dynamic>> emit(T0 p0, T1 p1, T2 p2) async {
    // The list of returned values from each function
    List<dynamic> retList = <dynamic>[];
    // Iterate over each subscribed function.
    for (int group in _createEmitGroup()) {
      List<Connection>? connections = _connectionMap[group];
      if (connections == null) continue;
      for (Connection connection in List.from(connections)) {
        // Skip if the connection is blocked
        if (connection.blocked) {
          continue;
        }
        retList.add(connection.function(p0, p1, p2));
      }
    }
    return retList;
  }
}

/// A signal is created and subscribed to by external sources,
/// which will receive the emitted signal when sent.
class Signal4<T0, T1, T2, T3> extends Signal {
  /// Provides the means to connect a slot [function] to a signal.
  /// Signals emitted will execute each [group] in acending order
  /// with the default of 0. The [insertAtIndex] can be used to specify
  /// where in the group the function should be added. If left null, it
  /// will insert at the end of the group. A [Connection] is returned to
  /// track the connection and disconnect the slot.
  Connection connect(Function(T0, T1, T2, T3) function,
      {final int group = 0, int? insertAtIndex}) {
    return _connect(function, group: group, insertAtIndex: insertAtIndex);
  }

  /// Used by the signal manager to send a signal to all subscribed connections.
  /// The optional result of all returned values will be included in
  /// the returned list, if the function returns a value at all.
  Future<List<dynamic>> emit(T0 p0, T1 p1, T2 p2, T3 p3) async {
    // The list of returned values from each function
    List<dynamic> retList = <dynamic>[];
    // Iterate over each subscribed function.
    for (int group in _createEmitGroup()) {
      List<Connection>? connections = _connectionMap[group];
      if (connections == null) continue;
      for (Connection connection in List.from(connections)) {
        // Skip if the connection is blocked
        if (connection.blocked) {
          continue;
        }
        retList.add(connection.function(p0, p1, p2, p3));
      }
    }
    return retList;
  }
}

/// A signal is created and subscribed to by external sources,
/// which will receive the emitted signal when sent.
class Signal5<T0, T1, T2, T3, T4> extends Signal {
  /// Provides the means to connect a slot [function] to a signal.
  /// Signals emitted will execute each [group] in acending order
  /// with the default of 0. The [insertAtIndex] can be used to specify
  /// where in the group the function should be added. If left null, it
  /// will insert at the end of the group. A [Connection] is returned to
  /// track the connection and disconnect the slot.
  Connection connect(Function(T0, T1, T2, T3, T4) function,
      {final int group = 0, int? insertAtIndex}) {
    return _connect(function, group: group, insertAtIndex: insertAtIndex);
  }

  /// Used by the signal manager to send a signal to all subscribed connections.
  /// The optional result of all returned values will be included in
  /// the returned list, if the function returns a value at all.
  Future<List<dynamic>> emit(T0 p0, T1 p1, T2 p2, T3 p3, T4 p4) async {
    // The list of returned values from each function
    List<dynamic> retList = <dynamic>[];
    // Iterate over each subscribed function.
    for (int group in _createEmitGroup()) {
      List<Connection>? connections = _connectionMap[group];
      if (connections == null) continue;
      for (Connection connection in List.from(connections)) {
        // Skip if the connection is blocked
        if (connection.blocked) {
          continue;
        }
        retList.add(connection.function(p0, p1, p2, p3, p4));
      }
    }
    return retList;
  }
}

/// A signal is created and subscribed to by external sources,
/// which will receive the emitted signal when sent.
class Signal6<T0, T1, T2, T3, T4, T5> extends Signal {
  /// Provides the means to connect a slot [function] to a signal.
  /// Signals emitted will execute each [group] in acending order
  /// with the default of 0. The [insertAtIndex] can be used to specify
  /// where in the group the function should be added. If left null, it
  /// will insert at the end of the group. A [Connection] is returned to
  /// track the connection and disconnect the slot.
  Connection connect(Function(T0, T1, T2, T3, T4, T5) function,
      {final int group = 0, int? insertAtIndex}) {
    return _connect(function, group: group, insertAtIndex: insertAtIndex);
  }

  /// Used by the signal manager to send a signal to all subscribed connections.
  /// The optional result of all returned values will be included in
  /// the returned list, if the function returns a value at all.
  Future<List<dynamic>> emit(T0 p0, T1 p1, T2 p2, T3 p3, T4 p4, T5 p5) async {
    // The list of returned values from each function
    List<dynamic> retList = <dynamic>[];
    // Iterate over each subscribed function.
    for (int group in _createEmitGroup()) {
      List<Connection>? connections = _connectionMap[group];
      if (connections == null) continue;
      for (Connection connection in List.from(connections)) {
        // Skip if the connection is blocked
        if (connection.blocked) {
          continue;
        }
        retList.add(connection.function(p0, p1, p2, p3, p4, p5));
      }
    }
    return retList;
  }
}

/// A signal is created and subscribed to by external sources,
/// which will receive the emitted signal when sent.
class Signal7<T0, T1, T2, T3, T4, T5, T6> extends Signal {
  /// Provides the means to connect a slot [function] to a signal.
  /// Signals emitted will execute each [group] in acending order
  /// with the default of 0. The [insertAtIndex] can be used to specify
  /// where in the group the function should be added. If left null, it
  /// will insert at the end of the group. A [Connection] is returned to
  /// track the connection and disconnect the slot.
  Connection connect(Function(T0, T1, T2, T3, T4, T5, T6) function,
      {final int group = 0, int? insertAtIndex}) {
    return _connect(function, group: group, insertAtIndex: insertAtIndex);
  }

  /// Used by the signal manager to send a signal to all subscribed connections.
  /// The optional result of all returned values will be included in
  /// the returned list, if the function returns a value at all.
  Future<List<dynamic>> emit(
      T0 p0, T1 p1, T2 p2, T3 p3, T4 p4, T5 p5, T6 p6) async {
    // The list of returned values from each function
    List<dynamic> retList = <dynamic>[];
    // Iterate over each subscribed function.
    for (int group in _createEmitGroup()) {
      List<Connection>? connections = _connectionMap[group];
      if (connections == null) continue;
      for (Connection connection in List.from(connections)) {
        // Skip if the connection is blocked
        if (connection.blocked) {
          continue;
        }
        retList.add(connection.function(p0, p1, p2, p3, p4, p5, p6));
      }
    }
    return retList;
  }
}
