// Copyright (C) 2022 by Voidari LLC or its subsidiaries.
library signals_slots;

import 'package:signals_slots/src/signal.dart';

/// Connections are references for slots that subscribe to signals.
/// A signal will provide a connection when a function is subscribed.
/// The connection can be used to disconnect from signals and unsubscribe
/// from the signal.
class Connection {
  /// The signal that the connection was created with.
  Signal? signal;

  /// The function that is subscribed to the connected signal.
  final Function function;

  /// The blocked status of the connection
  bool blocked = false;

  /// The constructor for the connection. The signature of the function
  /// should match the signature defined by the signal. The connection
  /// is created by the signal, and should not be created outside the library.
  Connection(this.signal, this.function);

  /// Disconnects the signal from the slot. Must be called when the
  /// connection is deconstructed.
  void disconnect() {
    if (signal != null) {
      signal?.disconnect(this);
      signal = null;
    }
  }

  /// Determines if the slot is connected.
  bool isConnected() {
    if (signal != null) {
      return signal!.isConnected(this);
    }
    return false;
  }

  /// Used by the signal to break the connection. For internal use only.
  void detach() {
    signal = null;
  }
}
