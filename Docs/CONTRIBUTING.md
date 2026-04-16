# Guía de Contribución - LoneWalker

¡Gracias por tu interés en contribuir a LoneWalker! Este documento proporciona orientación para contribuyentes.

## Antes de Empezar

Asegúrate de leer:
- [README.md](./README.md) - Descripción general del proyecto
- [CONDUCT.md](./CONDUCT.md) - Código de conducta (si existe)

## Cómo Contribuir

### Reportar Bugs

1. Verifica si el bug ya está reportado en [Issues](https://github.com/vrhino/lonewalker/issues)
2. Si no existe, crea un nuevo issue con:
   - Descripción clara del bug
   - Pasos para reproducir
   - Comportamiento esperado vs actual
   - Información del dispositivo/navegador
   - Logs si es aplicable

### Sugerir Mejoras

1. Usa [Discussions](https://github.com/vrhino/lonewalker/discussions) para ideas
2. Proporciona contexto de por qué la mejora es necesaria
3. Ejemplos de cómo beneficiaría a los usuarios

### Contribuir Código

#### 1. Fork y Clonar
```bash
git clone https://github.com/tu-usuario/lonewalker.git
cd lonewalker
git checkout -b feature/tu-feature
```

#### 2. Crear Rama
```bash
git checkout -b feature/descripcion-corta
# o para bugfix
git checkout -b fix/descripcion-corta
```

#### 3. Commits
Seguir formato convencional:
```
feat: agregar búsqueda de tesoros
fix: corregir cálculo de exploración
docs: actualizar README
style: formatear código
refactor: reorganizar módulo de mapas
test: agregar tests para radar
```

#### 4. Tests
- Agregar tests para nuevas features
- Asegurar que los tests existentes pasen
```bash
# Backend
npm run test
npm run test:coverage

# Frontend
flutter test
```

#### 5. Documentación
- Actualizar docs si cambias comportamiento
- Agregar docstrings a funciones públicas
- Actualizar CHANGELOG si es cambio visible

#### 6. Pull Request
1. Push a tu fork
2. Crear PR con descripción clara
3. Incluir:
   - Qué cambia y por qué
   - Screenshots/videos si es UI
   - Tests agregados
   - Checklist de verificación

### Estructura de PR

```markdown
## Descripción
Descripción clara de los cambios

## Tipo de Cambio
- [ ] Bugfix
- [ ] Nueva Feature
- [ ] Breaking Change
- [ ] Documentación

## Testing
- [ ] Agregué tests
- [ ] Tests existentes pasan
- [ ] Coverage > 80%

## Checklist
- [ ] Mi código sigue las guías
- [ ] He actualizado la documentación
- [ ] He agregado tests
- [ ] Los tests pasan localmente
```

## Guías de Estilo

### Código (Backend - Node.js)
```javascript
// ✓ Bien
const getUserExploration = async (userId) => {
  const exploration = await Exploration.findByUserId(userId);
  return exploration || null;
};

// ✗ Mal
const getUe = (uid) => Exploration.find({ uid });
```

### Código (Frontend - Dart/Flutter)
```dart
// ✓ Bien
class ExplorationBloc extends Bloc<ExplorationEvent, ExplorationState> {
  ExplorationBloc() : super(const ExplorationInitial());
  
  @override
  Stream<ExplorationState> mapEventToState(ExplorationEvent event) async* {
    // ...
  }
}

// ✗ Mal
class ExpBloc extends Bloc {
  // código sin documentación
}
```

### Documentación
```markdown
## Encabezados
Usa # para H1, ## para H2, etc.

- Listas con guion
1. Listas numeradas

**Bold** para énfasis
`code` para inline code

// Código en bloques
\`\`\`language
código aquí
\`\`\`
```

## Proceso de Review

1. **Verificación Automática**
   - CI/CD debe pasar
   - Linter sin errores
   - Tests > 80% coverage

2. **Review Manual**
   - Mantenedor revisa código
   - Verifica cumplimiento de guías
   - Solicita cambios si es necesario

3. **Merge**
   - Aprobación de al menos 1 mantenedor
   - Todos los checks pasan
   - Sin conflictos con main

## Áreas de Contribución

### Alta Prioridad
- [ ] Tests de integración backend
- [ ] Optimización de mapas offline
- [ ] Seguridad (auditoría)
- [ ] Rendimiento de exploraciones

### Media Prioridad
- [ ] Nuevas características UI
- [ ] Soporte de idiomas
- [ ] Animaciones
- [ ] Accesibilidad

### Baja Prioridad
- [ ] Temas personalizados
- [ ] Efectos visuales adicionales
- [ ] Música/Sonidos

## Desarrollo Local

Ver [Guía de Setup](./technical/setup.md) para instrucciones detalladas.

## Licencia

Al contribuir, aceptas que tu código será licenciado bajo la misma licencia del proyecto.

## Preguntas

Si tienes dudas:
1. Revisa [FAQs](./FAQ.md)
2. Abre una [Discussion](https://github.com/vrhino/lonewalker/discussions)
3. Contacta a los mantenedores

---

¡Gracias por contribuir a LoneWalker! 🗺️✨
