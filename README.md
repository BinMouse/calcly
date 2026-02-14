# Calcly
Simple Calculator on Flutter

Calcly supports basic operations and evaluates expressions by converting them to postfix notation (Reverse Polish Notation). The application is configured for Android and Windows, but thanks to Flutter it can be ported to other platforms at any time.

However, there are some bugs that can be corrected later, namely:
1. The calculator doesn't recognize the difference between the entries "√a" and "a√".
2. There's no support for implicit multiplication. I decided not to complicate the algorithm with additional checks and loops, although this will undoubtedly be necessary to expand the functionality.

There are unit tests to check the application's operation.
The app still needs some work, so I invite everyone to participate. The main thing is to keep it simple enough to serve as an example for newbies like me.