# Signals and Slots

[![pub package](https://img.shields.io/pub/v/signals_slots.svg)](https://pub.dev/packages/signals_slots)

[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

## Introduction

An implementation of a managed signals and slots system based on the boost signals2 C++ library. Signals represent callbacks with multiple targets, and are also called publishers or events in similar systems. Signals are connected to some set of slots, which are callback receivers (also called event targets or subscribers), which are called when the signal is "emitted."

For more information, view the [boost signals2 library documentation](https://www.boost.org/doc/libs/1_61_0/doc/html/signals2.html).

This plugin has no affiliation with boost or its contributors.

Please review the documentation for this library, as it differs in behavior for signal groups and uses indexes instead of defined 'back' and 'front' options. Dart (javascript) does not have destructors, thus no scoped implementation which limits the usability of this library. Disconnects will need to be called manually on signals and connections.

## Usage
To use this plugin, add `signals_slots` as a dependency in your pubspec.yaml file.

### Creating a signal and using emit
Signals can be created for any function signature, but should only be used with the signature it was created for. Signals can be used to create slot connections, or reconnect an existing slot connection.

```dart
Signal0 sig = Signal0();
sig.connect(() { print("Hello, "); });
sig.connect(() { print("World"); });
sig.emit();
// "Hello, World" is printed
```

### Emit a signal with parameters and optional result
Signals can be sent with parameters. Results of any type are provided in a returned list with any type for each connection that handles the signal.

```dart
Signal1<String> sig = Signal1<String>();
sig.connect((String name) { return "Hello, $name."; });
sig.connect((String name) { return "Goodbye, $name."; });
List<dynamic> result = sig.emit("John");
// result[ "Hello, John.", "Goodbye, John." ]
```

### Using connections
Connections are returned when connecting to a signal, or can be created and reconnected if getting a return value isn't possible. Connections are used to track the slot.

```dart
Signal0 sig = Signal0();
Connection connection = sig.connect(() {});
// Check the connection status
connection.isConnected();
// Used to temporary block signals to a connection
connection.blocked = true;

connection = Connection(null, () {});
sig.reconnect(connection);
```

### Disconnecting and disposing
Connections are likely made on pages or other temporary entities. When the page is destroyed, or whenever a connection loses scope, the connection must be disconnected. Signals are the same, except dispose should be called.

ConnectionGroup contains a list of connections for easier tracking a disconnections if a large number of connections need to be tracked.

If a connection is disconnected, it will no longer receive emitted signals.

```dart
Connection connection ...;
connection.disconnect();

ConnectionGroup connectionGroup ...;
connectionGroup.add(connection1);
connectionGroup.add(connection2);
connectionGroup.disconnectAll();
```

### Groups and indexing
Signals are sent out to slots in the order they were connected, unless priority is included in the original connection. Groups and indexing is used to accomplish this. Groups can be thought of as priority and indexing is used to insert within a specific group.

If no group is provided, group 0 will be used as the default.
If no index is provided, the connection will be inserted at the back of the group.

Indexes will never be out of bounds. If a negative index is provided, it will be inserted at the start of the group. If the index is greater than the group size, it will be inserted at the back of the group.

```dart
// Example without groups and indexes
String text = "";
Signal0 sig = Signal0();
sig.connect((){ text += "func1 "; });
sig.connect((){ text += "func2 "; });
sig.connect((){ text += "func3 "; });
sig.emit();
print(text); // func1 func2 func3
```

```dart
// Example with groups and indexes
String text = "";
Signal0 sig = Signal0();
sig.connect((){ text += "func1"; }, group: 1);
sig.connect((){ text += "func2"; });
sig.connect((){ text += "func3"; }, group: 1, insertAtIndex: 0);
sig.emit();
print(text); // func2 func3 func1
```

### Blocking signals and connection
Signals and connections can be blocked using the 'blocked' member variable. Signals are blocked to prevent them from emitting when emit is called. Connections can be blocked to prevent signals from executing the slot they are subscribed with.

```dart
Signal0 sig = Signal0();
Connection connection0 = sig.connect((){ print("slot 0"); });
Connection connection1 = sig.connect((){ print("slot 1"); });
sig.emit(); // 'slot 0' and 'slot 1' are printed

// Blocked signal example
sig.blocked = true;
sig.emit(); // Nothing is printed
sig.blocked = false;

// Blocked connection example
connection0.blocked = true;
sig.emit(); // Only 'slot 1' is printed
```

## Appreciation and Proposals

When we work on a project, any internal library we create that could benefit the community will be made public for free use. Please consider contributing, as work does go into creating and maintaining this library. As always, if something could be improved, please create an issue for it in the project repo and we'll be happy to discuss!

[<img src="img/buymecoffee.png" width="175"/>](https://www.buymeacoffee.com/voidari)

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/voidari/flutter_signals_slots.svg?style=for-the-badge
[contributors-url]: https://github.com/voidari/flutter_signals_slots/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/voidari/flutter_signals_slots.svg?style=for-the-badge
[forks-url]: https://github.com/voidari/flutter_signals_slots/network/members
[stars-shield]: https://img.shields.io/github/stars/voidari/flutter_signals_slots.svg?style=for-the-badge
[stars-url]: https://github.com/voidari/flutter_signals_slots/stargazers
[issues-shield]: https://img.shields.io/github/issues/voidari/flutter_signals_slots.svg?style=for-the-badge
[issues-url]: https://github.com/voidari/flutter_signals_slots/issues
[license-shield]: https://img.shields.io/github/license/voidari/flutter_signals_slots.svg?style=for-the-badge
[license-url]: https://github.com/voidari/flutter_signals_slots/blob/main/LICENSE