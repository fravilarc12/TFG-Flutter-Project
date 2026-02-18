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
2. **Desarrollo práctico**: Implementar una aplicación completa con Flutter como caso de estudio
3. **Benchmarking**: Realizar mediciones objetivas de rendimiento (FPS, uso de memoria, tiempo de carga)
4. **Evaluación cualitativa**: Documentar la experiencia de desarrollo y mejores prácticas

---

## ✈️ Caso de Estudio: Travel Planner App

Aplicación móvil de planificación de viajes desarrollada en **Flutter** para demostrar las capacidades del framework en un entorno de producción real.

### ✨ Características Implementadas

#### 🔐 Autenticación y Seguridad
- Registro e inicio de sesión mediante **Firebase Authentication**
- Gestión segura de sesiones y tokens
- Recuperación de contraseña

#### 🗺️ Gestión de Viajes (CRUD Completo)
- **Crear** nuevos viajes con destino, fechas y presupuesto
- **Leer** y visualizar viajes sincronizados en tiempo real
- **Actualizar** detalles de viajes existentes
- **Eliminar** viajes con confirmación

#### 📱 Interfaz de Usuario Avanzada
- **Material Design 3** con soporte para modo claro/oscuro
- **Navegación por pestañas** para gestión de itinerario, equipaje y gastos
- **Streams de Firebase** para sincronización instantánea
- Diseño responsive adaptado a diferentes tamaños de pantalla

#### 🎒 Funcionalidades Adicionales
- Lista de equipaje organizada por categorías
- Seguimiento de gastos por viaje
- Itinerario detallado con ubicaciones y horarios

---

## 🏗️ Arquitectura del Proyecto

### Patrón Arquitectónico: **Features-First + Clean Architecture**

El proyecto implementa una **arquitectura por capas y características** que separa responsabilidades y facilita el testing y escalabilidad:
```
lib/src/
├── features/              # Características de la app
│   ├── auth/             # Feature: Autenticación
│   │   ├── presentation/ # Pantallas y widgets
│   │   ├── domain/       # Lógica de negocio
│   │   └── data/         # Repositorios y data sources
│   └── trips/            # Feature: Gestión de viajes
│       ├── presentation/
│       ├── domain/
│       └── data/
├── routing/              # Configuración de GoRouter
├── shared/               # Widgets y utilidades compartidas
└── core/                 # Configuración global (tema, constantes)
```

### Principios Aplicados

✅ **Separation of Concerns**: Cada capa tiene una responsabilidad única  
✅ **Dependency Inversion**: Las capas superiores no dependen de las inferiores  
✅ **Testability**: Cada componente es testeable de forma aislada  
✅ **Scalability**: Fácil añadir nuevas features sin afectar las existentes

---

## 🛠️ Stack Tecnológico

| Categoría | Tecnología | Propósito |
|-----------|-----------|-----------|
| **Framework** | Flutter 3.x | UI multiplataforma |
| **Lenguaje** | Dart 3.x | Lenguaje principal |
| **State Management** | Riverpod 2.x | Gestión de estado reactivo con code generation |
| **Backend** | Firebase | Authentication + Cloud Firestore |
| **Navegación** | GoRouter | Routing declarativo y type-safe |
| **Sincronización** | Streams | Updates en tiempo real desde Firestore |
| **UI/UX** | Material Design 3 | Sistema de diseño moderno |

### Dependencias Principales
```yaml
dependencies:
  flutter_riverpod: ^2.x
  riverpod_annotation: ^2.x
  go_router: ^12.x
  firebase_core: ^2.x
  firebase_auth: ^4.x
  cloud_firestore: ^4.x
```

---

## 🚀 Instalación y Ejecución

### Requisitos Previos
- **Flutter SDK** 3.16.0 o superior
- **Dart** 3.2.0 o superior
- **Firebase CLI** (para configuración de Firebase)
- **Android Studio** / **Xcode** (para emuladores)

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

# Analizar código
flutter analyze
```

---

## 📊 Estado del Proyecto

**Inicio**: Noviembre 2025 | **Finalización prevista**: Junio 2026

### Progreso Actual

- [x] Investigación bibliográfica y estado del arte
- [x] Análisis de arquitecturas Flutter vs React Native
- [x] Setup del proyecto con Clean Architecture
- [x] Implementación de autenticación con Firebase
- [x] CRUD completo de viajes con sincronización en tiempo real
- [x] UI con Material Design 3 y modo oscuro
- [ ] Implementación completa de gestión de gastos
- [ ] Testing exhaustivo (Unit, Widget, Integration)
- [ ] Benchmarks de rendimiento vs React Native
- [ ] Documentación técnica final
- [ ] Redacción de memoria del TFG

---

## 🔬 Metodología de Investigación

### 1. Análisis Teórico
- Estudio de documentación oficial de Flutter y React Native
- Revisión de papers académicos sobre frameworks multiplataforma
- Análisis de casos de uso en producción (Alibaba, BMW, Google Pay)

### 2. Desarrollo Práctico
- Implementación de Travel Planner App como caso de estudio
- Aplicación de patrones arquitectónicos y mejores prácticas
- Documentación de decisiones técnicas y trade-offs

### 3. Benchmarking Cuantitativo
- Medición de rendimiento: FPS, consumo de memoria, tiempo de inicio
- Análisis de tamaño de binarios (APK/IPA)
- Comparación de tiempos de desarrollo y productividad

### 4. Evaluación Cualitativa
- Experiencia de desarrollo (DX)
- Curva de aprendizaje
- Calidad del ecosistema (packages, herramientas, comunidad)


---

## 🎨 Capturas de Pantalla

> **Nota**: Se añadirán capturas cuando la UI esté completamente implementada

---

## 🧪 Testing
```bash
# Ejecutar todos los tests
flutter test

# Coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Estrategia de Testing
- **Unit Tests**: Lógica de negocio y repositorios
- **Widget Tests**: Componentes de UI
- **Integration Tests**: Flujos completos de usuario

---

## 📖 Recursos de Aprendizaje

Durante el desarrollo de este TFG se consultaron:

- [Flutter Official Documentation](https://docs.flutter.dev)
- [Riverpod Documentation](https://riverpod.dev)
- [Firebase for Flutter](https://firebase.google.com/docs/flutter/setup)
- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

## 📄 Licencia

Este proyecto está desarrollado con fines académicos como parte del Trabajo de Fin de Grado.

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