import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/timer_provider.dart';
import '../screens/login_screen.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _glitchCtrl;
  late Animation<double> _pulseAnim;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _glitchCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _pulseAnim = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _glitchCtrl.dispose();
    super.dispose();
  }

  void _triggerGlitch() {
    _glitchCtrl.forward(from: 0);
  }

  // ── Logout con overlay ─────────────────────────────────────────────────────
  Future<void> _logout() async {
    if (_loggingOut) return;

    // Pausa el timer si estaba corriendo
    final timer = context.read<TimerProvider>();
    if (timer.state == TimerState.running) timer.pause();

    setState(() => _loggingOut = true);

    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  // ── Paleta hacker ──────────────────────────────────────────────────────────
  static const Color _bg = Color(0xFF030D03);
  static const Color _green = Color(0xFF00FF41);
  static const Color _greenDim = Color(0xFF00C030);
  static const Color _greenMuted = Color(0xFF005515);
  static const Color _amber = Color(0xFFFFB300);
  static const Color _red = Color(0xFFFF2D2D);
  static const Color _surface = Color(0xFF0A1A0A);

  Widget build(BuildContext context) {
    final timer = context.watch<TimerProvider>();
    final Color activeColor = timer.isBreak ? _amber : _green;
    final Color dimColor = timer.isBreak
        ? _amber.withOpacity(0.25)
        : _greenMuted;

    // PopScope intercepta el botón físico Atrás del teléfono también
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _logout();
      },
      child: Stack(
        children: [
          // ── Pantalla normal del timer ──────────────────────────────────────
          Scaffold(
            backgroundColor: _bg,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.logout_rounded,
                  color: activeColor.withOpacity(0.7),
                  size: 20,
                ),
                tooltip: 'Cerrar sesión',
                onPressed: _logout,
              ),
              title: Text(
                '> FOCUS_TERMINAL',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: activeColor,
                  fontSize: 14,
                  letterSpacing: 3,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    children: List.generate(
                      4,
                      (i) => Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.circle,
                          size: 8,
                          color: i < timer.sessionsCompleted
                              ? activeColor
                              : dimColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (context, _) {
                      final scale = timer.state == TimerState.running
                          ? _pulseAnim.value
                          : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: _TimerRing(
                          progress: timer.progress,
                          timeLabel: timer.timeLabel,
                          statusLabel: timer.statusLabel,
                          activeColor: activeColor,
                          dimColor: dimColor,
                          state: timer.state,
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  _ControlRow(
                    state: timer.state,
                    activeColor: activeColor,
                    onStart: () {
                      _triggerGlitch();
                      timer.start();
                    },
                    onPause: timer.pause,
                    onResume: () {
                      _triggerGlitch();
                      timer.resume();
                    },
                    onReset: timer.reset,
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Overlay de "cerrando sesión" ───────────────────────────────────
          if (_loggingOut) const _LogoutOverlay(),
        ],
      ),
    );
  }
}

// ── Overlay widget ─────────────────────────────────────────────────────────────

class _LogoutOverlay extends StatefulWidget {
  const _LogoutOverlay();

  @override
  State<_LogoutOverlay> createState() => _LogoutOverlayState();
}

class _LogoutOverlayState extends State<_LogoutOverlay> {
  int _dots = 0;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 350));
      if (mounted) setState(() => _dots = (_dots + 1) % 4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 40,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF030D03),
            border: Border.all(
              color: const Color(0xFF00FF41).withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FF41).withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            '> cerrando sesión${'.' * _dots}',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              letterSpacing: 2,
              color: Color(0xFF00FF41),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Timer Ring ─────────────────────────────────────────────────────────────────

class _TimerRing extends StatelessWidget {
  const _TimerRing({
    required this.progress,
    required this.timeLabel,
    required this.statusLabel,
    required this.activeColor,
    required this.dimColor,
    required this.state,
  });
  final double progress;
  final String timeLabel;
  final String statusLabel;
  final Color activeColor;
  final Color dimColor;
  final TimerState state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Anillo de progreso
          CustomPaint(
            size: const Size(260, 260),
            painter: _RingPainter(
              progress: progress,
              activeColor: activeColor,
              bgColor: dimColor,
            ),
          ),

          // Centro
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tiempo
              Text(
                timeLabel,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: activeColor,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(color: activeColor.withOpacity(0.8), blurRadius: 18),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // Estado
              Text(
                statusLabel,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  letterSpacing: 3,
                  color: activeColor.withOpacity(0.6),
                ),
              ),
            ],
          ),

          // Scanlines overlay decorativo
          Positioned.fill(child: CustomPaint(painter: _ScanlinesPainter())),
        ],
      ),
    );
  }
}

// ── Ring Painter ───────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.activeColor,
    required this.bgColor,
  });
  final double progress;
  final Color activeColor;
  final Color bgColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = bgColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    // Arco de progreso
    final arcPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    // Glow
    final glowPaint = Paint()
      ..color = activeColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        arcPaint,
      );
    }

    // Punto en el extremo del arco
    if (progress > 0.01 && progress < 0.99) {
      final dotAngle = startAngle + sweepAngle;
      final dotX = center.dx + radius * cos(dotAngle);
      final dotY = center.dy + radius * sin(dotAngle);
      canvas.drawCircle(Offset(dotX, dotY), 5, Paint()..color = activeColor);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.activeColor != activeColor;
}

// ── Scanlines Painter ──────────────────────────────────────────────────────────

class _ScanlinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_ScanlinesPainter _) => false;
}

// ── Control Row ────────────────────────────────────────────────────────────────

class _ControlRow extends StatelessWidget {
  const _ControlRow({
    required this.state,
    required this.activeColor,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onReset,
  });
  final TimerState state;
  final Color activeColor;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 16),

        // Botón principal
        if (state == TimerState.idle || state == TimerState.finished)
          _HackerButton(
            label: '[ INICIAR ]',
            color: activeColor,
            onTap: onStart,
          )
        else if (state == TimerState.running)
          _HackerButton(label: '[ PAUSAR ]', color: activeColor, onTap: onPause)
        else
          _HackerButton(
            label: '[ REANUDAR ]',
            color: activeColor,
            onTap: onResume,
          ),
      ],
    );
  }
}

class _HackerButton extends StatelessWidget {
  const _HackerButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.small = false,
  });
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: small ? 16 : 28,
          vertical: small ? 10 : 14,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1.5),
          color: color.withOpacity(0.06),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: small ? 12 : 15,
            letterSpacing: 2,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
