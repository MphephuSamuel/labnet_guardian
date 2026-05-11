class TimeUtils {
  static String timeAgo(String isoTime) {
    try {
      final dt = DateTime.parse(isoTime).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) {
        final m = diff.inMinutes;
        return '$m ${m == 1 ? 'minute' : 'minutes'} ago';
      }
      if (diff.inHours < 24) {
        final h = diff.inHours;
        return '$h ${h == 1 ? 'hour' : 'hours'} ago';
      }
      final d = diff.inDays;
      return '$d ${d == 1 ? 'day' : 'days'} ago';
    } catch (_) {
      return isoTime;
    }
  }
}
