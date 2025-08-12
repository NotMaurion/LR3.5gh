MCP V3: Live Roots AuraSonix Engine
Nombre del Protocolo: VibeFlow (v3.3)
Proyecto: AuraSonix Engine - Un intérprete MIDI generativo con un motor de audio multicapa, efectos y presets para Flutter.
Filosofía: "Vibe Coding". Priorizar el desarrollo de funcionalidades complejas y la experiencia de usuario, delegando la documentación, las pruebas y las tareas repetitivas a la IA y a la automatización.

1. Visión General del Proyecto (Actualizada según Arquitectura Implementada)

Aplicación: Una aplicación Flutter multiplataforma (Web, iOS, Android) que funciona como un instrumento musical generativo con capacidades avanzadas de procesamiento MIDI y audio.

Motor de Audio: El núcleo de la app utiliza una arquitectura híbrida:
- **Web Platform**: Web Audio API con JavaScript (`web_audio.js`) para baja latencia y efectos avanzados
- **Mobile Platforms**: flutter_soloud como motor principal con fallback a audioplayers
- **Unified Interface**: Abstracción común a través de `WebUtils` y `WebAudioApi`

Arquitectura de Interfaz (Implementada y Funcional):
- **FOLDER Central**: `assets/audio/presets/` - Repositorio central de presets con estructura estandarizada
- **Main Window**: Interfaz simple y fácil de usar para cargar presets con scrollable UI y toggle buttons
- **Lab Window**: Máquina completa y afinable para crear y modificar presets con tabs funcionales (Effects tab removido, consolidado en Advanced MIDI Config)

Flujo de Datos Implementado:
```
Main Window ← FOLDER → Lab Window
    ↓           ↑         ↓
  LOAD      assets/    EDIT EXISTING
           audio/      AND CREATE
          presets/     VOLUME CONTROLS
                      REAL-TIME EFFECTS
```

2. Stack Tecnológico (Actualizado según Implementación)

Framework: Flutter (última versión estable)
Lenguaje: Dart (última versión estable)
Gestión de Estado: Riverpod con riverpod_generator (implementado completamente)
Procesamiento MIDI: 
- Web MIDI API para navegadores
- dart_midi para parseo y procesamiento
- AdvancedMidiProcessor para lógica compleja

Reproducción de Audio (Arquitectura Híbrida Implementada):
- **Web Platform**: Web Audio API con JavaScript (`web_audio.js`) - Baja latencia, efectos avanzados, routing multicapa
- **Mobile Platforms**: flutter_soloud como motor principal
- **Fallback**: audioplayers para compatibilidad
- **Unified Interface**: `WebUtils` y `WebAudioApi` proporcionan abstracción común

Base de Datos Local: Isar para almacenar Presets, configuraciones de usuario y metadatos de contenido.

3. Arquitectura de Software (Implementada y Funcional)

Clean Architecture implementada con las siguientes entidades refinadas:

Domain (Dominio)
Entidades Principales Implementadas:
- **MidiNote**: Representa una nota MIDI (noteNumber, velocity)
- **SoundSample**: Contiene la ruta a un archivo de audio y su nota base
- **TriggerCondition**: Clase abstracta que define cuándo se activa una capa
- **SoundLayer**: Define una capa de sonido con triggerConditions y effectsChain
- **AmbientLayer**: Representa un sonido de fondo con modulación LFO
- **AudioEffect**: Clase abstracta (ReverbEffect, FilterEffect, DelayEffect)
- **EffectsChain**: Una lista ordenada de AudioEffect
- **AudioPreset**: La entidad clave que agrupa toda una configuración
- **LFO**: Define un Oscilador de Baja Frecuencia (shape, rate, depth)
- **ModulationMapping**: Conecta un LFO a un parámetro específico
- **AdvancedMidiConfig**: Configuración avanzada con scale filtering y multi-zone mapping
- **ScaleFilterConfig**: Filtrado por escala y rango de octavas
- **LayerVolumes**: Control individual de volúmenes por capa

