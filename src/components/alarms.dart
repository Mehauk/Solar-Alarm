import 'package:flutter/material.dart';

import '../ui/icon.dart';
import '../ui/switch.dart';
import '../ui/text.dart';

class AlarmsWidget extends StatelessWidget {
  const AlarmsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return _Background(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 36),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SText("Alarms", fontSize: 18),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SIconButton(Icons.add, onTap: () => print(1)),
                    const SizedBox(width: 4),
                    SIconButton(Icons.more_horiz, onTap: () => print(1)),
                  ],
                ),
              ],
            ),
          ),
          const Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(children: [AlarmTile()]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AlarmTile extends StatefulWidget {
  const AlarmTile({super.key});

  @override
  State<AlarmTile> createState() => _AlarmTileState();
}

class _AlarmTileState extends State<AlarmTile> {
  bool enabled = true;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5D666D), Color(0xFF363E46)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3F4850), Color(0xFF363E46)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SText("07:30", fontSize: 34),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SText(
                        "M T W T F S S",
                        fontSize: 12,
                        weight: STextWeight.thin,
                      ),
                      const SizedBox(width: 12),
                      SSwitch(
                        enabled,
                        onChanged: (v) => setState(() => enabled = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Background extends StatelessWidget {
  final Widget child;
  const _Background({required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5D666D), Color(0x0023282D)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 1.5),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF363E46), Color(0xFF2C343C)],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
