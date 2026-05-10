# 🎓 TFG: Análisis Comparativo de Frameworks Multiplataforma

> **Trabajo de Fin de Grado** - Universidad de Sevilla (2025-2026)  
> **Autor**: Francisco Villodres Arce  
> **Grado**: Ingeniería Informática - Ingeniería de Computadores

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange?logo=firebase)](https://firebase.google.com)
[![Clean Architecture](https://img.shields.io/badge/Architecture-Features--First-green)](https://blog.cleancoder.com)

---

## 📋 Resumen del Proyecto

Estudio comparativo entre **Flutter** y **React Native** analizando:
- ⚡ Rendimiento en tiempo de ejecución y consumo de recursos
- 📦 Ecosistema de librerías, plugins y herramientas
- 📈 Curva de aprendizaje y productividad del desarrollador
- 🚀 Escalabilidad y mantenibilidad en aplicaciones de producción

## 🎯 Objetivos del TFG

1. **Análisis teórico**: Comparar las arquitecturas, paradigmas y ecosistemas de ambos frameworks
2. **Desarrollo práctico**: Implementar una aplicación completa con Flutter como caso de estudio (TravelHub / Travel Planner App)
3. **Benchmarking**: Realizar mediciones objetivas de rendimiento (FPS, uso de memoria, tiempo de carga)
4. **Evaluación cualitativa**: Documentar la experiencia de desarrollo y mejores prácticas

---

## ✈️ Caso de Estudio: TravelHub (Travel Planner App)

Aplicación móvil de planificación de viajes desarrollada en **Flutter** para demostrar las capacidades del framework en un entorno de producción real, sirviendo como solución integral para la gestión centralizada de viajes.

### ✨ Características Principales (Requisitos Funcionales)

El sistema cumple con los siguientes casos de uso y funcionales (FRQ):
- **FRQ-0001**: Registro e inicio de sesión seguro con **Firebase Auth**, con redirección inteligente de sesiones.
- **FRQ-0002**: CRUD Completo de expediciones de viaje (crear, leer, actualizar, borrar con confirmación en deslizamiento).
- **FRQ-0003**: Gestión de listas de control (Checklist) de equipaje, con categorización de ítems.
- **FRQ-0004**: Registro y categorización de gastos, actualización de balance y control de límites de presupuesto (alertas visuales en rojo si se excede el gasto).
- **FRQ-0005**: Subida y visualización de recuerdos en galería fotográfica (con vista de **Masonry Grid** y límite de tamaño de 5 MB por imagen para evitar bloqueos de memoria).
- **FRQ-0006**: Ubicación de puntos de interés y marcadores en mapas interactivos mediante **Google Maps API**.
- **FRQ-0007**: Consulta y gestión de documentos de viaje nativos (billetes/PDFs).

### 🛡️ Reglas de Negocio (CRQ) y Seguridad

- **Privacidad**: Solo el propietario (UID coincidente) puede leer, editar o borrar sus recursos.
- **Validaciones**: 
  - La fecha de fin del viaje debe ser posterior a la de inicio.
  - Los importes de gastos son numéricos positivos.
- **Rendimiento y Límites**: Límite técnico de 5 MB por archivo subido a la galería para prevenir problemas de memoria (OOM Errors).

---

## 🏗️ Arquitectura del Proyecto

### Patrón Arquitectónico: **Features-First + Clean Architecture**

El proyecto implementa una **arquitectura por capas y características** que separa responsabilidades y facilita el testing y la escalabilidad, mitigando problemas comunes de acoplamiento y centralizando configuraciones.
```text
lib/src/
├── features/              # Características de la app
│   ├── auth/             # Autenticación y gestión de usuarios
│   └── trips/            # Gestión de viajes, gastos, equipaje, mapas, galería
├── routing/              # Configuración de GoRouter con redirecciones de seguridad
├── shared/               # Componentes de UI reutilizables
└── core/                 # Configuración global (colores en app_colors.dart, temas)
```

### Atributos de Calidad (Requisitos No Funcionales)
- **NFR-0001 (Seguridad)**: Cifrado de las comunicaciones mediante HTTPS/SSL/TLS y gestión robusta de estados de sesión.
- **NFR-0002 (Disponibilidad)**: Persistencia de datos local offline y sincronización automática bidireccional vía Firestore.
- **NFR-0003 (Portabilidad)**: Diseñado para ser compatible con Android 8.0+ e iOS 13.0+.
- **NFR-0004 (Usabilidad)**: Diseño accesible donde las acciones principales se ejecutan en menos de 3 clics y respuesta veloz (< 200ms).

### Diseño Visual y UX/UI
- **Estilo**: Moderno, limpio, basado en tarjetas con bordes redondeados y sombras suaves.
- **Paleta de Colores**: Centralizada (`app_colors.dart`) usando un **Azul Océano** como primario, fondos en blancos y grises claros, con toques de **Coral** en acentos y botones.
- **Navegación**: Barra de navegación inferior principal, enriquecida con menús de pestañas (Tabs) divididas en archivos independientes para las vistas de detalle del viaje.

---

## 🛠️ Stack Tecnológico

| Categoría | Tecnología | Propósito |
|-----------|-----------|-----------|
| **Framework** | Flutter 3.x | Desarrollo multiplataforma móvil nativo |
| **Lenguaje** | Dart 3.x | Lenguaje de programación principal |
| **State Management** | Riverpod 2.x | Gestión de estado reactivo y segura con code generation |
| **Backend (BaaS)** | Firebase | Auth, Cloud Firestore (BBDD en tiempo real) y Cloud Storage |
| **Mapas** | Google Maps API | Integración interactiva de mapas y localización de marcadores |
| **Navegación** | GoRouter | Routing declarativo, type-safe y redirecciones condicionales |
| **Sincronización** | Streams | Recepción de eventos y actualizaciones en tiempo real de Firestore |
| **UI/UX** | Material Design 3 | Implementación de las guías de diseño modernas de Google |

---

## 🚀 Instalación y Ejecución

### Requisitos Previos
- **Flutter SDK** 3.16.0 o superior
- **Dart** 3.2.0 o superior
- **Firebase CLI** (para configuración de Firebase backend)
- **Android Studio** / **Xcode** (para emulación en dispositivos)

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

### Comandos Útiles
```bash
# Ejecutar en modo release
flutter run --release

# Ejecutar tests
flutter test

# Generar código en watch mode
dart run build_runner watch
```

---

## 📊 Estado del Proyecto

**Inicio**: Noviembre 2025 | **Finalización prevista**: Junio 2026

### Progreso Actual

- [x] Investigación bibliográfica y estado del arte
- [x] Análisis de arquitecturas Flutter vs React Native
- [x] Setup del proyecto con Clean Architecture (Features-First)
- [x] Implementación de autenticación segura con Firebase (Login y redirecciones por sesión)
- [x] CRUD completo de viajes con sincronización instantánea y confirmación de borrado
- [x] Refactorización UI: Material Design 3, modo oscuro y constantes de color
- [x] Implementación de gestión de gastos con límites visuales de presupuesto (FRQ-0004)
- [x] Visores interactivos de Mapas (Google Maps, FRQ-0006) y Galería fotográfica (Masonry Grid, FRQ-0005)
- [x] Optimización de almacenamiento con límites de subida a 5MB por imagen
- [x] Integración de carga y visor de Docs nativos (Billetes/PDFs) (FRQ-0007)
- [x] Implementación de agrupado/categorías en Checklists de Equipaje (FRQ-0003)
- [x] Mantenimiento y control de estabilidad (prevención de Memory Leaks, Auth double-tap)
- [ ] Testing exhaustivo (Unit, Widget, Integration)
- [ ] Benchmarks de rendimiento en dispositivos físicos vs React Native
- [ ] Documentación técnica final
- [ ] Redacción de memoria del TFG

---

## 🔬 Metodología de Investigación

### 1. Análisis Teórico
- Estudio de documentación oficial de Flutter y React Native
- Revisión de papers académicos sobre frameworks multiplataforma
- Análisis de casos de uso empresariales en producción

### 2. Desarrollo Práctico
- Implementación iterativa de Travel Planner App como caso de estudio principal
- Aplicación de patrones arquitectónicos avanzados y refactorizaciones (Clean Code)
- Documentación de decisiones técnicas y trade-offs durante el ciclo de vida del proyecto

### 3. Benchmarking Cuantitativo
- Medición de rendimiento en ejecución: FPS, consumo de memoria, tiempo de carga
- Análisis comparativo del tamaño de binarios (APK para Android / IPA para iOS)
- Comparación de tiempos de desarrollo e incremento en la productividad

### 4. Evaluación Cualitativa
- Experiencia de desarrollo (DX) y asimilación de la curva de aprendizaje
- Calidad general del ecosistema (madurez de paquetes en pub.dev, comunidad)

---

## 🧪 Testing
```bash
# Ejecutar todos los tests del proyecto
flutter test

# Generar y visualizar reporte de Coverage de código
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 📖 Recursos de Aprendizaje y Referencias

- [Flutter Official Documentation](https://docs.flutter.dev)
- [Riverpod Documentation](https://riverpod.dev)
- [Firebase for Flutter](https://firebase.google.com/docs/flutter/setup)
- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

## 👤 Contacto

**Francisco Villodres Arce**  
📧 pvillodresarce@gmail.com  
🔗 [LinkedIn](https://linkedin.com/in/paco-v-arce) | [GitHub](https://github.com/fravilarc12)

**Director del TFG**: [Amador Duran Toro]  
**Universidad de Sevilla** - Escuela Técnica Superior de Ingeniería Informática

---

<div align="center">

*Trabajo de Fin de Grado - Curso Académico 2025/2026*

**Universidad de Sevilla** | Grado en Ingeniería Informática

</div>