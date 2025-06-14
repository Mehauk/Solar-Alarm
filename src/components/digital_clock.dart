part of 'clock.dart';

class DigitalClock extends StatefulWidget {
  const DigitalClock({super.key});

  @override
  State<DigitalClock> createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  late DateTime _currentTime;
  late Timer _timer;
  Prayer? _currentPrayer;

  late final void Function(Prayers? data) _observer;

  void setCurrentPrayer(Prayer? prayer) {
    _currentPrayer = prayer;
    currentPrayerObserver.update(_currentPrayer);
  }

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _startTimer();

    setCurrentPrayer(prayerTimingsObserver.data?.prayerAtTime(_currentTime));

    _observer = (prayerTimings) {
      setState(() {
        setCurrentPrayer(prayerTimings?.prayerAtTime(_currentTime));
      });
    };
    prayerTimingsObserver.addObserver(_observer);
  }

  void _startTimer() {
    final int secondsUntilNextMinute = 60 - _currentTime.second;
    _timer = Timer(Duration(seconds: secondsUntilNextMinute), () {
      setState(() => _currentTime = DateTime.now());
      _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
        setState(() {
          _currentTime = DateTime.now();
          setCurrentPrayer(
            prayerTimingsObserver.data?.prayerAtTime(_currentTime),
          );
        });
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    prayerTimingsObserver.removeObserver(_observer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    (String time, DayPeriod period) formattedTime = _currentTime.formattedTime;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0),
          child: SText(
            formattedTime.$1,
            fontSize: 84,
            height: 0.85,
            shadow: true,
          ),
        ),

        if (_currentPrayer != null)
          Positioned(
            top: 0,
            left: 0,
            child: SizedBox(
              height: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PrayerIcon(_currentPrayer!, radius: 16),
                  const SizedBox(width: 4),
                  SText(
                    _currentPrayer!.name.capitalized,
                    fontSize: 16,
                    weight: STextWeight.bold,
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          right: 0,
          child: SText(formattedTime.$2.uname, fontSize: 16, height: 1),
        ),
      ],
    );
  }
}
