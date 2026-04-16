# El Consejo de Exploradores: Sistema de Hitos Comunitarios

## Descripción General

El Consejo de Exploradores es un sistema democrático donde la comunidad de LoneWalker propone, vota y cuida los Puntos de Interés (POI) del mapa. Transforma Madrid en una cartografía viva, constantemente actualizada por sus propios exploradores.

## 1. Propuesta de Hito

### Requisitos Previos para Proponer

Para poder proponer un hito, el usuario debe cumplir:

- **Exploración Mínima**: Haber explorado al menos el 10% de la ciudad
- **Proximidad Física**: Estar a menos de 50 metros del punto propuesto
- **Cuenta Verificada**: Registro confirmado por email
- **Sin Prohibiciones**: No estar baneado por spam o contenido inapropiado

### Proceso de Propuesta

#### 1.1 Iniciar Propuesta
```
Usuario camina → Pulsa botón "+" en mapa
    ↓
Selector de ubicación GPS
    ↓
Formulario de Hito
```

#### 1.2 Formulario de Propuesta
El usuario debe proporcionar:

```json
{
  "nombre": "Fuente del Ángel Caído",
  "categoria": "MONUMENTO",
  "descripcion": "Emblemática fuente de estilo Art Nouveau en el Retiro",
  "foto_principal": "imagen.jpg",
  "fotos_adicionales": ["imagen2.jpg", "imagen3.jpg"],
  "ubicacion": {
    "latitude": 40.4158,
    "longitude": -3.6878,
    "precision_metros": 25
  },
  "horario": {
    "abierto_24h": true
  },
  "accesibilidad": {
    "acceso_silla_ruedas": true,
    "aparcamiento": true
  },
  "etiquetas": ["MONUMENTO", "ARTE", "FOTOGÉNICO"]
}
```

#### 1.3 Validación de Contenido
Antes de publicar, el sistema valida:
- ✓ Foto tiene meta-datos GPS válidos
- ✓ Descripción sin palabras prohibidas
- ✓ Usuario está realmente en la ubicación
- ✓ No es un duplicado de hito existente

### Estados Iniciales del Hito

#### 🟣 Hito Fantasma (Propuesta)
```
Estado: DRAFT
Visibilidad: Solo para votantes de su zona (radio 500m)
Pestaña: "Hitos en Votación"
Duración: 14 días para alcanzar umbral
Icono: Hito semitransparente/gris pálido
```

#### 🟡 Hito Boceto (En Votación Activa)
```
Estado: VOTING
Visibilidad: Visible en pestaña especial
Votos Netos Actuales: Mostrado como "+X"
Comentarios: Abiertos
Tiempo Restante: Muestra días faltantes
Icono: Hito con signo de interrogación
```

#### 🟢 Hito Permanente (Aprobado)
```
Estado: APPROVED
Visibilidad: Mapa general, visible para todos
Votos: Mostrados como número
Foto: Destacada en perfil del creador
Duración: Permanente hasta recibir votos negativos
Icono: Hito de color sólido
```

#### ⚫ Hito Desactivado (Rechazado)
```
Estado: REJECTED
Visibilidad: Archivo histórico solo
Razón: Mostrada al creador
Votos Negativos: X superan a positivos
Duración: 30 días antes de eliminación permanente
Icono: Tachado
```

---

## 2. Sistema de Curación Social

### 2.1 Votación (Upvote/Downvote)

#### Mecánica de Votos

```
Votos Positivos (+)  →  "Esto existe y es correcto"
Votos Negativos (-)  →  "Esto no existe o es falso"
```

#### Cálculo de Puntuación Neta
```
Puntuación Neta = (Votos Positivos) - (Votos Negativos)
```

### 2.2 Umbral de Activación

#### Requisito para Aprobación
```
Umbral Mínimo: +20 votos positivos netos
Tiempo Máximo: 14 días desde la propuesta
Votantes Únicos: Contados solo una vez por usuario
```

