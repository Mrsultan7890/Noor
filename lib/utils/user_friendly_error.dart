class UserFriendlyError {
  static String content(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('socketexception') ||
        message.contains('clientexception') ||
        message.contains('failed host lookup') ||
        message.contains('timeout')) {
      return 'Could not connect. Check your internet connection and try again.';
    }
    return 'We could not load this content. Please try again.';
  }

  static String settings(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('permission') || message.contains('denied')) {
      return 'Allow notifications in your device settings, then try again.';
    }
    return 'We could not save this setting. Please try again.';
  }

  static String audio(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('socketexception') ||
        message.contains('clientexception') ||
        message.contains('failed host lookup') ||
        message.contains('timeout')) {
      return 'Audio could not be loaded. Check your internet connection and try again.';
    }
    return 'Audio could not be played. Please try again.';
  }

  static String account(Object error, {required String action}) {
    final message = error.toString().toLowerCase();
    if (message.contains('already registered') ||
        message.contains('already exists') ||
        message.contains('email is already')) {
      return 'An account with this email already exists. Try signing in instead.';
    }
    if (message.contains('invalid credentials') ||
        message.contains('invalid email or password') ||
        message.contains('incorrect email') ||
        message.contains('incorrect password')) {
      return 'Email or password is incorrect. Check your details and try again.';
    }
    if (message.contains('invalid email')) {
      return 'Enter a valid email address.';
    }
    if (message.contains('password') && message.contains('character')) {
      return 'Choose a longer password and try again.';
    }
    if (message.contains('your session expired') ||
        message.contains('unauthorized')) {
      return 'Your session expired. Please sign in again.';
    }
    if (message.contains('socketexception') ||
        message.contains('clientexception') ||
        message.contains('failed host lookup') ||
        message.contains('timeout')) {
      return 'No internet connection. Check your connection and try again.';
    }
    return 'We could not $action. Please try again.';
  }

  static String prayerTimes(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('location services are disabled')) {
      return 'Turn on your device location services and try again.';
    }
    if (message.contains('permanently denied')) {
      return 'Allow location access for Noor in your device settings.';
    }
    if (message.contains('location permission') ||
        message.contains('permission was denied')) {
      return 'Allow location access so Noor can calculate your prayer times.';
    }
    if (message.contains('timeout')) {
      return 'Prayer times took too long to load. Check your connection and try again.';
    }
    if (message.contains('socketexception') ||
        message.contains('clientexception') ||
        message.contains('failed host lookup')) {
      return 'No internet connection. Check your connection and try again.';
    }
    return 'We could not load prayer times. Please try again.';
  }

  static String notification(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('permission') || message.contains('denied')) {
      return 'Allow notifications and alarms in your device settings to receive reminders.';
    }
    return 'Prayer times are ready, but the reminders could not be updated. Please try again.';
  }

  static String schedule(Object error, {required bool alreadySaved}) {
    final message = error.toString().toLowerCase();
    if (message.contains('permission') || message.contains('denied')) {
      return 'Allow notifications and alarms in your device settings to use schedule reminders.';
    }
    if (alreadySaved) {
      return 'Your schedule was saved, but its reminder could not be set. You can edit it and try again.';
    }
    return 'We could not save your schedule. Please try again.';
  }

  static String deleteSchedule(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('permission') || message.contains('denied')) {
      return 'Allow notifications and alarms in your device settings, then try again.';
    }
    return 'We could not delete this schedule or its reminder. Please try again.';
  }

  static String qiblaLocation(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('permanently denied')) {
      return 'Allow location access for Noor in your device settings.';
    }
    if (message.contains('permission') || message.contains('denied')) {
      return 'Allow location access to find the Qibla direction.';
    }
    if (message.contains('timeout')) {
      return 'Finding your location took too long. Please try again.';
    }
    return 'We could not find your location. Check location services and try again.';
  }
}
