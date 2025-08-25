# Verificación de Configuración del LAB - LiveRoots 3.5

## Objetivo

Verificar que el LAB pueda cargar y modificar correctamente todos los parámetros del `config.json`, especialmente los efectos de audio y la configuración de polifonía.

## Funcionalidades Implementadas

### 1. **Carga Automática de Configuración**

Cuando se abre el LAB, automáticamente carga:
- ✅ **Efectos de Audio** desde el engine
- ✅ **Configuración de Escalas** desde el engine  
- ✅ **Configuración de Zonas** desde el engine
- ✅ **Configuración de Polifonía** desde el engine

### 2. **Sincronización Bidireccional**

- ✅ **LAB → Engine**: Los cambios en el LAB se aplican inmediatamente al engine
- ✅ **Engine → LAB**: La configuración del engine se carga en el LAB al abrirlo
- ✅ **Config.json → Engine**: Los valores del archivo de configuración se aplican al cargar presets

## Verificación Paso a Paso

### **Paso 1: Verificar Carga de Configuración**

1. **Cargar un preset** en la aplicación principal
2. **Abrir el LAB** (botón "LAB" en la barra superior)
3. **Verificar que los valores coincidan** con el `config.json`:

```json
// Ejemplo para preset Meditation
{
  "defaultAudioEffects": {
    "reverb": { 
      "enabled": true, 
      "wet": 0.61,        // Debe aparecer como 61% en el LAB
      "roomSize": 0.90,   // Debe aparecer como 90% en el LAB
      "dampening": 0.80,  // Debe aparecer como 80% en el LAB
      "preDelay": 0.05    // Debe aparecer como 50ms en el LAB
    },
    "envelope": { 
      "enabled": true, 
      "attack": 0.10,     // Debe aparecer como 100ms en el LAB
      "decay": 0.20,      // Debe aparecer como 200ms en el LAB
      "sustain": 0.80,    // Debe aparecer como 80% en el LAB
      "release": 1.00     // Debe aparecer como 1000ms en el LAB
    },
    "polyphony": { 
      "enabled": true, 
      "limit": 12,        // Debe aparecer como 12 en el LAB
      "voiceStealing": true,
      "stealOldest": true,
      "releaseTime": 0.1  // Debe aparecer como 0.10s en el LAB
    }
  }
}
```

### **Paso 2: Verificar Modificación en Tiempo Real**

1. **Mover un slider** en el LAB (ej: Reverb Wet de 61% a 70%)
2. **Escuchar el cambio inmediato** en el sonido
3. **Verificar que el cambio persiste** al cerrar y abrir el LAB

### **Paso 3: Verificar Configuración de Polifonía**

1. **Ir a la sección "Polyphony"** en el panel de Audio
2. **Verificar que los valores coincidan**:
   - **Polyphony Limit**: 12 (Meditation), 16 (Creative Flow), 8 (Deep Focus)
   - **Voice Stealing**: Habilitado
   - **Steal Oldest**: Habilitado
   - **Release Time**: 0.10s (Meditation), 0.08s (Creative Flow), 0.12s (Deep Focus)

3. **Probar la funcionalidad**:
   - **Reducir el límite** a 4 voces
   - **Tocar muchas notas rápidamente**
   - **Verificar que se aplique voice stealing** (logs en consola)

### **Paso 4: Verificar Sensibilidad a la Velocidad**

1. **Ir a la sección "Randomness"** en el LAB
2. **Habilitar "Randomness"** y ajustar "Velocity Variation" a 0.3
3. **Tocar notas con diferentes velocidades** (si tienes un controlador MIDI)
4. **Verificar que las notas suenen con diferentes volúmenes**

## Logs de Verificación

### **Logs Esperados al Abrir el LAB**

```
AudioEffectsNotifier: received effects data from engine: {
  reverb: { enabled: true, wet: 0.61, dry: 0.39, roomSize: 0.90, dampening: 0.80, preDelay: 0.05 },
  envelope: { enabled: true, attack: 0.10, decay: 0.20, sustain: 0.80, release: 1.00 },
  polyphony: { enabled: true, limit: 12, voiceStealing: true, stealOldest: true, releaseTime: 0.1 }
}
AudioEffectsNotifier: loaded from engine - { reverb: {...}, envelope: {...}, polyphony: {...} }
```

### **Logs Esperados al Modificar Parámetros**

```
AudioEffectsNotifier: pushed to engine - { reverb: { wet: 0.70, ... } }
AuraSonixEngine: updateAudioEffects called with: { reverb: { wet: 0.70, ... } }
```

### **Logs de Polifonía**

```
AuraSonixEngine: Added voice 1 for note 60 (C4) at velocity 0.8
AuraSonixEngine: Polyphony limit reached (12/12), will steal voice
AuraSonixEngine: Stealing oldest voice (note 48, started at 2024-01-15T10:30:15.123Z)
AuraSonixEngine: Released voice for note 48 with 0.1s release
```

## Configuración por Preset

### **Preset Meditation**
```json
"polyphony": {
  "enabled": true,
  "limit": 12,
  "voiceStealing": true,
  "stealOldest": true,
  "releaseTime": 0.1
}
```

### **Preset Creative Flow**
```json
"polyphony": {
  "enabled": true,
  "limit": 16,
  "voiceStealing": true,
  "stealOldest": true,
  "releaseTime": 0.08
}
```

### **Preset Deep Focus**
```json
"polyphony": {
  "enabled": true,
  "limit": 8,
  "voiceStealing": true,
  "stealOldest": true,
  "releaseTime": 0.12
}
```

## Problemas Comunes y Soluciones

### **Problema: Los valores no coinciden**
**Solución**: Verificar que el `config.json` tenga los valores correctos y que no haya overrides en el engine.

### **Problema: Los cambios no se aplican**
**Solución**: Verificar que el método `_pushToEngine()` se esté llamando correctamente.

### **Problema: La polifonía no funciona**
**Solución**: Verificar que la configuración de polifonía esté habilitada y que los límites sean apropiados.

### **Problema: No se cargan los efectos al abrir el LAB**
**Solución**: Verificar que el método `loadFromEngine()` se esté llamando en `lab_screen.dart`.

## Métodos de Verificación Adicionales

### **Verificar desde la Consola del Navegador**

```javascript
// Obtener configuración actual del engine
const engine = window.auraSonixEngine;
const effects = engine.getCurrentAudioEffects();
console.log('Current effects:', effects);

// Obtener estadísticas de polifonía
const polyphony = engine.getPolyphonyStats();
console.log('Polyphony stats:', polyphony);
```

### **Verificar desde Flutter**

```dart
// Obtener estado actual de efectos
final effects = ref.read(audioEffectsProvider);
print('Current effects: ${effects.toMap()}');

// Obtener estadísticas de polifonía
final engine = ref.read(audioEngineProvider);
final stats = await engine.getPolyphonyStats();
print('Polyphony stats: $stats');
```

## Conclusión

El LAB ahora tiene capacidad completa para:
- ✅ **Cargar** todos los parámetros del `config.json`
- ✅ **Modificar** todos los parámetros en tiempo real
- ✅ **Aplicar** los cambios inmediatamente al engine
- ✅ **Mantener** la sincronización entre UI y engine
- ✅ **Configurar** polifonía avanzada con voice stealing

Esto convierte al LAB en un verdadero lugar de fine-tuning para los sonidos, permitiendo ajustes precisos y en tiempo real de todos los parámetros de audio.
