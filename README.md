# ⚡ HackTime - FOCUS_OS v2.5.1

HackTime (también conocido internamente como **FOCUS_OS**) es una aplicación de gestión de tiempo y productividad con una interfaz estética inspirada en terminales de comandos "Hacker" de estilo retro-cyberpunk. Incorpora un sistema avanzado y automatizado de escudo de seguridad global que reacciona al ciclo de vida del dispositivo móvil.

## 🚀 Características Principales

* **Estética Terminal Hacker:** Toda la interfaz gráfica cuenta con fuentes monoespaciadas, paletas de colores basadas en verde fósforo (`#00FF41`), animaciones de cursor intermitente, efectos de escritura fluida (*typewriter*) y líneas de escaneo de monitor CRT (*scanlines*).
* **Módulo de Autenticación Virtual:** Pantalla de acceso simulado con estados de carga animados que validan credenciales antes de inicializar el sistema de control de tiempo.
* **Focus Timer Interactivo:** Un temporizador circular estilizado con animaciones de pulso y soporte dinámico para el progreso visual de las sesiones de enfoque.
* **Escudo de Seguridad Global (`SecurityScreen`):** Monitorea en segundo plano el estado del hardware a través de un `WidgetsBindingObserver`. Si la aplicación pierde el foco principal o se envía a segundo plano, el sistema se bloquea inmediatamente desplegando una pantalla de alerta crítica ("BRECHA DE SEGURIDAD").
* **Restablecimiento Seguro:** El botón de restablecer la sesión limpia por completo el estado del temporizador en memoria (`TimerProvider`) y destruye el historial de navegación redirigiendo de forma obligatoria al Login mediante una clave de navegación global (`navigatorKey`).

## 🛠️ Tecnologías y Arquitectura

* **Framework:** Flutter
* **Gestión de Estado:** `Provider` y `MultiProvider` (Patrón de inyección de dependencias para estados compartidos como `TimerProvider` y `ThemeProvider`).
* **Efectos Visuales Personalizados:** Renderizado del anillo de progreso mediante `CustomPainter` (`_RingPainter` y `_ScanlinesPainter`).
* **Control del Ciclo de Vida:** Mezcla de mixins (`WidgetsBindingObserver`) para interceptar cambios a nivel de sistema operativo (`AppLifecycleState.resumed`).

## 📂 Estructura del Código Fuente (Módulos Críticos)

```text
lib/
├── main.dart                 # Punto de entrada, inyección de Providers y Escudo de Seguridad Global.
├── provider/
│   └── timer_provider.dart   # Lógica del estado del temporizador (Pomodoro, pausas, reseteos).
├── themes/
│   └── app_theme.dart        # Configuración de temas claros y oscuros del sistema.
└── screens/
    ├── login_screen.dart     # Terminal de acceso, efectos estéticos de arranque y typewriter.
    └── timer_screen.dart     # Interfaz principal del cronómetro y acciones de usuario.
```

## ⚙️ Configuración del Escudo de Seguridad (main.dart)
El secreto de la persistencia de la alerta de seguridad radica en envolver la raíz del enrutador de Flutter utilizando la propiedad builder de MaterialApp:

```dart
MaterialApp(
  navigatorKey: navigatorKey, // Clave global para navegación absoluta
  home: const LoginScreen(),
  builder: (context, child) {
    return SecurityScreen(child: child!); // Capa protectora por encima de cualquier pantalla
  },
)
```

## 💻 Instalación y Ejecución

1. Asegúrate de tener instalado el SDK de Flutter en tu entorno local.

2. Clona este repositorio o descarga los archivos en tu espacio de trabajo.

3. Instala las dependencias necesarias ejecutando en la terminal:

```bash
flutter pub get
```

4. Conecta un emulador o dispositivo físico y arranca la aplicación:

```bash
flutter run
```