Casos de Uso Implementados:
- **ProcessMidiEvent**: Recibe un MidiNote, evalúa las triggerConditions y activa las capas correspondientes
- **ApplyPreset**: Carga un Preset y configura todo el motor de audio
- **AdvancedMidiProcessor**: Procesamiento avanzado con scale filtering y multi-zone mapping
- **Real-time Volume Control**: Control de volúmenes en tiempo real con actualización inmediata del audio

Flujo de Procesamiento de Audio Implementado:
1. MIDI Note → AdvancedMidiProcessor → Scale Filtering
2. Triggered Layers → Individual Effects Chains
3. Mixed Output → Global Effects Chain
4. Real-time Volume Control → Immediate Audio Update

4. Estrategia de Contenido Híbrida (Implementada)

Fase 1: Contenido Inicial Incluido (Bundled Content) ✅
- Implementado: 3 presets completos (relaxation, deep focus, creative flow)
- Estructura: `assets/audio/presets/[preset_name]/` con archivos bass, high, mid, tex y preset.json
- Funcionalidad: Carga automática y funcionamiento inmediato

Fase 2: Contenido Descargable (Biblioteca de Presets) 🔄
- Preparado: Sistema de importación ZIP implementado
- UI: Botón de importación en Main Window
- Backend: Preparado para integración con Firebase Storage

Fase 3: Contenido del Usuario (Modo Laboratorio) ✅
- Implementado: Lab Screen con capacidades completas de edición
- File Picker: Integrado para cargar samples personalizados
- Real-time Editing: Modificación en tiempo real de presets

5. Acceso Oculto a la UI de Laboratorio (Easter Egg) ✅

Activación Implementada:
- Tocar el logo de la app 7 veces en la pantalla de Ajustes
- Logo actualizado: "Logo-App-Live-Roots-Lab.png" en lugar de Flutter logo
- Overlay con D-pad y botones A/B para código Konami
- Código: ↑↑↓↓←→←→BA
- Desbloqueo: Guarda isLabUnlocked = true en Isar
- UI Condicional: Botón "Laboratorio" aparece permanentemente

6. Especificaciones de Interfaz (Implementadas y Funcionales)

Main Window ✅:
- **Propósito**: "A simple App where the presets are loaded. It should be easy to use."
- **Funcionalidad**: Carga presets desde `assets/audio/presets/` con nombres de carpetas
- **UI Mejorada**: 
  - Logo actualizado con "Logo Live Roots Lab blanco fondo transparente-01.png"
  - Logo ampliado (240x240) sin ClipOval para usar todo el espacio disponible
  - Scrollable ListView para múltiples presets
  - Toggle buttons con green glow effect para preset activo
  - Texto blanco para presets activos con outline verde
  - Eliminación del "mode status button" y "LIVE ROOTS" text del AppBar
  - Nombres de carpetas como display names
  - "Creative Flow" como preset por defecto (primero en la lista)
  - Browser tab title: "LiveRoots Player"
  - **Favicon personalizado**: LiveRoots Lab logo en lugar de Flutter icon
- **Play/Stop Controls**: 
  - Play button: Habilita entrada MIDI y reproduce ambient sound
  - Stop button: Deshabilita MIDI y fade out de 4 segundos
  - Tab visibility handling: Manejo automático de cambios de tab
- **Experiencia**: Interfaz simple y fácil de usar

Lab Window ✅:
- **Propósito**: "A complete Midi Lab for creating and fine tuning existing sounds."
- **Funcionalidad**: Crear y afinar sonidos existentes con tabs funcionales
- **Tabs Implementados**:
  - **Advanced MIDI Config**: Configuración avanzada de MIDI (único tab activo)
  - **Removido**: Effects Editor tab (funcionalidad consolidada en Advanced MIDI Config)
  - **Removido**: Basic Settings tab (consolidado en Advanced MIDI Config)
  - **Removido**: Audio Files tab (consolidado en Advanced MIDI Config)
