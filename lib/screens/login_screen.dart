import 'dart:async';
import 'package:flutter/material.dart';
import 'timer_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // ── Paleta hacker (igual que TimerScreen) ──────────────────────────────────
  static const Color _bg = Color(0xFF030D03);
  static const Color _green = Color(0xFF00FF41);
  static const Color _greenMuted = Color(0xFF005515);

  // ── Estado del formulario ──────────────────────────────────────────────────
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String _terminalOutput = '';
  String _errorMsg = '';

  // ── Animación de cursor parpadeante ───────────────────────────────────────
  late AnimationController _cursorCtrl;
  Timer? _typeTimer;

  @override
  void initState() {
    super.initState();
    _cursorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    // Efecto typewriter al arrancar
    _typeWelcome();
  }

  void _typeWelcome() {
    const msg = '> Bienvenido a FOCUS_OS v2.5.1\n> Autentícate para continuar_';
    int i = 0;
    _typeTimer = Timer.periodic(const Duration(milliseconds: 35), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _terminalOutput = msg.substring(0, i + 1));
      i++;
      if (i >= msg.length) t.cancel();
    });
  }

  // ── Lógica de login falso ──────────────────────────────────────────────────
  Future<void> _login() async {
    final user = _userCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      setState(() => _errorMsg = '> ERROR: campos vacíos');
      return;
    }

    setState(() {
      _loading = true;
      _errorMsg = '';
      _terminalOutput = '> Verificando credenciales...';
    });

    // Simula delay de "autenticación"
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    setState(() {
      _terminalOutput =
          '> Acceso concedido. Iniciando sesión...\n> Cargando módulos...';
    });

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    // Navega reemplazando la pantalla (no puede volver al login con Back)
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const TimerScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _cursorCtrl.dispose();
    _typeTimer?.cancel();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── UI ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── ASCII header ──────────────────────────────────────────────
              const _AsciiHeader(),
              const SizedBox(height: 32),

              // ── Terminal output ───────────────────────────────────────────
              _TerminalBox(text: _terminalOutput),
              const SizedBox(height: 28),

              // ── Campos ────────────────────────────────────────────────────
              _HackerField(
                label: 'USUARIO',
                controller: _userCtrl,
                obscure: false,
              ),
              const SizedBox(height: 14),
              _HackerField(
                label: 'CONTRASEÑA',
                controller: _passCtrl,
                obscure: true,
              ),
              const SizedBox(height: 8),

              // ── Error ─────────────────────────────────────────────────────
              if (_errorMsg.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _errorMsg,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Color(0xFFFF2D2D),
                      letterSpacing: 1,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // ── Botón login ───────────────────────────────────────────────
              _loading
                  ? const Center(child: _LoadingDots())
                  : _LoginButton(onTap: _login),
            ],
          ),
        ),
      ),
    );
  }
}

// ── ASCII Header ───────────────────────────────────────────────────────────────

class _AsciiHeader extends StatelessWidget {
  const _AsciiHeader();

  @override
  Widget build(BuildContext context) {
    const art = '''
 ██╗  ██╗ █████╗  ██████╗██╗  ██╗
 ██║  ██║██╔══██╗██╔════╝██║ ██╔╝
 ███████║███████║██║     █████╔╝ 
 ██╔══██║██╔══██║██║     ██╔═██╗ 
 ██║  ██║██║  ██║╚██████╗██║  ██╗
 ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝
     T I M E   [ v 2 . 5 . 1 ]''';

    return Text(
      art,
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 9,
        color: Color(0xFF00FF41),
        height: 1.4,
        shadows: [Shadow(color: Color(0x8000FF41), blurRadius: 10)],
      ),
    );
  }
}

// ── Terminal output box ────────────────────────────────────────────────────────

class _TerminalBox extends StatelessWidget {
  const _TerminalBox({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF00FF41).withOpacity(0.2)),
        color: const Color(0xFF00FF41).withOpacity(0.03),
      ),
      child: Text(
        text.isEmpty ? '> _' : text,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          height: 1.6,
          color: Color(0x9900FF41),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Campo de texto estilo terminal ─────────────────────────────────────────────

class _HackerField extends StatelessWidget {
  const _HackerField({
    required this.label,
    required this.controller,
    required this.obscure,
  });
  final String label;
  final TextEditingController controller;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '> $label:',
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: Color(0x8800FF41),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            color: Color(0xFF00FF41),
            letterSpacing: 2,
          ),
          cursorColor: const Color(0xFF00FF41),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF00FF41).withOpacity(0.05),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(
                color: const Color(0xFF00FF41).withOpacity(0.3),
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: Color(0xFF00FF41), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Botón de login ─────────────────────────────────────────────────────────────

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF00FF41), width: 1.5),
          color: const Color(0xFF00FF41).withOpacity(0.07),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00FF41).withOpacity(0.15),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Text(
          '[ ACCEDER ]',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 15,
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00FF41),
          ),
        ),
      ),
    );
  }
}

// ── Animación de carga con puntos ──────────────────────────────────────────────

class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots> {
  int _dots = 0;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (mounted) setState(() => _dots = (_dots + 1) % 4);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '> Autenticando${'.' * _dots}',
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        color: Color(0xFF00FF41),
        letterSpacing: 2,
      ),
    );
  }
}