#### Proceso de Aprobación
```
Hito en Votación (+20 votos)
    ↓
Sistema verifica automáticamente cada 1 hora
    ↓
Si cumple: Cambiar a APPROVED
    ↓
Notificar al creador: "¡Tu hito fue aprobado!"
    ↓
Mostrar en mapa para todos
    ↓
Creador gana puntos de "Cartógrafo"
```

### 2.3 Mecánica de Expulsión

#### Rechaza Automática por Votos Negativos
```
Si Votos Negativos > Votos Positivos:
    →  El hito regresa a estado DRAFT
    
Si un hito APPROVED recibe:
    (Votos Negativos > Votos Positivos + 10)
    →  Cambiar a REJECTED
    →  Desaparecer del mapa
    →  Notificar al creador
```

#### Ejemplos
```
Caso 1: Hito nuevo
Votos: +25 / -0 → APROBADO ✓

Caso 2: Hito nuevo
Votos: +15 / -5 → RECHAZADO (solo +10 netos)

Caso 3: Hito aprobado
Votos: +50 / -35 → SIGUE APROBADO (+15 netos > +10 umbral)

Caso 4: Hito aprobado que desaparece
Votos: +20 / -31 → RECHAZADO (el monumento ya no existe)
```

### 2.4 Voto Requerido: Comentario Obligatorio

#### Regla de Transparencia
**No se puede votar sin proporcionar feedback.**

Excepto casos muy específicos:
- Voto de usuario con nivel < 5: Requiere texto obligatorio
- Voto anónimo: Texto obligatorio
- Voto de baneado temporal: Rechazado

#### Estructura del Comentario

```json
{
  "vote_id": "vote-uuid",
  "user_id": "user-uuid",
  "hito_id": "hito-uuid",
  "voto": "+1",
  "comentario": "Confirmó, está en exactamente ese lugar",
  "evidencia": "FOTO_PROPIA | REFERENCIA_EXTERNA | CONOCIMIENTO_LOCAL",
  "timestamp": "2026-04-16T15:30:00Z",
  "es_reportado": false
}
```

#### Tipos de Evidencia
- **FOTO_PROPIA**: Usuario subió foto como evidencia
- **REFERENCIA_EXTERNA**: Link a Wikipedia, Google Maps, etc
- **CONOCIMIENTO_LOCAL**: Vive/trabaja cerca, lo conoce personalmente
- **REPORTAR_CONTENIDO**: Denuncia spam, ofensivo, duplicado

#### Comentarios Destacados
El sistema muestra:
- Comentarios con evidencia fotográfica
- Comentarios de usuarios verificados ("Local de Barrio")
- Comentarios más votados (+5 upvotes)
- Comentarios del creador del hito

### 2.5 Transparencia Total

#### Visualización de Votación
Al tocar un hito, aparece:

```
┌─────────────────────────────┐
│  Fuente del Ángel Caído    │
│  📍 Parque del Retiro       │
├─────────────────────────────┤
│  👍 +45  👎 -8              │
│  Puntuación Neta: +37       │
├─────────────────────────────┤
│  Cartógrafo: AlexWalker     │
│  Propuesto hace: 5 días     │
├─────────────────────────────┤
│  📝 Ver 12 comentarios      │
│    ├─ "Confirmado, hermoso" (+8)
│    ├─ "Foto de referencia"  (+3)
│    └─ "¿Sigue abierto?"     (+1)
├─────────────────────────────┤
│  [ 👍 Voto Positivo ]       │
│  [ 👎 Voto Negativo ]       │
│  [ 🚩 Reportar ]            │
└─────────────────────────────┘
```

#### Pestaña de Votación
Accesible desde **Mapa → Hitos en Votación**:

```
┌──────────────────────────────┐
│ Hitos en Votación (12)       │
├──────────────────────────────┤
│ 🟡 Fuente Nueva (Barrio ABC) │
│    +15 / -2 (Vota en 9 días) │
│                              │
│ 🟡 Monumento Restaurado      │
│    +8 / -1 (Vota en 11 días) │
│                              │
│ 🟡 Café Histórico (Centro)   │
│    +3 / -0 (Vota en 13 días) │
└──────────────────────────────┘
```

---

## 3. Gamificación de la Curación

### 3.1 Puntos de Reputación: Cartógrafo