- **Capacidad**: Cargar desde ZIP conteniendo sonidos y JSON con presets
- **Real-time Controls**: Volúmenes y efectos se aplican inmediatamente
- **Experiencia**: Máquina completa y afinable para usuarios avanzados

7. Características Técnicas Implementadas

Audio Engine & Playback Controls ✅:
- **Web Audio API**: Motor principal con baja latencia y efectos avanzados
- **Audio Loading**: Prioriza archivos .mp3 con fallback a .wav
- **AudioContext Management**: Manejo automático de suspensión/resumen
- **Play/Stop System**: 
  - Play: Habilita entrada MIDI y reproduce ambient sound
  - Stop: Deshabilita MIDI y fade out de 4 segundos
  - Tab Visibility: Manejo automático de cambios de tab/window
- **Audio Decoding**: Manejo robusto de errores de decodificación MP3/WAV
- **Cache Busting**: Sistema agresivo para evitar problemas de caché

Volumen Controls ✅:
- **Master Volume**: Control global del volumen
- **Layer Volumes**: Control individual para Bass, Mid, High, Ambient
- **Real-time Updates**: Cambios aplicados inmediatamente al audio
- **Safe Values**: Fallbacks para valores iniciales (0.8 para master/layers, 0.6 para ambient)
- **Reset/Randomize**: Botones funcionales para ajustes rápidos

MIDI Processing ✅:
- **Web MIDI API**: Soporte completo para navegadores
- **Scale Filtering**: Filtrado por escala y rango de octavas (Chromatic implementado)
- **Multi-zone Mapping**: Mapeo avanzado de zonas MIDI
- **Real-time Processing**: Procesamiento en tiempo real de eventos MIDI
- **Advanced Configuration**: Configuración avanzada con estadísticas y debugging
- **MIDI State Management**: 
  - Ignora señales MIDI cuando app está en "stop"
  - Re-enable automático cuando se presiona "play"
  - Manejo de visibilidad de tab para entrada MIDI

Audio Effects ✅:
- **Reverb**: Room size, damping, wet/dry levels
- **Filter**: Lowpass, highpass, frequency, resonance
- **LFO**: Sine, square, triangle waves con rate y depth
- **Envelope**: ADSR parameters para modulación
- **Real-time Application**: Efectos aplicados inmediatamente

8. Estándares, Git y CI/CD

Estándares de Código Implementados:
- **Clean Architecture**: Implementada completamente
- **Riverpod**: Gestión de estado con providers generados
- **Error Handling**: Manejo robusto de errores con logging
- **Type Safety**: Uso completo de tipos de Dart
- **Code Generation**: build_runner para providers y entidades

Estrategia de Git:
- **Feature Branches**: Desarrollo en ramas separadas
- **Conventional Commits**: Estructura de commits estandarizada
- **Pull Requests**: Revisión de código antes de merge
- **Versioning**: Semantic versioning para releases

CI/CD (Preparado):
- **GitHub Actions**: Workflows para testing y deployment
- **Automated Testing**: Unit tests y integration tests
- **Code Quality**: Linting y análisis estático
- **Deployment**: Automatización para web y mobile

9. Estrategia de Testing (Implementada)

Unit Tests Implementados:
- **Preset Loading**: Verificación de carga correcta de presets
- **MIDI Processing**: Testing de procesamiento de eventos MIDI
- **Volume Controls**: Verificación de controles de volumen
- **Effects Application**: Testing de aplicación de efectos
- **Provider States**: Verificación de estados de Riverpod providers

Integration Tests (con patrol):
- **Easter Egg Flow**: Navegación a Ajustes, tocar logo 7 veces, código Konami
- **Lab Access**: Verificación de desbloqueo del Laboratorio
- **Preset Loading**: Flujo completo de carga de presets
- **Volume Controls**: Testing de controles de volumen en tiempo real
- **MIDI Connection**: Verificación de conexión MIDI y procesamiento

