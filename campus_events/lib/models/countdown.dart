/// R9: the three states of the countdown. Sealed, so a `switch` over it
/// must handle every case.
sealed class Countdown {
  const Countdown();
}

/// The event has not started yet; [left] is the time until the start.
final class Upcoming extends Countdown {
  const Upcoming(this.left);

  final Duration left;
}

/// The event started [since] ago and is still running.
final class Started extends Countdown {
  const Started(this.since);

  final Duration since;
}

/// The event is over.
final class Ended extends Countdown {
  const Ended();
}
