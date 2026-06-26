import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'themes/app_theme.dart';
import 'provider/timer_provider.dart';
import 'screens/timer_screen.dart';
import 'screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema de Seguridad',
      theme: ThemeData(useMaterial3: true),
      home: const SecurityScreen(child: LoginScreen()),
    );
  }
}

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key, required this.child});

  final Widget child;

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen>
    with WidgetsBindingObserver {
  bool _sesionFallida = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _sesionFallida = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child,

          if (_sesionFallida)
            // 3. El Builder ahora genera el contexto correcto para buscar el TimerProvider
            Builder(
              builder: (innerContext) {
                return Container(
                  color: Colors.redAccent.withOpacity(0.98),
                  width: double.infinity,
                  height: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.gpp_bad_outlined,
                        color: Colors.white,
                        size: 110,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'BRECHA DE SEGURIDAD',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Sesión Fallida',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Se detectó un cambio de entorno o la aplicación perdió el foco principal.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),

                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          // Ocultamos la alerta inmediatamente
                          setState(() {
                            _sesionFallida = false;
                          });

                          // Buscamos el TimerProvider usando el innerContext del Builder
                          final timer = Provider.of<TimerProvider>(
                            innerContext,
                            listen: false,
                          );
                          timer.reset();

                          // 4. Redirigimos usando la navigatorKey global instalada en la raíz
                          navigatorKey.currentState?.pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text(
                          'Reestablecer Sesión',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}