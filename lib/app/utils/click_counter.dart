
// A simple class to help counting how many times the user clicked on a button
// with some maximal duration between each two clicks.
class ClickCounter {
    // A timestamp (ms since epoch) when was the last time the user hit the
    // back button from the directory root. If the user hits it twice within
    // exitBackButtonTimeoutMs duration, then the app will exit.
    int _lastClickTime = 0;
    int _clickCount = 0;
    final int _timeoutMs;

    ClickCounter({required int timeoutMs}) : _timeoutMs = timeoutMs;

    int registerClick() {
      int now = DateTime.now().millisecondsSinceEpoch;

      if (now - _lastClickTime <= _timeoutMs) {
        _clickCount += 1;
      } else {
        _clickCount = 1;
      }

      _lastClickTime = now;

      return _clickCount;
    }

    void reset() {
      _lastClickTime = 0;
      _clickCount = 0;
    }
}
