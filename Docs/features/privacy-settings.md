# Configuración de Privacidad y Seguridad

## Descripción General

La privacidad y seguridad son fundamentales en LoneWalker. Este documento detalla todas las opciones disponibles para proteger los datos del usuario.

## 1. Permisos Requeridos

### Permisos Necesarios

#### 1.1 Ubicación (GPS)
- **Razón**: Determinar posición del usuario para exploración
- **Tipo**: "Always" durante uso activo
- **Privacidad**: Solo se almacena posición aproximada (precisión GPS reducida a 50m internamente)
- **Usuario puede**:
  - Denegar (app no funcionará)
  - Permitir solo mientras usa la app
  - Permitir siempre (para modo offline)

#### 1.2 Cámara
- **Razón**: Foto de perfil, captura de tesoro encontrado
- **Tipo**: Bajo demanda del usuario
- **Privacidad**: Las imágenes se comprimen y se carga metadata
- **Usuario puede**:
  - Usar cámara
  - Usar galería
  - Denegar (usará avatar genérico)

#### 1.3 Contactos
- **Razón**: Invitar amigos fácilmente
- **Tipo**: Lectura de lista de contactos
- **Privacidad**: No se envían contactos al servidor
- **Usuario puede**:
  - Permitir acceso
  - Denegar (buscar amigos manualmente)

#### 1.4 Notificaciones
- **Razón**: Alertas de tesoros, amigos, logros
- **Tipo**: Notificaciones push
- **Usuario puede**:
  - Permitir todas
  - Permitir solo algunas categorías
  - Denegar completamente

#### 1.5 Almacenamiento
- **Razón**: Cacheo de mapas, datos locales
- **Tipo**: Lectura/escritura de almacenamiento externo
- **Usuario puede**:
  - Permitir (necesario para modo offline)
  - Denegar (modo online only)

## 2. Recopilación de Datos

### Datos Recopilados

```
Nivel 1 - ESENCIAL (Siempre recopilado)
├── User ID
├── Nombre de usuario
├── Email
├── Exploración % del usuario
├── Medallas desbloqueadas
└── Rango en ranking

Nivel 2 - FUNCIONAL (Recopilado si está activo en app)
├── Posición GPS (precisión reducida a 50m)
├── Velocidad de movimiento
├── Distancia caminada
├── Tesoros reclamados
├── Rutas exploratorias (agregadas)
└── Horas de actividad

Nivel 3 - ANALÍTICA (Recopilado si permite)
├── Interacciones en UI
├── Errores y crashes
├── Versión del SO
├── Modelo del dispositivo
├── Duración de sesiones
└── Features más usados

Nivel 4 - MARKETING (Recopilado si consiente)
├── Email para newsletter
├── Preferencias de contenido
├── Feedback voluntario
└── Participación en encuestas
```

### Consentimiento para Cada Nivel

En primer inicio:
1. Presentar cada nivel de recopilación
2. Explicar claramente qué se usa para qué
3. Obtener consentimiento explícito
4. Permitir cambios en Configuración → Privacidad

## 3. Almacenamiento de Datos

### Cifrado

#### En Tránsito
- Conexión HTTPS obligatoria
- TLS 1.3 mínimo
- Certificados SSL verificados

#### En Reposo
- Base de datos: AES-256
- Contraseñas: bcrypt (salt + hash)
- Tokens de sesión: Encriptados

### Retención de Datos

| Tipo de Dato | Retención | Nota |
|--------------|-----------|------|
| Perfil de usuario | Indefinido | Hasta eliminación de cuenta |
| Exploración mapa | Indefinido | Histórico completo |
| Tesoros encontrados | Indefinido | Registro permanente |
| Ubicación detallada | 30 días | Luego se agrega en bloques |
| Logs de acceso | 90 días | Para auditoría de seguridad |
| Datos analíticos | 1 año | Luego se descarta |
| Contactos invite | 7 días | Se elimina después de invitar |

## 4. Modo Privado (Local Only)

### Activación
Configuración → Privacidad → "Modo Local Only"

### Características

#### Lo que CAMBIA en Modo Local
```
Desactivado:
✗ Ranking público
✗ Perfil visible
✗ Compartir logros
✗ Datos en servidor público
✗ Amigos ven actividad

Activado (pero funciona):
✓ Exploración local
✓ Tesoros funcionan igual
✓ Medallas se ganan igual
✓ Datos sincronizados privadamente
```

#### Almacenamiento Local en Modo Privado
- Todos los datos se almacenan en dispositivo
- Base de datos SQLite encriptada
- Sincronización de servidor-cliente es privada
- Nunca se comparte con otros usuarios

### Cambiar de Modo
- Cambio puede ocurrir en cualquier momento
- Si cambias de Privado a Público: historial se hace visible
- Si cambias de Público a Privado: datos se hacen privados (permanentemente)

## 5. Eliminación de Datos

### Solicitud de Eliminación

