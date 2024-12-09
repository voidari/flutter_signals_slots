# 1.1.1
* Fixes issue disconnecting during the emitting of a signal.

## 1.1.0
* Add type support to the signal class. Usage of Signal now requires the declaration of types (ex. Signal2<int, float>()) to avoid a mismatch of parameters and connection functions.

## 1.0.1
* Add ability to block a signal

## 1.0.0

* Initial release of signals and slots.
* Provides a means of creating signals, subscribing to them, and managing connections.
* Adds test cases to validate functionality.