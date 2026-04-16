# Mecánicas de Exploración y Mapa

## Descripción General

Las mecánicas de exploración son el corazón de LoneWalker. Transforman un mapa ordinario en una aventura de descubrimiento progresivo.

## 1. Fog of War (Niebla de Guerra)

### Concepto
La niebla de guerra es una capa visual semitransparente que cubre las áreas no exploradas del mapa. Al caminar, el usuario despeja gradualmente esta niebla, revelando detalles del mapa a su alrededor.

### Funcionalidad
- **Radio de Despeje**: Aproximadamente 50-100 metros alrededor de la posición GPS actual
- **Suavizado Visual**: El borde de la niebla tiene un gradiente suave para mejor experiencia visual
- **Actualización en Tiempo Real**: La niebla se actualiza según se mueve el usuario
- **Persistencia**: El estado despejado se guarda localmente y en el servidor

### Beneficios
- Incentiva al usuario a explorar nuevas áreas
- Crea sentido de descubrimiento y logro
- Proporciona objetivo visual claro

## 2. Degradación Dinámica

### Concepto
Las áreas exploradas no permanecen reveladas indefinidamente. Con el tiempo, la niebla vuelve a cubrir las zonas si no se visitan regularmente.

### Mecanismo de Degradación
- **Período de Degradación**: 1 semana (configurable)
- **Velocidad de Re-cubrimiento**: Gradual, entre 7-10 días
- **Factor de Distancia**: Áreas más lejanas se re-cubren más rápido

### Configuración
```
Degradation Period: 7 days
Degradation Speed: 10-15% por día
Minimum Visibility: Mantiene visible el 20% de la zona más explorada
```

### Objetivo
- Fomenta la re-exploración periódica de la ciudad
- Evita que el mapa se complete una sola vez y se abandone
- Mantiene el juego fresco y desafiante

## 3. Zona de Maestría

### Definición
Alcanzar el 100% de exploración de un distrito específico (basado en cuadrículas o sectores municipales).

### Logro de Conquistador
Al completar la maestría de un distrito:

#### Recompensas
- **Medalla Digital**: Icono único y exclusivo en el perfil
- **Bonificación de Puntos**: 5,000 XP + bonificación especial
- **Permanencia**: La niebla desaparece permanentemente de esa zona
- **Entrada en Muro de Fama**: El nombre aparece en el ranking regional

#### Requisitos
1. Descubrir al menos el 95% del distrito
2. Completar al menos 3 desafíos ubicados en el distrito
3. Encontrar al menos 1 tesoro en la zona

### Niveles de Maestría
- **Bronce**: 50% exploración
- **Plata**: 75% exploración
- **Oro**: 95% exploración
- **Platino**: 100% exploración + Desafíos completados

## 4. Modo Offline

### Funcionalidad
Permite a los usuarios explorar sin conexión a internet continua.

### Características
- **Cacheo de Mapas**: Descarga automática de áreas alrededor del usuario
- **Almacenamiento Local**: Registro local de coordenadas y exploración
- **Sincronización**: Envío automático de datos cuando se recupera conexión
- **Indicador de Estado**: Muestra si está en modo online/offline

### Implementación
```
Cached Tile Size: 100MB máximo
Cache Expiration: 30 días
Sync Strategy: Cola automática de pendientes
```

### Casos de Uso
- Exploración en zonas con conexión intermitente
- Viajes largos sin cobertura
- Conservación de datos móviles

---

## Flujo de Experiencia

```
Inicio → Camina → Niebla se despeja → Explora → Re-visita después
         ↓         ↓                   ↓           ↓
    GPS activo  Niebla visual   Puntos XP    Degradación inicia
              Actualización    Medallas      Re-descubrimiento
              en tiempo real
```

## Configuración Recomendada

| Parámetro | Valor | Ajustable |
|-----------|-------|-----------|
| Radio de Despeje | 75m | Sí |
| Período de Degradación | 7 días | Sí |
| Área Mínima Visible | 20% | No |
| Velocidad de Re-cubrimiento | 10-15% / día | Sí |

---

**Última actualización**: Abril 2026
