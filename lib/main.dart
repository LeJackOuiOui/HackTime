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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'HackTime',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            home: const LoginScreen(), // pantalla directa, sin go_router
          );
        },
      ),
    );
  }
}

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen>
    with WidgetsBindingObserver {
  // Variable que controla si se muestra la alerta
  bool _sesionFallida = false;

  @override
  void initState() {
    super.initState();
    // Registra el observador para escuchar cuando el usuario sale de la app
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Limpia el observador al destruir la pantalla
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Si la app estuvo en segundo plano y el usuario regresa (resumed)
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _sesionFallida = true; // Activa la alerta de seguridad
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Center(
            child: Text(
              'Tu aplicación está corriendo normalmente aquí...',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),

          if (_sesionFallida)
            Container(
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

                  // --- AQUÍ ESTÁ EL NUEVO BOTÓN PARA REINICIAR LA SESIÓN ---
                  const SizedBox(height: 40), // Espacio arriba del botón
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
                    onPressed: () {
                      setState(() {
                        _sesionFallida = false;
                      });
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
                  // --------------------------------------------------------
                ],
              ),
            ),
        ],
      ),
    );
  }
}

