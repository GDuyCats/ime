import 'package:uuid/uuid.dart';

const Uuid _uuid = Uuid();

/// A new random UUID for a database row.
String newId() => _uuid.v4();

/// The current time as Unix epoch milliseconds.
int nowMillis() => DateTime.now().millisecondsSinceEpoch;
