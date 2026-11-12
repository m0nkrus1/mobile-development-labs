# Practice 10: The Data Arrives Later

## Level 1: order of events

Predicted:
A, C, first frame, then after 2 s: B and "6 students".

Actual:
A, C, first frame, after ~2 s: B, 6 students.

Third fetchStudents() call in a row:
Unhandled Exception: Instance of 'NoConnectionException'

With sleep(const Duration(seconds: 2)) instead of await Future.delayed: the first frame is drawn only after 2 s, the event loop is blocked.

## Level 2

Without both `if (!mounted) return;` guards, Back within 2 s:
setState() called after dispose(): _StudentsScreenState#a1b2c(lifecycle state: defunct, not mounted)

## Level 4

Version B without cancel(): Back at 7, one second later setState() called after dispose(), the console keeps printing tick 6 ... tick 0 with nobody on screen.
Version B with cancel(): the console stops at tick 7.
Version A: no cancel anywhere in my code, Back at 7, the console stops. StreamBuilder cancels the subscription itself.

## Level 5

Un-awaited save: the second tap pops the screen as if it worked, and the console prints
Unhandled Exception: Bad state: server rejected 6
The user saw a success.

Awaited save with try / on StateError: pop only on success, SnackBar "server rejected 6" on failure.