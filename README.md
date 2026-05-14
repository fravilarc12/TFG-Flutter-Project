# ✈️ TravelHub - Tu Gestor de Viajes Integral

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange?logo=firebase)](https://firebase.google.com)
[![Clean Architecture](https://img.shields.io/badge/Architecture-Features--First-green)](https://blog.cleancoder.com)

---

## 📋 Resumen del Proyecto

**TravelHub** es una aplicación móvil desarrollada en **Flutter** diseñada para ser tu asistente personal a la hora de organizar, planificar y gestionar viajes. Desde el control de los gastos y el equipaje hasta la organización de los documentos y recuerdos, TravelHub centraliza todo lo que necesitas para tu próxima aventura en una única interfaz moderna e intuitiva.

## ✨ Características Principales

- **Seguridad**: Registro e inicio de sesión seguro mediante Firebase Auth.
- **Gestión de Viajes (CRUD)**: Crea, lee, actualiza y elimina tus expediciones de viaje de manera sencilla.
- **Equipaje Controlado**: Listas de control (Checklist) organizadas por categorías (Ropa, Electrónica, Aseo, etc.).
- **Control de Presupuesto**: Añade los gastos de tu viaje categorizados y mantén un control visual de tu presupuesto. Recibe alertas visuales si sobrepasas tu límite.
- **Galería Fotográfica**: Captura o sube imágenes a la nube para guardar tus recuerdos de viaje.
- **Mapas y Rutas**: Encuentra ubicaciones, añade marcadores y visualiza tus destinos interactuando directamente con OpenStreetMap y Google Maps API.
- **Billetera de Documentos**: Sube y almacena todos los PDFs o imágenes esenciales de tu viaje (billetes, reservas de hotel, visados).

---

## 🏗️ Arquitectura del Proyecto

### Patrón Arquitectónico: **Features-First + Clean Architecture**

El proyecto implementa una arquitectura escalable y mantenible separada por casos de uso y características:

```text
lib/src/
├── features/             # Características de la app (Auth, Trips, etc.)
├── routing/              # Configuración de rutas seguras con GoRouter
├── shared/               # Componentes visuales reutilizables
└── core/                 # Configuración global y estilos de la aplicación
```

### Diseño Visual y UX/UI
- **Estilo**: Moderno, limpio, basado en tarjetas con bordes redondeados y sombras suaves.
- **Paleta de Colores**: Basada en un **Azul Océano** principal, con acentos en **Coral** para interacciones.

---

## 🛠️ Stack Tecnológico

| Categoría | Tecnología | Propósito |
|-----------|-----------|-----------|
| **Framework** | Flutter 3.x | Desarrollo multiplataforma móvil nativo |
| **State Management** | Riverpod 2.x | Gestión de estado reactivo y escalable |
| **Backend (BaaS)** | Firebase | Autenticación, Base de Datos en Tiempo Real (Firestore) y Almacenamiento (Storage) |
| **Mapas** | flutter_map / Google API | Renderizado de mapas interactivos y geocodificación |
| **Navegación** | GoRouter | Routing declarativo |
| **UI/UX** | Material Design 3 | Implementación visual moderna |

---

## 🚀 Instalación y Ejecución

### Requisitos Previos
- **Flutter SDK** 3.16.0 o superior
- **Dart** 3.2.0 o superior
- **Firebase CLI** (para la configuración del backend)

### Pasos de Instalación
```bash
# 1. Clonar el repositorio
git clone https://github.com/fravilarc12/TFG-Flutter-Project.git
cd TFG-Flutter-Project

# 2. Instalar dependencias
flutter pub get

# 3. Generar código de Riverpod (build_runner)
dart run build_runner build --delete-conflicting-outputs

# 4. Configurar Firebase (sigue las instrucciones en pantalla)
flutterfire configure

# 5. Ejecutar la aplicación
flutter run
```

---

## 👤 Contacto

**Francisco Villodres Arce**  
📧 pvillodresarce@gmail.com  
🔗 [LinkedIn](https://linkedin.com/in/paco-v-arce) | [GitHub](https://github.com/fravilarc12)