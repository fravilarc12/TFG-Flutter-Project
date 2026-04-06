# Contexto y Stack Tecnológico
TravelHub es una solución móvil para la gestión centralizada de viajes.
- **Framework**: Flutter (Dart) para desarrollo multiplataforma.
- **Backend as a Service (BaaS)**: Firebase (Auth, Cloud Firestore, Cloud Storage).
- **Mapas**: Google Maps API.

## Requisitos de Información (IRQ) - Modelo de Datos
El sistema debe persistir las siguientes entidades en Firestore:
- **IRQ-0001 (Perfiles)**: UID, email, nombre y URL de foto de perfil.
- **IRQ-0002 (Viajes)**: Título, destino, fechas de inicio/fin y UID del propietario.
- **IRQ-0003 (Equipaje)**: Nombre del ítem, categoría, estado (booleano) e ID del viaje.
- **IRQ-0004 (Gastos)**: Concepto, importe (Double), fecha, categoría e ID del viaje.
- **IRQ-0005 (Mapas)**: Título, descripción, latitud, longitud e ID del viaje.
- **IRQ-0006 (Documentos)**: Tipo de recurso, nombre, URL/ruta e ID del viaje.
- **IRQ-0007 (Galería)**: URL de imagen, nombre, fecha de subida y tamaño.

## Reglas de Negocio y Restricciones (CRQ)
Políticas obligatorias que rigen la lógica del sistema:
- **CRQ-0001 (Privacidad)**: Solo el propietario (UID coincidente) puede leer, editar o borrar sus recursos.
- **CRQ-0002 (Fechas)**: La fecha de fin debe ser siempre posterior a la de inicio.
- **CRQ-0003 (Finanzas)**: Los importes de gastos deben ser valores numéricos positivos.
- **CRQ-0004 (Imágenes)**: Límite técnico de 5 MB por archivo en la galería.

## Requisitos Funcionales (FRQ) y Casos de Uso (UC)
Funcionalidades clave que el usuario debe poder ejecutar:
- **FRQ-0001 / UC-0001**: Registro e inicio de sesión seguro con Firebase Auth.
- **FRQ-0002 / UC-0002**: CRUD (Crear, Leer, Actualizar, Borrar) de expediciones de viaje.
- **FRQ-0003 / UC-0003**: Gestión de listas de control (Checklist) de equipaje.
- **FRQ-0004 / UC-0004**: Registro y categorización de gastos con actualización de balance.
- **FRQ-0005 / UC-0005**: Subida y visualización de recuerdos en galería fotográfica.
- **FRQ-0006 / UC-0006**: Ubicación de puntos de interés y marcadores en mapas interactivos.
- **FRQ-0007 / UC-0007**: Consulta y gestión de documentos de viaje (reservas/billetes).

## Requisitos No Funcionales (NFR)
Atributos de calidad y rendimiento:
- **NFR-0001 (Seguridad)**: Cifrado de comunicaciones mediante protocolos HTTPS/SSL/TLS.
- **NFR-0002 (Disponibilidad)**: Persistencia de datos en modo offline y sincronización automática.
- **NFR-0003 (Portabilidad)**: Compatible con Android 8.0+ e iOS 13.0+.
- **NFR-0004 (Usability)**: Acciones principales en menos de 3 clics; respuesta de UI < 200ms.

## Diseño Visual y UX/UI
- **Estilo**: Moderno, limpio, basado en tarjetas con bordes redondeados y sombras suaves.
- **Paleta sugerida**: Azul Océano (Primario), Blanco/Gris claro (Fondo) y Coral (Acentos/Botones).
- **Navegación**: Barra de navegación inferior y menús de pestañas (Tabs) en el detalle del viaje.