#### Sistema de Reputación
```
Proponer hito:           +10 puntos
Hito aprobado:          +50 puntos
Hito rechazado:         -5 puntos
Voto positivo usado:    +1 punto
Voto útil (recibe +5):  +2 puntos
Comentario destacado:   +3 puntos
```

#### Niveles de Cartógrafo
```
Nivel 0: 0-50 puntos       "Explorador Novato"
Nivel 1: 50-150 puntos     "Cartógrafo Aprendiz"
Nivel 2: 150-400 puntos    "Cartógrafo Confirmado"
Nivel 3: 400-1000 puntos   "Cartógrafo Maestro"
Nivel 4: 1000+ puntos      "Guardián del Mapa"
```

#### Insignias Cartógrafo
```
🗺️ "Primer Hito" - Proponer tu primer hito
🎯 "Aprobación" - Tu primer hito aprobado
📸 "Fotógrafo" - 10 hitos con fotos excelentes
✅ "Verificador" - 50 votos positivos útiles
🏛️ "Monumentero" - 20 hitos aprobados
🌆 "Arquitecto de Madrid" - Hitos en todos los distritos
🎖️ "Guardián Supremo" - 1000 puntos de Cartógrafo
```

### 3.2 Prevención de Spam

#### Límites de Propuesta
```
Nuevos usuarios (< 10% exploración):
  - Máx 1 hito por semana
  - Máx 3 hitos activos simultáneamente

Usuarios normales (10-50% exploración):
  - Máx 2 hitos por semana
  - Máx 10 hitos activos simultáneamente

Cartógrafos confirmados (50%+ exploración):
  - Máx 5 hitos por semana
  - Sin límite de activos
```

#### Validación de Proximidad
```
Para proponer: Debe estar a < 50m del punto
Para votar positivo: Puede ser a cualquier distancia
Para votar negativo: Idealmente a < 500m (pero puede desde cualquier lugar)
```

#### Sistema de Penalización
```
1 hito rechazado:        Sin penalización
3 hitos rechazados:      -1 propuesta/semana
5 hitos rechazados:      Suspensión 7 días
10 hitos rechazados:     Suspensión permanente (Cartógrafo deshabilitado)
```

#### Detección de Spam
El sistema automático rechaza si:
- Propuesta duplicada (< 100m de hito existente)
- Foto con calidad muy baja
- Descripción con palabras prohibidas
- Usuario tiene 5+ propuestas en 1 hora
- Foto no tiene metadata GPS válida

---

## 4. Notas de Diseño para Implementación

### 4.1 Moderación de Contenido

#### Filtro Automático
```javascript
// Palabras prohibidas en comentarios
const bannedWords = [
  'ofensa_1', 'ofensa_2', ..., 'ofensa_n'
];

// Validar comentario
function validateComment(text) {
  const words = text.toLowerCase().split(' ');
  const hasBannedWords = words.some(w => bannedWords.includes(w));
  
  if (hasBannedWords) {
    return { valid: false, reason: 'Contenido inapropiado' };
  }
  return { valid: true };
}
```

#### Botón de Reporte
En cada hito y comentario aparece **🚩 Reportar** que permite:
- "Contenido ofensivo"
- "Spam"
- "Información falsa"
- "Ubicación incorrecta"
- "Duplicado"
- "Contenido inapropiado"

Reportes múltiples automáticamente elevan para revisión manual.

### 4.2 La "Guerra de Barrios": Feature Gamificada

Aunque compite de forma divertida, hay protecciones:

#### Rivalidad Sana
```
Sistema de "Distritos Rivales":
  - Chamberí vs Malasaña
  - Centro vs Salamanca
  - Retiro vs Usera
  
Los usuarios que completan distritos rivales
desbloquean medalla especial: "Paz Territorial"
```

#### Protección contra Brigadas de Voto
```
Detección automática:
- Si 50+ usuarios votan contra un hito en < 1 hora
  → Investigación manual
  → Posible invalidación de votos coordinados
  
Explicación al usuario:
"Los votos de 23 usuarios fueron identificados como
coordinados y fueron descartados para mantener 
la integridad del sistema"
```