#### Opción 1: Borrado Parcial
"Configuración → Privacidad → Limpiar Datos Personales"
- Elimina: Foto, bio, nombre mostrado
- Mantiene: Medallas, logros (anónimos)
- Resultado: Perfil aparece como "Explorador Anónimo"

#### Opción 2: Borrado Completo
"Configuración → Cuenta → Eliminar Cuenta Permanentemente"
- Tiempo para confirmación: 30 días
- Durante esos días: Cuenta desactivada pero recuperable
- Después de 30 días: Eliminación permanente de todo

### Qué se Elimina en Borrado Completo
```
SE ELIMINA:
✗ Perfil de usuario
✗ Email y credenciales
✗ Datos de ubicación
✗ Historiales de exploración
✗ Tesoros encontrados
✗ Medallas y logros
✗ Amigos y relaciones

SE MANTIENE (Anónimo):
✓ Estadísticas agregadas ("5000 tesoros encontrados en Madrid")
✓ Mapa general de exploración (sin atribuir a usuario)
```

## 6. Exportación de Datos (GDPR)

### Solicitar Portabilidad de Datos

"Configuración → Privacidad → Solicitar Mi Información"

### Formato de Exportación
- **Formato**: JSON + CSV
- **Contenido**: 
  - Perfil completo
  - Historiales de exploración
  - Tesoros encontrados
  - Medallas ganadas
  - Rutas (puntos GPS)
  - Mensajes / comentarios
- **Entrega**: Email con enlace de descarga (7 días válido)
- **Tamaño típico**: 5-50 MB

## 7. Seguridad de Cuenta

### Contraseña

#### Requisitos
- Mínimo 8 caracteres
- Números, mayúsculas, minúsculas recomendadas
- No puede ser igual a las últimas 5 contraseñas

#### Cambio de Contraseña
- Requerida cada 90 días (aviso)
- Opción manual en cualquier momento
- Se cierra sesión en otros dispositivos después de cambio

### Autenticación de Dos Factores (2FA)

#### Opciones
1. **Email**: Código enviado a email registrado
2. **SMS**: Código por SMS (si proporciona teléfono)
3. **Autenticador**: App como Google Authenticator

#### Activación
"Configuración → Seguridad → Habilitar 2FA"

### Sesiones Activas

Ver y cerrar sesiones:
- "Configuración → Seguridad → Dispositivos"
- Lista de dispositivos con:
  - Nombre del dispositivo
  - Ubicación aproximada
  - Última actividad
  - Botón "Cerrar sesión remota"

## 8. Privacidad de Amigos

### Control de Amistad

#### Solicitud de Amistad
- Usuario A envía solicitud a Usuario B
- Usuario B acepta/rechaza
- Si acepta: El otro puede ver:
  - Porcentaje exploración (si permite)
  - Medallas desbloqueadas
  - Logros recientes
  - Actividad general (no ubicación exacta)

#### Bloquear Usuario
- "Perfil del usuario → ⋮ → Bloquear"
- Bloqueado no puede:
  - Ver tu perfil
  - Enviar solicitud de amistad
  - Ver tu actividad
  - Mentarte en comentarios

## 9. Reportes de Privacidad

### Generar Reporte de Privacidad

"Configuración → Privacidad → Generar Reporte"

Muestra:
- Qué datos tienes almacenados
- Dónde se almacena (local vs servidor)
- Con quién se comparte
- Cuándo fue el último acceso

### Auditoría de Consentimientos
- Ver todos los consentimientos dados
- Revocar consentimientos en cualquier momento
- Re-consentir si es necesario

## 10. Conformidad Legal

### GDPR (Unión Europea)
- ✓ Derecho al acceso
- ✓ Derecho a la corrección
- ✓ Derecho al olvido
- ✓ Derecho a la portabilidad
- ✓ Derecho a objetar
- ✓ Derecho a no automatización (profiling)

### CCPA (California, USA)
- ✓ Derecho a conocer
- ✓ Derecho a borrar
- ✓ Derecho a opt-out de venta
- ✓ Derecho a no discriminación

### LGPD (Brasil)
- ✓ Consentimiento explícito
- ✓ Derecho al acceso
- ✓ Derecho a la corrección
- ✓ Derecho a la eliminación

---

## Flujo de Configuración de Privacidad

```
Primer Inicio
    ↓
┌─────────────────────────────────┐
│ Consentimiento de Niveles       │
│ 1. Esencial (obligatorio)       │
│ 2. Funcional (recomendado)      │
│ 3. Analítica (opcional)         │
│ 4. Marketing (opcional)         │
└─────────────────────────────────┘
    ↓
Seleccionar Modo
│
├─→ Público: Visible en rankings
└─→ Privado: Local only
    ↓
En Cualquier Momento
    ↓
Configuración → Privacidad
│
├─→ Cambiar permisos
├─→ Ver datos almacenados
├─→ Cambiar modo
├─→ Exportar datos
└─→ Eliminar cuenta
```

---

**Última actualización**: Abril 2026
**Versión de Política**: 2.1
