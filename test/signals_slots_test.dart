// Copyright (C) 2022 by Voidari LLC or its subsidiaries.

import 'package:flutter_test/flutter_test.dart';

import 'package:signals_slots/signals_slots.dart';

/// Tests match closely to the boost tutorial found at:
/// https://www.boost.org/doc/libs/1_61_0/doc/html/signals2/tutorial.html
void main() {
  test('Hello, World! (Beginner)', () async {
    // Signal with no arguments and a void return value
    Signal sig = Signal();

    // Connect a slot
    bool called = false;
    // ignore: prefer_function_declarations_over_variables
    Function() helloworld = () {
      called = true;
    };
    sig.connect(helloworld);

    // Call all of the slots
    await sig.emit();
    expect(called, true);
  });

  test('Connecting Multiple Slots (Beginner)', () async {
    Signal sig = Signal();

    int count = 0;
    // ignore: prefer_function_declarations_over_variables
    Function() hello = () {
      count++;
    };
    // ignore: prefer_function_declarations_over_variables
    Function() world = () {
      count++;
    };

    sig.connect(hello);
    sig.connect(world);

    await sig.emit();
    expect(count, 2);
  });

  test('Ordering Slot Call Groups (Intermediate)', () async {
    Signal sig = Signal();
    String result = "";

    sig.connect(() {
      result += "World";
    }, group: 1); // connect with group 1
    sig.connect(() {
      result += "Hello";
    }, group: 0); // connect with group 0

    await sig.emit();
    expect(result, "HelloWorld");
  });

  test('Slot Arguments (Beginner)', () async {
    Signal sig = Signal();
    int count = 0;

    sig.connect((int x, int y) {
      count += (x + y);
    });
    sig.connect((int x, int y) {
      count += (x * y);
    });
    sig.connect((int x, int y) {
      count += (x ^ y);
    });

    await sig.emit(2, 4);
    expect(count, (2 + 4) + (2 * 4) + (2 ^ 4));
  });

  test('Signal Return Values (Advanced)', () async {
    Signal sig = Signal();

    sig.connect((int x, int y) {
      return x + y;
    });
    sig.connect((int x, int y) {
      return x * y;
    });
    sig.connect((int x, int y) {
      return x ^ y;
    });

    int count = 0;
    for (var x in (await sig.emit(2, 4))) {
      count += x as int;
    }
    expect(count, (2 + 4) + (2 * 4) + (2 ^ 4));
  });

  test('Disconnecting Slots (Beginner)', () async {
    Signal sig = Signal();
    int count = 0;
    Connection connection = sig.connect(() {
      count++;
    });

    // Before disconnect
    count = 0;
    sig.emit();
    expect(count, 1);

    // After disconnect
    count = 0;
    connection.disconnect();
    sig.emit();
    expect(count, 0);
  });

  test('Blocking Slots (Beginner)', () async {
    Signal sig = Signal();
    int count = 0;
    Connection connection = sig.connect(() {
      count++;
    });

    // Before block
    count = 0;
    sig.emit();
    expect(count, 1);

    // After block
    count = 0;
    connection.blocked = true;
    sig.emit();
    expect(count, 0);

    // After unblock
    count = 0;
    connection.blocked = false;
    sig.emit();
    expect(count, 1);
  });

  test('Reconnection example', () async {
    Signal sig = Signal();
    bool isCalled = false;

    Connection connection = Connection(null, () {
      isCalled = true;
    });

    sig.reconnect(connection);
    sig.emit();
    expect(isCalled, true);
  });

  test('ConnectionGroup example', () async {
    ConnectionGroup connectionGroup = ConnectionGroup();

    Signal sig = Signal();
    int count = 0;
    connectionGroup.add(sig.connect(() {
      count++;
    }));
    connectionGroup.add(sig.connect(() {
      count++;
    }));
    connectionGroup.add(sig.connect(() {
      count++;
    }));
    sig.emit();
    expect(count, 3);

    // After disconnect
    connectionGroup.disconnectAll();
    count = 0;
    sig.emit();
    expect(count, 0);
  });
}
