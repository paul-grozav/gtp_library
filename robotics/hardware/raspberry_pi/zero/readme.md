# Thermal throttle
- [30, 50) - Optimal - Maximum lifespan. Ideal for "set it and forget it"
  servers.
- [50, 70) - Normal operating range for medium-to-high load. No risk to hardware
- [79, 80) - Safe, but heat starts to soak into the microSD card, which can lead
  to earlier disk corruption.
- [60, 80) - WARNING - At 60°C: A yellow thermomether icon appears that signals
  the fact that it is getting warm. OS might step in to reduce CPU usage, but
  you should not notice and performance degradation.
- [80, 85) - CRITICAL - At 80°C: A red thermomether icon appears. The Pi OS will
  start to reduce the CPU clock frequency (e.g., from 1.0 GHz down to 700 MHz or
  lower).
- [85, 110) - CRITICAL - At 85°C: The Pi OS will reduce the CPU even more
  aggressively to cool it down and prevent hardware/silicon damage.
- [110, inf) - EMERGENCY - At ~110°C the Pi OS triggers OS Shutdown. If the
  temperature continues to rise despite the throttling (which is very rare
  unless it's in a literal fire or a completely sealed box with no air), the SoC
  will perform a hard emergency shutdown to prevent permanent silicon damage.

Keeping it in the optimal zone, should give you 5-10 years of running without
major hardware damage. However you can also have daily intensive activities of
2 - 5 hours, when you keep the CPU at 75°C and that will still keep the hardware
safe for 5+ years.

# Audio config
Create a `/home/pi/.asoundrc` file containing:
```txt
defaults.pcm.!card 1
defaults.ctl.!card 1
```
This should get your USB headsets working.
