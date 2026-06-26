import 'dart:async';
import 'package:flutter/material.dart';

enum TimerState { idle, running, paused, finished }

class TimerProvider extends ChangeNotifier {
  static const int _workDuration = 25 * 60; // 25 minutos en segundos
  static const int _breakDuration = 5 * 60; //  5 minutos en segundos

  int _secondsLeft = _workDuration;
  TimerState _state = TimerState.idle;
  bool _isBreak = false;
  int _sessionsCompleted = 0;
  Timer? _timer;

  // ── Getters ────────────────────────────────────────────────────────────────
  int get secondsLeft => _secondsLeft;
  TimerState get state => _state;
  bool get isBreak => _isBreak;
  int get sessionsCompleted => _sessionsCompleted;

  int get totalDuration => _isBreak ? _breakDuration : _workDuration;
  double get progress => 1 - (_secondsLeft / totalDuration);

  String get timeLabel {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get statusLabel {
    switch (_state) {
      case TimerState.idle:
        return _isBreak ? '[ DESCANSO ]' : '[ LISTO ]';
      case TimerState.running:
        return _isBreak ? '[ DESCANSO ]' : '[ ENFOCADO ]';
      case TimerState.paused:
        return '[ PAUSADO ]';
      case TimerState.finished:
        return _isBreak ? '[ DESCANSO LISTO ]' : '[ SESIÓN COMPLETA ]';
    }
  }

  // ── Controles ──────────────────────────────────────────────────────────────
  void start() {
    if (_state == TimerState.finished) return;
    _state = TimerState.running;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) {
        _secondsLeft--;
        notifyListeners();
      } else {
        _timer?.cancel();
        _state = TimerState.finished;
        if (!_isBreak) _sessionsCompleted++;
        notifyListeners();
      }
    });
  }

  void pause() {
    _timer?.cancel();
    _state = TimerState.paused;
    notifyListeners();
  }

  void resume() => start();

  void reset() {
    _timer?.cancel();
    _secondsLeft = _isBreak ? _breakDuration : _workDuration;
    _state = TimerState.idle;
    notifyListeners();
  }

  void switchMode() {
    _timer?.cancel();
    _isBreak = !_isBreak;
    _secondsLeft = _isBreak ? _breakDuration : _workDuration;
    _state = TimerState.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
