# task_manager_hilagro

Una aplicación móvil de gestión de tareas desarrollada en Flutter con autenticación Firebase y almacenamiento local SQLite.

## Características

- Autenticación de usuarios con Firebase Auth
- Gestión de tareas con CRUD completo
- Almacenamiento local usando SQLite
- Filtros por fecha (tareas de hoy, esta semana)
- Interfaz intuitiva con Material Design 3
- Localización en español
- Estado de tareas (pendientes/completadas)

## Tecnologías

- **Flutter** - Framework de desarrollo móvil
- **Firebase Auth** - Autenticación de usuarios
- **SQLite** - Base de datos local
- **Provider** - Gestión de estado
- **Intl** - Internacionalización y formateo de fechas

## Estructura del Proyecto

```
lib/
├── app/
│   └── app.dart
├── core/
│   └── database/
│       └── database_helper.dart
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       ├── pages/
│   │       └── providers/
│   ├── splash/
│   └── tasks/
│       ├── domain/
│       └── presentation/
└── main.dart
```

## Getting Started

### Prerequisitos

- Flutter SDK instalado
- Cuenta de Firebase
- Editor de código (VS Code recomendado)

### Instalación

1. Clona el repositorio
```bash
git clone https://github.com/arthurficher/task_manager_hilagro/settings
cd task_manager_hilagro
```

2. Instala las dependencias
```bash
flutter pub get
```

3. Configura Firebase
   - Crea un proyecto en Firebase Console
   - Agrega tu app Android/iOS
   - Descarga el archivo google-services.json
   - Colócalo en android/app/

4. Ejecuta la aplicación
```bash
flutter run
```

# Configuración de Firebase

## Pasos para configurar Firebase:

1. Crear proyecto en [Firebase Console](https://console.firebase.google.com/)
2. Agregar app Android con package: `com.example.task_manager_hilagro`
3. Descargar `google-services.json` y colocar en: `android/app/`
4. Agregar app iOS con bundle ID: `com.example.taskManagerHilagro`
5. Descargar `GoogleService-Info.plist` y colocar en: `ios/Runner/`
6. Habilitar **Email/Password** en Authentication

## Estructura de Firebase requerida:
- Authentication: Email/Password habilitado
- Sin Firestore ni Realtime Database (solo SQLite local)

## Dependencias Principales

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  provider: ^6.1.1
  sqflite: ^2.3.0
  intl: ^0.18.1
  uuid: ^4.2.1
  equatable: ^2.0.5
```

## Funcionalidades

### Autenticación
- Inicio de sesión con email y contraseña
- Gestión de estados de autenticación
- Validación de formularios

### Gestión de Tareas
- Crear nuevas tareas
- Marcar como completadas
- Filtrar por fecha
- Eliminar tareas

## Uso

1. Inicia sesión con tu email y contraseña
2. Ve el dashboard con el resumen de tareas
3. Crea nuevas tareas usando el botón flotante
4. Marca tareas como completadas
5. Cierra sesión cuando termines

## Contribución

1. Fork el proyecto
2. Crea una rama feature
3. Commit tus cambios
4. Push a la rama
5. Abre un Pull Request

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

