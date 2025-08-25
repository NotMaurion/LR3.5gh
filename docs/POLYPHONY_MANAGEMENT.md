# Gestión de Polifonía y Sensibilidad a la Velocidad - LiveRoots 3.5

## Problema Identificado

El motor de audio anterior tenía problemas de saturación y sonaba inorgánico debido a:

1. **Saturación del Buffer**: Demasiadas notas simultáneas causaban problemas de rendimiento
2. **Falta de Gestión de Polifonía**: No había límites en el número de voces activas
3. **Sonido Inorgánico**: Las notas no tenían una liberación natural (ADSR)
4. **Falta de Sensibilidad a la Velocidad**: Todas las notas sonaban con la misma intensidad

## Solución Implementada

### 1. **Gestión de Polifonía Inteligente**

#### Configuración por Preset
```json
"polyphony": {
  "enabled": true,
  "limit": 12,           // Límite de voces simultáneas
  "voiceStealing": true, // Habilitar robo de voz
  "stealOldest": true,   // Robar la voz más antigua
  "releaseTime": 0.1     // Tiempo de liberación en segundos
}
```

#### Límites por Preset
- **Meditation**: 12 voces (equilibrio entre riqueza y claridad)
- **Creative Flow**: 16 voces (máxima expresividad)
- **Deep Focus**: 8 voces (mínima distracción)

### 2. **Algoritmo de Robo de Voz**

#### Proceso de Robo de Voz
1. **Detección**: Cuando se alcanza el límite de polifonía
2. **Identificación**: Encuentra la voz más antigua por timestamp
3. **Liberación**: Aplica liberación ADSR natural (0.1s por defecto)
4. **Reemplazo**: Libera espacio para la nueva voz

```javascript
_stealOldestVoice() {
  // Encuentra la voz más antigua
  let oldestVoice = null;
  let oldestTime = Date.now();
  
  for (const [noteNumber, voice] of this.activeVoices.entries()) {
    if (voice.startTime < oldestTime) {
      oldestTime = voice.startTime;
      oldestVoice = { noteNumber, voice };
    }
  }
  
  // Aplica liberación ADSR
  if (oldestVoice) {
    this._releaseVoice(oldestVoice.noteNumber, settings.releaseTime);
  }
}
```

### 3. **Sensibilidad a la Velocidad**

#### Integración Completa
- **Parámetro velocity**: Aceptado en `playNote(noteNumber, velocity)`
- **Modulación de Volumen**: La velocidad afecta directamente el volumen final
- **Tracking de Velocidad**: Cada voz registra su velocidad original

```javascript
// En playNote()
const baseGain = this._clamp01(globalVol * zoneVol * this._clamp01(velocity));

// En _addVoice()
this.activeVoices.set(noteNumber, {
  source,
  startTime: Date.now(),
  velocity,        // Velocidad original
  noteName,
  voiceId
});
```

### 4. **Liberación ADSR Natural**

#### Proceso de Liberación
```javascript
_releaseVoice(noteNumber, releaseTime = 0.1) {
  const voice = this.activeVoices.get(noteNumber);
  if (!voice) return;
  
  const { source } = voice;
  
  // Aplica curva de liberación natural
  if (source._gainNode) {
    const currentGain = source._gainNode.gain.value;
    const releaseStart = this.audioCtx.currentTime;
    const releaseEnd = releaseStart + releaseTime;
    
    // Curva de liberación suave
    source._gainNode.gain.setValueAtTime(currentGain, releaseStart);
    source._gainNode.gain.linearRampToValueAtTime(0.001, releaseEnd);
    
    // Detiene la fuente después de la liberación
    source.stop(releaseEnd + 0.01);
  }
}
```

## Beneficios de la Nueva Implementación

### ✅ **Sonido Orgánico**
- Liberación ADSR natural en lugar de cortes abruptos
- Transiciones suaves entre voces
- Comportamiento similar a instrumentos reales

### ✅ **Rendimiento Optimizado**
- Límites de polifonía previenen saturación
- Robo de voz inteligente mantiene la musicalidad
- Limpieza automática de voces terminadas

### ✅ **Expresividad Musical**
- Sensibilidad completa a la velocidad MIDI
- Diferentes límites por tipo de preset
- Tracking detallado de cada voz

### ✅ **Configuración Flexible**
- Límites configurables por preset
- Tiempos de liberación personalizables
- Algoritmos de robo de voz configurables

## Monitoreo y Debugging

### Estadísticas de Polifonía
```javascript
getPolyphonyStats() {
  return {
    enabled: settings.enabled,
    limit: settings.limit,
    currentVoices: this.activeVoices.size,
    voiceStealing: settings.voiceStealing,
    activeVoices: [
      {
        noteNumber: 60,
        noteName: "C4",
        velocity: 0.8,
        voiceId: 1,
        age: 1500 // ms
      }
    ]
  };
}
```

### Logs de Debugging
```
AuraSonixEngine: Added voice 1 for note 60 (C4) at velocity 0.8
AuraSonixEngine: Polyphony limit reached (12/12), will steal voice
AuraSonixEngine: Stealing oldest voice (note 48, started at 2024-01-15T10:30:15.123Z)
AuraSonixEngine: Released voice for note 48 with 0.1s release
AuraSonixEngine: Removed voice 1 for note 60 (C4)
```

## Configuración Recomendada

### Para Presets de Meditación
```json
"polyphony": {
  "enabled": true,
  "limit": 12,
  "voiceStealing": true,
  "stealOldest": true,
  "releaseTime": 0.1
}
```

### Para Presets Creativos
```json
"polyphony": {
  "enabled": true,
  "limit": 16,
  "voiceStealing": true,
  "stealOldest": true,
  "releaseTime": 0.08
}
```

### Para Presets de Concentración
```json
"polyphony": {
  "enabled": true,
  "limit": 8,
  "voiceStealing": true,
  "stealOldest": true,
  "releaseTime": 0.12
}
```

## Integración con el Sistema Existente

### Compatibilidad
- ✅ Compatible con el sistema de optimizaciones de rendimiento
- ✅ Integrado con el sistema de efectos de audio
- ✅ Funciona con todos los presets existentes
- ✅ Mantiene la funcionalidad de voice stealing anterior

### Mejoras Adicionales
1. **Tracking de Voces**: Cada voz tiene un ID único y metadata completa
2. **Liberación Inteligente**: Aplica ADSR natural en lugar de cortes abruptos
3. **Monitoreo Avanzado**: Estadísticas detalladas de polifonía
4. **Configuración Granular**: Control fino por preset

## Próximas Mejoras

1. **Algoritmos de Robo de Voz**: Implementar diferentes estrategias (más suave, más agudo, etc.)
2. **Polifonía Dinámica**: Ajustar límites basado en el rendimiento del dispositivo
3. **Liberación por Velocidad**: Tiempos de liberación basados en la velocidad de la nota
4. **Priorización de Voces**: Dar prioridad a ciertas notas sobre otras
