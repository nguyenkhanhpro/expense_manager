import 'dart:io';

/// Resolve correct backend host for IO platforms.
String resolveHost() => Platform.isAndroid ? '10.0.2.2' : 'localhost';

