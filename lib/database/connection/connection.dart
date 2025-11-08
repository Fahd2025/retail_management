// This file provides the appropriate database connection based on the platform
export 'unsupported.dart'
    if (dart.library.io) 'native.dart'
    if (dart.library.html) 'web.dart';
