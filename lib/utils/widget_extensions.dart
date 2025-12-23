import 'package:flutter/material.dart';
import 'package:solar_alarm/utils/interfaces.dart';

extension ErrorSnackbar on ScaffoldMessengerState {
  showErrorSnackbar(WithErrorMessage state) {
    showSnackBar(SnackBar(content: Text('Error: ${(state).message}')));
  }
}
