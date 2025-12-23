import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solar_alarm/presentation/pages/home/prayer_timings/prayer_timings_bloc.dart';
import 'package:solar_alarm/utils/interfaces.dart';

import '../../../../data/models/prayers.dart';
import '../../../../utils/extensions.dart';
import '../../../components/prayer_icons.dart';
import '../../../core/icon.dart';
import '../../../core/switch.dart';
import '../../../core/text.dart';

class PrayerTimingsWidget extends StatelessWidget {
  const PrayerTimingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PrayerTimingsBloc, PrayerTimingsState>(
      listenWhen: (previous, current) => current is WithErrorMessage,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${(state as WithErrorMessage).message}'),
          ),
        );
      },
      buildWhen: (previous, current) => current is UiState,
      builder: (context, state) {
        switch (state as UiState) {
          case PrayerTimingsLoadInProgress():
            return const Center(child: CircularProgressIndicator());
          case PrayerTimingsLoadSuccess(prayers: var prayers) ||
              PrayerUpdateSuccess(prayers: var prayers):
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < prayers.ordered.length; i++)
                  _PrayerTiming(
                    Prayers.orderedPrayers[i],
                    prayers.ordered[i],
                    prayers.prayerAtTime(DateTime.now()),
                    prayers.statuses[Prayers.orderedPrayers[i]],
                    (s) => context.read<PrayerTimingsBloc>().add(
                      PrayerUpdateEvent(Prayers.orderedPrayers[i], s),
                    ),
                  ),
              ],
            );
          case PrayerTimingsLoadFailure():
            return Center(
              child: IconButton(
                onPressed: () {
                  context.read<PrayerTimingsBloc>().add(
                    const PrayersLoadEvent(),
                  );
                },
                icon: const Icon(Icons.refresh),
              ),
            );
        }

        throw UnimplementedError();
      },
    );
  }
}

class _PrayerTiming extends StatelessWidget {
  final Prayer prayer;
  final Prayer? currentPrayer;
  final DateTime time;
  final PrayerAlarmStatus? status;
  final void Function(PrayerAlarmStatus s)? onUpdateStatus;

  const _PrayerTiming(
    this.prayer,
    this.time,
    this.currentPrayer,
    this.status,
    this.onUpdateStatus,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SText(
            "I",
            fontSize: 24,
            color:
                currentPrayer == prayer
                    ? const Color(0xFF8E98A1)
                    : Colors.transparent,
            glow: true,
          ),
          Expanded(
            child: Row(
              children: [
                PrayerIcon(prayer, weight: PrayerIconWeight.thin, radius: 12),
                const SizedBox(width: 8),
                SText(prayer.name.capitalized, fontSize: 16),
              ],
            ),
          ),

          SText(
            "${time.formattedTime.$1} ${time.formattedTime.$2.uname}",
            fontSize: 16,
          ),

          const SizedBox(width: 4),
          SizedBox(
            width: 52,
            child:
                status != null
                    ? InkWell(
                      onTap:
                          status != null
                              ? () => onUpdateStatus!(status!.toggle)
                              : null,
                      child: SizedBox(
                        height: 28,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SSwitch(
                              status!,
                              onChanged: onUpdateStatus ?? (_) {},
                              trackSize: const Size(27, 7),
                              toggleSize: const Size(14, 14),
                            ),
                            const SizedBox(width: 4),
                            if (status!.icon != null)
                              SIcon(status!.icon!, radius: 7),
                          ],
                        ),
                      ),
                    )
                    : null,
          ),
        ],
      ),
    );
  }
}

extension on PrayerAlarmStatus {
  IconData? get icon => switch (this) {
    PrayerAlarmStatus.disabled => null,
    PrayerAlarmStatus.vibrate => Icons.vibration,
    PrayerAlarmStatus.sound => Icons.volume_up,
  };
}
