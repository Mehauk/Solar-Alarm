import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_alarm/presentation/components/prayer_icons.dart';
import 'package:solar_alarm/presentation/core/text.dart';
import 'package:solar_alarm/presentation/modules/home/digital_clock/digital_clock_bloc.dart';
import 'package:solar_alarm/utils/extensions.dart';

class ClockDigital extends StatelessWidget {
  const ClockDigital({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DigitalClockBloc, TimerState>(
      builder: (context, state) {
        (String time, DayPeriod period) formattedTime =
            state.currentTime.formattedTime;
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

            Positioned(
              top: 0,
              left: 0,
              child: SizedBox(
                height: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (state.currentPrayer != null) ...[
                      PrayerIcon(state.currentPrayer!, radius: 16),
                      const SizedBox(width: 4),
                      SText(
                        state.currentPrayer!.name.capitalized,
                        fontSize: 16,
                        weight: STextWeight.bold,
                      ),
                      const SizedBox(width: 4),
                      SText("\u0387", fontSize: 16, weight: STextWeight.bold),
                      const SizedBox(width: 4),
                    ],
                    SText(
                      state.currentTime.formattedDate,
                      fontSize: 16,
                      weight: STextWeight.thin,
                    ),
                    const SizedBox(width: 4),
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
      },
    );
  }
}
