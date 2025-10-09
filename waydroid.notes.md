# adb
some apps block taps. Compatibility settings can be configured to change this:
- BLOCK_UNTRUSTED_TOUCHES
- ... others
I haven't found all I'd need to disable, but disabling BLOCK_UNTRUSTED_TOUCHES makes the
taps show up, atleast, but they don't register on the UI

However, `adb shell input swipe` can be used as a tap by:
1. Using same or very close coordinates for both startX/Y and endX/Y
2. Using a fast swipe speed, 100ms works. 0ms or 1ms don't register. Probably needs to be at least one frame or something.

So, instead of e.g. `adb shell input tap 100 200`,
use `adb shell input swipe 100 200 100 200 100`...
