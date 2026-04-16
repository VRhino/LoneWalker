# LoneWalker - Documentación

Bienvenido a la documentación de **LoneWalker**, una aplicación de exploración gamificada basada en ubicación GPS que transforma tu forma de descubrir las ciudades.

## 📋 Tabla de Contenidos

1. [Descripción General](#descripción-general)
2. [Características Principales](#características-principales)
3. [Guía de Características](#guía-de-características)
4. [Arquitectura Técnica](#arquitectura-técnica)
5. [Primeros Pasos](#primeros-pasos)

## Descripción General

LoneWalker es una aplicación móvil innovadora que gamifica la exploración urbana. Basada en la ubicación del usuario (GPS), la app utiliza mecánicas de videojuegos para motivar a los usuarios a caminar por su ciudad, descubrir nuevos lugares y participar en búsquedas de tesoros.

### Objetivo Principal
Transformar la exploración urbana en una aventura emocionante mediante:
- Niebla de guerra que se despeja al caminar
- Búsqueda de tesoros con mecánica de radar
- Logros y rankings sociales
- Recompensas digitales exclusivas

## Características Principales

### 1. **Mecánicas de Exploración y Mapa**
- **Fog of War (Niebla de Guerra)**: Capa visual sobre Google Maps que se despeja progresivamente al caminar
- **Degradación Dinámica**: Las zonas descubiertas se vuelven a cubrir lentamente con el tiempo, fomentando la re-exploración
- **Zona de Maestría**: Alcanzar el 100% de exploración de un distrito otorga logros de "Conquistador"
- **Modo Offline**: Cacheo de mapas y sincronización posterior

### 2. **Filtro de Integridad y Realismo**
- **Speed Limit (Límite de Velocidad)**: Si superas 20 km/h, la progresión se detiene automáticamente
- Aviso amigable invitando al usuario a caminar

### 3. **Búsqueda del Tesoro: Mecánica de Radar**
- **Activación por Proximidad**: Se activa al estar a 50-100 metros de un punto de interés
- **Interfaz Caliente/Frío**: Indicadores visuales y vibración háptica que intensifican al acercarse
- **Validación GPS**: Reclamación de hallazgos a menos de 5-10 metros

### 4. **Gestión de Objetos y Recompensas**
- **Escasez Real**: Tesoros con contador de usos limitado (ej. "Solo para los 5 primeros")
- **Objetos Agotados**: Cambio a estado "Archivado" con muro de la fama
- **Recompensa Digital**: Archivos .STL exclusivos y medallas digitales

### 5. **Social y Privacidad**
- **Ranking de Exploradores**: Clasificación por porcentaje descubierto y tesoros encontrados
- **Control de Privacidad**: Opción de modo privado o ranking público

## Guía de Características

Para detalles específicos sobre cada característica, consulta:

- [Mecánicas de Exploración](./features/exploration-mechanics.md)
- [Sistema de Radar y Tesoros](./features/treasure-hunt-radar.md)
- [Sistema Social y Ranking](./features/social-system.md)
- [Gestión de Privacidad](./features/privacy-settings.md)

## Arquitectura Técnica

Para información sobre la estructura del código y arquitectura:

- [Arquitectura del Proyecto](./technical/architecture.md)
- [Guía de Configuración](./technical/setup.md)
- [API Referencias](./technical/api-reference.md)

## Primeros Pasos

### Requisitos
- Dispositivo móvil con GPS
- Conexión a internet (con soporte offline)
- Permiso de ubicación habilitado

### Instalación
Ver [Guía de Configuración](./technical/setup.md)

### Uso Básico
1. Abre la aplicación
2. Comienza a caminar para explorar
3. Observa cómo se despeja la niebla de guerra
4. Busca tesoros cuando se active el radar
5. Sube de rango en el ranking

---

**Última actualización**: Abril 2026
