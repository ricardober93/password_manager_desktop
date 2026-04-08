import 'dart:io';

class AppDataDirectory {
  const AppDataDirectory._();

  static Directory resolve({String appName = 'password_manager_desktop'}) {
    final String basePath;
    if (Platform.isWindows) {
      basePath =
          Platform.environment['APPDATA'] ??
          Platform.environment['LOCALAPPDATA'] ??
          Directory.current.path;
    } else if (Platform.isMacOS) {
      final String home =
          Platform.environment['HOME'] ?? Directory.current.path;
      basePath = '$home/Library/Application Support';
    } else if (Platform.isLinux) {
      final String home =
          Platform.environment['HOME'] ?? Directory.current.path;
      basePath = Platform.environment['XDG_DATA_HOME'] ?? '$home/.local/share';
    } else {
      basePath = Directory.current.path;
    }

    return Directory('$basePath${Platform.pathSeparator}$appName');
  }
}
