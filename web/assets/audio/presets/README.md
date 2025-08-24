# LiveRoots Audio Presets

Este directorio contiene todos los presets de audio para LiveRoots, cada uno con su configuración específica y archivos de audio.

## 📁 Estructura de Directorios

```
web/assets/audio/presets/
├── Deep-Focus/
│   ├── config.json
│   ├── bass.wav
│   ├── mid.wav
│   ├── high.wav
│   └── tex.wav
├── Creative-Flow/
│   ├── config.json
│   ├── bass.wav
│   ├── mid.wav
│   ├── high.wav
│   └── tex.wav
├── Relaxation/
│   ├── config.json
│   ├── bass.wav
│   ├── mid.wav
│   ├── high.wav
│   └── tex.wav
├── Night-Drive/
│   ├── config.json
│   ├── bass.wav
│   ├── mid.wav
│   ├── high.wav
│   └── tex.wav
├── Meditation/
│   ├── config.json
│   ├── bass.wav
│   ├── mid.wav
│   ├── high.wav
│   └── tex.wav
├── Study/
│   ├── config.json
│   ├── bass.wav
│   ├── mid.wav
│   ├── high.wav
│   └── tex.wav
└── Workout/
    ├── config.json
    ├── bass.wav
    ├── mid.wav
    ├── high.wav
    └── tex.wav
```

## 🎵 Presets Disponibles

### 1. **Deep-Focus** 🧠
- **Categoría**: Productividad
- **Uso**: Concentración profunda y trabajo intelectual
- **Características**: Sonidos espaciales y envolventes
- **Energía**: Media-Baja
- **Duración recomendada**: 30-120 minutos

### 2. **Creative-Flow** 🎨
- **Categoría**: Creatividad
- **Uso**: Inspiración y flujo artístico
- **Características**: Sonidos dinámicos y expresivos
- **Energía**: Media-Alta
- **Duración recomendada**: 15-90 minutos

### 3. **Relaxation** 😌
- **Categoría**: Bienestar
- **Uso**: Relajación profunda y reducción del estrés
- **Características**: Sonidos suaves y envolventes
- **Energía**: Baja
- **Duración recomendada**: 20-60 minutos

### 4. **Night-Drive** 🌙
- **Categoría**: Atmosférico
- **Uso**: Viajes nocturnos y contemplación
- **Características**: Sonidos cinematográficos y atmosféricos
- **Energía**: Media-Baja
- **Duración recomendada**: 30-120 minutos

### 5. **Meditation** 🧘‍♀️
- **Categoría**: Bienestar
- **Uso**: Meditación profunda y mindfulness
- **Características**: Sonidos minimalistas y zen
- **Energía**: Muy Baja
- **Duración recomendada**: 15-45 minutos

### 6. **Study** 📚
- **Categoría**: Productividad
- **Uso**: Sesiones de estudio intensivo
- **Características**: Sonidos estructurados y enfocados
- **Energía**: Media
- **Duración recomendada**: 45-120 minutos

### 7. **Workout** 💪
- **Categoría**: Fitness
- **Uso**: Entrenamientos intensos y motivación
- **Características**: Sonidos energéticos y rítmicos
- **Energía**: Muy Alta
- **Duración recomendada**: 20-60 minutos

## 📋 Formato Estándar de config.json

Todos los presets siguen el mismo formato estándar:

