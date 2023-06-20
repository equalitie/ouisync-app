import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/constants.dart';
import '../utils/fields.dart';
import '../cubits/cubits.dart';

typedef _Creator = Widget Function(bool showError, bool showWarning);

class NotificationBadgeBuilder {
  StateMonitorIntCubit _panicCounter;
  PowerControl _powerControl;

  bool _withErrorIfUpdateExists = false;
  bool _withErrorOnLibraryPanic = false;
  bool _withWarningIfNetworkDisabled = false;

  StateMonitorIntCubit get panicCounter => _panicCounter;

  NotificationBadgeBuilder(
    this._panicCounter,
    this._powerControl, {
    bool withErrorIfUpdateExists = true,
    bool withErrorOnLibraryPanic = true,
    bool withWarningIfNetworkDisabled = true,
  })  : _withErrorIfUpdateExists = withErrorIfUpdateExists,
        _withErrorOnLibraryPanic = withErrorOnLibraryPanic,
        _withWarningIfNetworkDisabled = withWarningIfNetworkDisabled;

  NotificationBadgeBuilder copyWith({
    required bool withErrorIfUpdateExists,
    required bool withErrorOnLibraryPanic,
    required bool withWarningIfNetworkDisabled,
  }) {
    return NotificationBadgeBuilder(
      _panicCounter,
      _powerControl,
      withErrorIfUpdateExists: withErrorIfUpdateExists,
      withErrorOnLibraryPanic: withErrorOnLibraryPanic,
      withWarningIfNetworkDisabled: withWarningIfNetworkDisabled,
    );
  }

  Widget build(Widget widget) {
    return _addErrorIfUpdateExists(_addErrorOnLibraryPanic(
        _addWarningIfNetworkDisabled(
            (e, w) => _finalWidget(widget, e, w))))(false, false);
  }

  _Creator _addErrorIfUpdateExists(_Creator creator) {
    if (!_withErrorIfUpdateExists) {
      return creator;
    }

    return (bool showError, bool showWarning) {
      return BlocBuilder<UpgradeExistsCubit, bool>(
          builder: (context, updateExists) =>
              creator(showError || updateExists, showWarning));
    };
  }

  _Creator _addErrorOnLibraryPanic(_Creator creator) {
    if (!_withErrorOnLibraryPanic) {
      return creator;
    }

    return (bool showError, bool showWarning) {
      return BlocBuilder<StateMonitorIntCubit, int?>(
          bloc: _panicCounter,
          builder: (context, panicCount) =>
              creator(showError || ((panicCount ?? 0) > 0), showWarning));
    };
  }

  _Creator _addWarningIfNetworkDisabled(_Creator creator) {
    if (!_withWarningIfNetworkDisabled) {
      return creator;
    }

    return (bool showError, bool showWarning) {
      return BlocBuilder<PowerControl, PowerControlState>(
          bloc: _powerControl,
          builder: (context, powerControlState) {
            final isNetworkEnabled = powerControlState.isNetworkEnabled ?? true;
            return creator(showError, showWarning || !isNetworkEnabled);
          });
    };
  }

  Widget _finalWidget(Widget widget, bool showError, bool showWarning) {
    Color? color;

    if (showError) {
      color = Constants.errorColor;
    } else if (showWarning) {
      color = Constants.warningColor;
    }

    if (color != null) {
      return Fields.addBadge(widget, color: color);
    } else {
      return widget;
    }
  }
}
