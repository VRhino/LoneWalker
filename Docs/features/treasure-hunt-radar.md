# Sistema de Búsqueda del Tesoro y Mecánica de Radar

## Descripción General

La mecánica de búsqueda del tesoro es una experiencia inmersiva que convierte puntos de interés en aventuras emocionantes. El sistema de radar proporciona retroalimentación táctil y visual sin revelar la ubicación exacta.

## 1. Activación por Proximidad

### Trigger Automático
El modo radar se activa cuando el usuario entra en un radio específico de un punto de interés.

### Parámetros de Activación
- **Radio de Activación**: 50-100 metros del punto de interés
- **Tipo de Activación**: Automática (sin acción del usuario)
- **Notificación**: Alerta visual y sonora sutil cuando se activa
- **Desactivación**: Ocurre al alejarse más de 150 metros

### Puntos de Interés (POI)
- **Landmarks**: Lugares históricos, monumentos
- **Treasure Maker**: Depósitos de premios por creadores
- **Secretos**: Lugares ocultos descubiertos por la comunidad
- **Eventos**: Desafíos temporales ubicados

## 2. Interfaz Caliente/Frío

### Concepto Visual
En lugar de mostrar coordenadas exactas, el sistema proporciona retroalimentación progresiva que mejora según te acercas.

### Indicadores Visuales

#### Escala de Colores
```
Rojo (< 5m)     🔴 ¡Muy Caliente! - Estás aquí
Naranja (5-15m) 🟠 Caliente - Muy cerca
Amarillo (15-30m) 🟡 Tibio - Acercándote
Azul (30-50m)   🔵 Frío - Lejos
```

#### Elementos Adicionales
- **Barra de Progreso Circular**: Muestra proximidad en escala 0-100%
- **Brújula de Radar**: Indica dirección aproximada
- **Distancia Aproximada**: "Alrededor de X metros"

### Retroalimentación Háptica

#### Vibración Táctil
```
Frío (Azul):    Vibración leve cada 3 segundos
Tibio (Amarillo): Vibración moderada cada 2 segundos
Caliente (Naranja): Vibración intensa cada 1 segundo
Muy Caliente (Rojo): Vibración continua
```

#### Configuración de Haptics
- Intensidad: Ajustable (Bajo, Medio, Alto)
- Desactivable: Opción de vibración silenciosa
- Accesibilidad: Sonido alternativo disponible

## 3. Validación GPS

### Proceso de Reclamación

#### Etapas
1. **Proximidad**: Usuario a menos de 10 metros
2. **Confirmación Visual**: Pantalla muestra "¡Tesoro Encontrado!"
3. **Acción del Usuario**: Pulsa botón "Reclamar"
4. **Validación GPS**: Sistema verifica posición durante 3-5 segundos
5. **Confirmación**: Tesoro reclamado si GPS es válido

#### Requisitos
- Exactitud GPS: Mejor que 10 metros
- Conexión: Al menos conexión débil a internet
- Tiempo Mínimo: 3 segundos en la ubicación exacta
- Intentos: Máximo 3 intentos antes de bloqueo temporal

## 4. Gestión de Objetos y Recompensas Maker

### Sistema de Escasez Real

#### Contador de Usos
Cada tesoro tiene un límite predefinido:
```
{
  "treasureId": "treasure_001",
  "maxUses": 5,
  "currentUses": 3,
  "status": "active"
}
```

#### Tipos de Límites
- **Cantidad Fija**: "Solo para los 5 primeros"
- **Cantidad con Caducidad**: "5 premios válidos por 30 días"
- **Uso Ilimitado**: Algunos tesoros no tienen límite

### Tratamiento de Objetos Agotados

#### Estados del Tesoro
1. **Activo**: 🟢 Premios disponibles
2. **Bajo en Stock**: 🟡 Menos de 3 premios restantes
3. **Agotado**: ⚫ Premios terminados
4. **Archivado**: ⚪ Históricamente completado

#### Transición a Estado Archivado
- El icono en el mapa cambia a pedestal gris
- Se muestra "Archivado - Completado por X usuarios"
- Acceso a "Muro de la Fama"

### Muro de la Fama

#### Contenido
- Nombres de los primeros 5 ganadores
- Fecha de reclamación
- Puntos XP obtenidos
- Foto opcional del ganador

#### Acceso
- Visible al visitar el lugar después del agotamiento
- Compartible en redes sociales
- Registro permanente en el perfil del usuario

## 5. Recompensas Digitales

### Tipos de Recompensas

#### Archivos .STL (3D)
- **Formato**: STL (Stereolithography)
- **Uso**: Impresión 3D personal o comercial
- **Exclusividad**: Solo para ganadores
- **Descarga**: Link disponible en el perfil del usuario

#### Medallas Digitales
```
{
  "medalId": "medal_conquistador_001",
  "name": "Conquistador de Madrid",
  "rarity": "Legendaria",
  "unlockedAt": "2026-04-15",
  "displayable": true
}
```

#### Puntos de Experiencia (XP)
- **Base**: 100 XP por tesoro
- **Multiplicador**: 1.5x para tesoros raros
- **Bonificación**: +50 XP si es el primero en reclamar

### Sistema de Rareza

| Rareza | Color | XP | Probabilidad |
|--------|-------|-----|--------------|
| Común | Gris | 100 | 50% |
| Poco Común | Verde | 150 | 30% |
| Rara | Azul | 250 | 15% |
| Épica | Púrpura | 400 | 4% |
| Legendaria | Dorada | 1000 | 1% |

---

## Flujo Completo de Búsqueda

```
Usuario Camina → Radar Activa (50-100m)
                 ↓
            Interfaz Caliente/Frío
            Vibración Háptica
                 ↓
            Usuario se Acerca
            Colores Cambian (Azul → Rojo)
                 ↓
            < 10 metros: "Reclamar" Disponible
                 ↓
            Usuario Pulsa "Reclamar"
                 ↓
            Validación GPS (3-5s)
                 ↓
            ✓ Validado → Recompensa
            ✗ Fallido → Reintentar
                 ↓
            Medalla + XP + .STL (si aplica)
```

## Configuración Recomendada

| Parámetro | Valor | Notas |
|-----------|-------|-------|
| Radio de Activación | 75m | Puede ser 50-100m |
| Radio de Reclamación | 10m | Máximo para validar |
| Tiempo de Validación | 4s | 3-5 segundos |
| Intensidad Haptic | Media | Ajustable por usuario |
| Límite Reclamación | 3 intentos | Por tesoro, por día |

---

**Última actualización**: Abril 2026