```json
{
  "metadata": {
    "name": "Nombre del Preset",
    "description": "Descripción detallada del preset",
    "version": "1.0.0",
    "author": "LiveRoots",
    "category": "Categoría",
    "tags": ["tag1", "tag2", "tag3"]
  },
  "audioFiles": {
    "bass": "bass.wav",
    "mid": "mid.wav",
    "high": "high.wav",
    "tex": "tex.wav"
  },
  "defaultZones": [
    {
      "name": "Bass",
      "minNote": 21,
      "maxNote": 43,
      "baseNote": "C2",
      "volume": 0.7,
      "probability": 0.8,
      "description": "Descripción de la zona"
    }
  ],
  "defaultScaleFilter": {
    "enabled": true,
    "root": "C",
    "mode": "pentatonic_major",
    "minOctave": 2,
    "maxOctave": 6,
    "description": "Descripción del filtro de escala"
  },
  "defaultAudioEffects": {
    "reverb": {
      "enabled": true,
      "wet": 0.8,
      "dry": 0.2,
      "roomSize": 0.95,
      "dampening": 0.8,
      "preDelay": 0.05,
      "description": "Descripción del reverb"
    },
    "filter": {
      "enabled": false,
      "cutoff": 2000.0,
      "resonance": 0.0,
      "type": "lpf",
      "description": "Descripción del filtro"
    },
    "envelope": {
      "enabled": true,
      "attack": 0.2,
      "decay": 0.3,
      "sustain": 0.8,
      "release": 1.5,
      "description": "Descripción del envelope"
    },
    "sustain": {
      "enabled": true,
      "duration": 4.0,
      "level": 0.9,
      "infinite": false,
      "description": "Descripción del sustain"
    },
    "globalVolume": 1.2,
    "audioQuality": "High"
  },
  "defaultMidiRules": {
    "velocityMapping": {
      "enabled": true,
      "minVelocity": 0.3,
      "maxVelocity": 1.0,
      "curve": "linear",
      "description": "Descripción del mapeo de velocidad"
    },
    "noteTransformation": {
      "enabled": false,
      "transpose": 0,
      "octaveShift": 0,
      "harmonization": "none",
      "description": "Descripción de la transformación"
    },
    "arpeggiator": {
      "enabled": false,
      "pattern": "up",
      "rate": 0.5,
      "octaves": 1,
      "description": "Descripción del arpeggiator"
    },
    "quantization": {
      "enabled": false,
      "grid": "1/4",
      "strength": 0.5,
      "description": "Descripción de la cuantización"
    },
    "randomness": {
      "enabled": false,
      "amount": 0.1,
      "type": "note",
      "description": "Descripción de la aleatoriedad"
    },
    "simultaneousNotes": {
      "enabled": true,
      "maxNotes": 8,
      "voiceStealing": true,
      "description": "Descripción de las notas simultáneas"
    }
  },
  "presetSpecifics": {
    "intendedUse": "Uso específico del preset",
    "mood": "Estado de ánimo",
    "energyLevel": "Nivel de energía",
    "complexity": "Complejidad",
    "recommendedDuration": "Duración recomendada"
  }
}
```

## 🎛️ Parámetros de Audio

### **Zonas (Zones)**
- **Bass**: Frecuencias bajas (MIDI 21-43)
- **Mid**: Frecuencias medias (MIDI 44-67)
- **High**: Frecuencias altas (MIDI 68-87)
- **Tex**: Textura que cubre todo el rango (MIDI 21-87)

### **Filtros de Escala**
- **Chromatic**: Todas las notas disponibles
- **Pentatonic Major**: Escala pentatónica mayor
- **Pentatonic Minor**: Escala pentatónica menor
- **Major**: Escala mayor
- **Minor**: Escala menor
- **Dorian**: Escala dórica

### **Efectos de Audio**
- **Reverb**: Espacialidad y ambiente
- **Filter**: Filtrado de frecuencias
- **Envelope**: Forma de las notas (ADSR)
- **Sustain**: Duración de las notas
- **Global Volume**: Volumen general

### **Reglas MIDI**
- **Velocity Mapping**: Mapeo de velocidad
- **Note Transformation**: Transformación de notas
- **Arpeggiator**: Arpegiación automática
- **Quantization**: Cuantización rítmica
- **Randomness**: Aleatoriedad
- **Simultaneous Notes**: Notas simultáneas

## 📁 Archivos de Audio

### **Recomendaciones de Formato**
- **Formato**: WAV (PCM)
- **Sample Rate**: 44.1kHz o 48kHz
- **Bit Depth**: 16-bit o 24-bit
- **Canales**: Mono o Stereo
- **Duración**: 5-15 segundos por archivo

### **Nombres de Archivos**
- `bass.wav` - Frecuencias bajas
- `mid.wav` - Frecuencias medias
- `high.wav` - Frecuencias altas
- `tex.wav` - Textura general

### **Características por Capa**
- **Bass**: Sonidos profundos y fundamentales
- **Mid**: Melodías principales y armonías
- **High**: Detalles y texturas brillantes
- **Tex**: Ambiente y textura envolvente

## 🔧 Compatibilidad

### **Navegadores Web**
- Chrome 66+
- Firefox 60+
- Safari 11.1+
- Edge 79+

### **Dispositivos Móviles**
- iOS 12+
- Android 8+
- WebView compatible

### **Limitaciones**
- Los archivos WAV deben ser < 10MB cada uno
- El total de archivos por preset debe ser < 40MB
- Se recomienda comprimir archivos grandes

## 🚀 Agregando Nuevos Presets

1. **Crear carpeta** con el nombre del preset
2. **Agregar archivos WAV** (bass.wav, mid.wav, high.wav, tex.wav)
3. **Crear config.json** siguiendo el formato estándar
4. **Actualizar PRESET_CONFIG** en `aurasonix_engine.js`
5. **Probar** el preset en la aplicación

## 📝 Notas de Desarrollo

- Los presets se cargan dinámicamente desde `config.json`
- Si no se encuentra `config.json`, se usan valores por defecto
- Los efectos de audio se aplican en tiempo real
- Las configuraciones se pueden modificar desde el Lab
- Los cambios se guardan automáticamente en el navegador