10. Estado Actual del Proyecto ✅

Funcionalidades Completadas:
- ✅ Main Window con UI mejorada y scrollable
- ✅ Lab Window con tabs funcionales (Effects tab removido)
- ✅ Real-time volume controls
- ✅ MIDI processing avanzado
- ✅ Audio effects en tiempo real
- ✅ Easter egg para acceso al Lab
- ✅ Preset loading y management
- ✅ Web Audio API integration
- ✅ Advanced MIDI configuration
- ✅ Scale filtering y multi-zone mapping
- ✅ Play/Stop controls con fade out de 4 segundos
- ✅ Tab visibility handling para MIDI input
- ✅ AudioContext management automático
- ✅ UI refinements (logo, presets, colors)
- ✅ Chromatic scale filtering en todos los presets
- ✅ **Favicon personalizado implementado y desplegado**
- ✅ **Lab screen simplificado con solo Advanced MIDI Config tab**

Funcionalidades en Desarrollo:
- 🔄 Content download system (Fase 2)
- 🔄 Advanced DSP effects
- 🔄 User preset sharing
- 🔄 Cloud sync capabilities

11. Próximos Pasos

Corto Plazo:
- Testing exhaustivo de play/stop controls y tab visibility
- Optimización de performance en Web Audio API
- Mejora de la UI/UX basada en feedback de usuario
- Implementación de más efectos de audio
- Testing exhaustivo de todas las funcionalidades

Mediano Plazo:
- Sistema de descarga de contenido (Fase 2)
- Integración con servicios en la nube
- Mejoras en el motor de audio para mobile
- Sistema de sharing de presets

Largo Plazo:
- DSP personalizado con FFI
- Integración con DAWs
- Machine learning para generación de presets
- Comunidad de usuarios y marketplace

12. Mejoras Recientes (Agosto 2024) ✅

UI/UX Refinements:
- Logo actualizado con imagen transparente y tamaño ampliado
- Preset buttons con green glow effect y texto blanco
- Eliminación de elementos innecesarios (star icon, "LIVE ROOTS" text)
- "Creative Flow" como preset por defecto
- Browser tab title actualizado a "LiveRoots Player"
- **Favicon personalizado**: LiveRoots Lab logo implementado y desplegado
- **Lab screen simplificado**: Solo Advanced MIDI Config tab activo

Audio Engine Improvements:
- Play/Stop controls con fade out de 4 segundos
- AudioContext management automático para tab visibility
- Priorización de archivos .mp3 con fallback a .wav
- Manejo robusto de errores de decodificación
- Cache busting agresivo para evitar problemas de caché

MIDI State Management:
- Ignora señales MIDI cuando app está en "stop"
- Re-enable automático cuando se presiona "play"
- Manejo de visibilidad de tab para entrada MIDI
- Chromatic scale filtering implementado en todos los presets

Deployment & Infrastructure:
- **Firebase hosting configurado y funcional**
- **Favicon personalizado desplegado exitosamente**
- **Build process optimizado con cache-busting**
- **Multiple favicon formats soportados (PNG, ICO)**

13. Notas de Implementación

Arquitectura Híbrida:
- Web: Web Audio API proporciona la mejor performance y flexibilidad
- Mobile: flutter_soloud como base con capacidad de expansión
- Unified Interface: Abstracción común permite desarrollo consistente

Real-time Processing:
- MIDI events procesados inmediatamente
- Volume changes aplicados sin delay
- Effects modificados en tiempo real
- Audio routing optimizado para baja latencia
- Play/Stop state management con fade controls
- Tab visibility handling para continuidad de audio

User Experience:
- Main Window simple y intuitivo con controles play/stop
- Lab Window potente pero accesible (simplificado a un tab)
- Easter egg mantiene la simplicidad inicial
- Feedback inmediato en todas las interacciones
- UI refinada con logo actualizado y presets mejorados
- Manejo automático de cambios de tab para continuidad
- **Favicon personalizado mejora la identidad de marca**