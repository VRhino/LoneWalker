# Sistema Social y Ranking

## Descripción General

El sistema social de LoneWalker crea comunidad y competencia sana entre exploradores. Los usuarios pueden comparar su progreso, compartir logros y participar en desafíos colaborativos.

## 1. Ranking de Exploradores

### Estructura del Ranking

#### Clasificación Principal: Porcentaje de Madrid Descubierto
```
Posición | Usuario | Exploración | Tesoros | XP Total | Medallas
1️⃣       | AlexWalker | 87.3% | 12 | 15,420 | 8
2️⃣       | MadrileñoViajero | 84.1% | 10 | 14,150 | 6
3️⃣       | ExploradorNocturno | 81.5% | 9 | 12,890 | 5
...
```

#### Métricas de Ranking
1. **Exploración %**: Porcentaje total de ciudad descubierto (40% peso)
2. **Tesoros Encontrados**: Cantidad de tesoros reclamados (30% peso)
3. **Puntos XP**: Total de experiencia acumulada (20% peso)
4. **Medallas Obtenidas**: Logros especiales desbloqueados (10% peso)

### Cálculo del Ranking
```
Puntuación Final = (Exploración % × 0.4) + 
                   (Tesoros Encontrados × 0.3) + 
                   (XP Total / 1000 × 0.2) + 
                   (Medallas × 0.1)
```

### Rangos y Títulos
```
0-20%    → Vagabundo
20-40%   → Caminante
40-60%   → Explorador
60-75%   → Pionero
75-85%   → Conquistador
85-95%   → Leyenda
95-100%  → Maestro de Madrid
```

## 2. Ranking Temático

Además del ranking general, hay clasificaciones especializadas:

### Ranking por Distrito
Cada distrito tiene su propio ranking local:
- **Centro Histórico Champion**
- **Barrio de Salamanca Master**
- **Retiro Explorer**
- etc.

### Ranking Semanal
Competencia dinámica basada en actividad reciente:
- Cambios dinámicos cada semana
- Bonificación 2x para actividad reciente (últimos 7 días)
- Reinicio cada lunes a las 00:00 UTC

### Ranking de Tesoreros
Específico para buscadores de tesoros:
- Cantidad de tesoros encontrados
- Rareza promedio de tesoros
- Racha actual sin fallos

## 3. Visibilidad y Perfiles

### Perfil Público
Los usuarios pueden mostrar:
- Avatar personalizado
- Nombre de usuario
- Porcentaje de exploración
- Medallas desbloqueadas
- Logros recientes
- Estadísticas generales

### Perfil Privado
Modo "Local Only" donde:
- No aparece en rankings públicos
- Datos no compartidos con otros usuarios
- Estadísticas personales solo visibles localmente
- Sincronización continúa con servidor (no participa en ranking)

### Datos Privados
Siempre privados, independientemente del modo:
- Historial de ubicación detallado
- Rutas exactas caminadas
- Horarios de actividad
- Datos de contacto

## 4. Control de Usuario: Privacidad

### Opciones de Privacidad

#### Modo Público (Por Defecto)
```
✓ Visible en rankings globales
✓ Perfil visible a otros usuarios
✓ Amigos pueden ver estadísticas
✗ No se muestran ubicaciones exactas (solo porcentaje exploración)
```

#### Modo Privado (Local Only)
```
✗ No aparece en rankings
✗ Perfil invisible a otros usuarios
✗ Amigos no ven estadísticas
✓ Datos almacenados localmente y en servidor privado
```

### Configuración Granular
Los usuarios pueden personalizar qué mostrar:

- [ ] Mostrar nombre en rankings
- [ ] Mostrar porcentaje exploración
- [ ] Mostrar tesoros encontrados
- [ ] Mostrar medallas
- [ ] Permitir que amigos vean actividad reciente
- [ ] Mostrarse como "Online" cuando activo

### Amigos y Seguimiento

#### Sistema de Amigos
- Agregar amigos manualmente
- Invitaciones de amistad
- Bloqueo de usuarios

#### Privacidad de Amigos
- Ver progreso de amigos solo si aceptan
- Notificaciones de logros de amigos (opcional)
- Competencia amistosa en rankings privados

## 5. Logros Sociales

### Logros Colaborativos
```
🏆 "Expedición en Grupo"
   Completar juntos 5 desafíos con amigos
   Recompensa: Medalla + 500 XP

🏆 "Influencer de Barrio"
   5 amigos completan el mismo distrito
   Recompensa: Medalla especial + 300 XP

🏆 "Maestro Social"
   100 usuarios tienen tu perfil visitado
   Recompensa: Título exclusivo + 250 XP
```

### Desafíos de Comunidad
- **Objetivo Semanal**: Explorar un distrito específico juntos
- **Tesoro Compartido**: Busca de tesoro multi-usuario con pistas colaborativas
- **Maratón Mensual**: Mayor exploración en el mes

## 6. Notificaciones Sociales

### Tipos de Notificaciones
- ✓ Amigo desbloqueó un logro
- ✓ Alguien sobrepasó tu ranking
- ✓ Nuevo desafío disponible en tu área
- ✓ Amigo está explorando cerca de ti
- ✗ A menos que lo permitas: Ubicación exacta de amigos

### Control de Notificaciones
Cada tipo es desactivable individualmente en Configuración

## Seguridad y Cumplimiento

### Regulación GDPR
- Consentimiento explícito para públicos datos
- Derecho a la supresión ("derecho al olvido")
- Portabilidad de datos bajo demanda
- Transparencia en uso de datos

### Protección de Menores
- Usuarios < 13 años: Solo modo privado
- Usuarios 13-18: Privacidad reforzada (solo amigos)
- Parental controls disponibles

---

## Flujo de Privacidad

```
Crear Cuenta
    ↓
Elegir Modo (Público/Privado)
    ↓
Configurar Privacidad Granular
    ↓
┌─── Público ───┐      ┌─── Privado ───┐
│ Ranking      │      │ Local Only    │
│ Visible      │      │ No Rankings   │
│ Amigos ven   │      │ Privado Total │
└──────────────┘      └───────────────┘
```

---

## Estadísticas Compartibles

Los usuarios pueden compartir (si está en modo público):
- Logro de conquista de distrito
- Primer tesoro encontrado
- Nueva medalla desbloqueada
- Hito de exploración (ej: 50%, 75%, 100%)

**Formato compartible**: Captura de pantalla con código QR para perfil del usuario

---

**Última actualización**: Abril 2026