### 4.3 Privacidad vs. Visibilidad

#### Identidad en Comentarios
**Se usa: Nombre de Usuario (Nick de Explorador)**

Ejemplos:
```
✓ AlexWalker: "Confirmado, acabo de verlo"
✓ MadrileñoViajero: "Fue aquí donde encontré un tesoro"
✓ ExploradorNocturno: "Monumento bellísimo al anochecer"

✗ Juan García: "Esto es mi barrio"
✗ maria.lopez@gmail.com: "Voto positivo"
```

#### Privacidad de Datos
- Los comentarios son públicos
- El nombre del usuario es visible
- La foto de perfil es visible
- La ubicación exacta del votante **NUNCA** se muestra
- El historial de votos individuales es público (ej: "Usuario X votó a este hito")

#### Excepción: Usuarios Baneados
Si un usuario es baneado, sus comentarios:
- Aparecen como "[Comentario de usuario baneado]"
- Sus votos son descontados

---

## 5. Integración con Otras Mecánicas

### 5.1 XP y Recompensas
```
Proponer hito aprobado:     +100 XP
Comentario destacado:       +50 XP
Medalla de Cartógrafo:      +500 XP única
```

### 5.2 Logros Especiales
```
🎖️ "Cartógrafo Diamante" - 100 hitos propuestos
🎖️ "Curador de Oro" - 500 votos útiles
🎖️ "Historiador de Madrid" - 50 comentarios con +10 votos
```

### 5.3 Interacción con Treasures
```
Si se coloca un Treasure cerca de un hito comunitario:
- +20% XP bonus para quien lo encuentre
- Medalla especial: "Tesoro en Hito Legendario"
```

---

## 6. Flujo Completo: De Propuesta a Aprobación

```
Usuario Camina
    ↓
Pulsa "Proponer Hito"
    ↓
Toma foto + rellena info
    ↓
Sistema valida contenido y ubicación
    ↓
Hito creado como DRAFT (Hito Fantasma)
    ↓
Visible en "Hitos en Votación" por 14 días
    ↓
Comunidad vota + comenta
    ↓
¿Alcanza +20 votos netos?
├─ SÍ → APROBADO
│   ├─ Visible en mapa general
│   ├─ Creador gana +50 puntos
│   └─ Foto destacada en perfil
│
└─ NO → RECHAZADO
    ├─ Desaparece del mapa
    ├─ Creador ve feedback
    ├─ 30 días en archivo
    └─ Puede volver a proponer
```

---

## 7. Configuración Recomendada

| Parámetro | Valor | Nota |
|-----------|-------|------|
| Umbral de Aprobación | +20 votos | Puede ajustarse por distrito |
| Duración Votación | 14 días | Después se auto-rechaza si no llega |
| Radio Propuesta | 50 metros | Usuario debe estar cerca |
| Radio Visibilidad Draft | 500 metros | Solo votantes cercanos ven |
| Límite Propuestas | Variable por nivel | Ver sección 3.2 |
| Penalización Rechazos | 3 = -1 límite | Escalada progresiva |
| Filtro Spam | Automático | Manual si múltiples reportes |

---

## 8. API Endpoints para Hitos

### Proponer Hito
```http
POST /api/v1/landmarks
Authorization: Bearer {token}
Content-Type: multipart/form-data

{
  "nombre": "...",
  "categoria": "MONUMENTO",
  "descripcion": "...",
  "latitude": 40.4158,
  "longitude": -3.6878,
  "fotos": [file1, file2]
}
```

### Votar en Hito
```http
POST /api/v1/landmarks/{id}/votes
Authorization: Bearer {token}
Content-Type: application/json

{
  "voto": 1,
  "comentario": "Confirmado, acabo de verlo"
}
```

### Listar Hitos en Votación
```http
GET /api/v1/landmarks?status=VOTING&lat=40.41&lng=-3.70&radius=5000
Authorization: Bearer {token}
```

### Detalles de Hito con Comentarios
```http
GET /api/v1/landmarks/{id}/with-comments
Authorization: Bearer {token}
```

---

**Última actualización**: Abril 2026
**Versión**: 1.0
