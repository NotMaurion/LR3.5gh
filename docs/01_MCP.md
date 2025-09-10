Plan de Control Maestro (MCP) V4.1: LiveRoots - Arquitectura Definitiva
Versión: 4.1
Fecha: 12 de agosto de 2024
Filosofía: "Fundación Estable, Creatividad Ilimitada". Priorizamos una arquitectura central robusta, predecible y fácil de mantener para eliminar la deuda técnica. Sobre esta base sólida, construimos las funcionalidades creativas y complejas de forma segura y escalable.

1. Resumen Ejecutivo: ¿Por Qué Este Nuevo MCP?
El desarrollo anterior (V3) enfrentó problemas críticos de estabilidad, principalmente por:

Complejidad Accidental: El uso de archivos .json para la gestión de presets introdujo una capa frágil de parseo y validación, propensa a errores.

Ambigüedad en Rutas: La falta de una convención estricta para las rutas de los archivos de audio generó errores 404 y dificultó la depuración.

Acoplamiento Excesivo: La lógica de audio estaba demasiado mezclada con la lógica de la aplicación, haciendo difícil aislar y solucionar problemas.

Este MCP V4.1 resuelve estos problemas de raíz con una arquitectura simplificada y un flujo de trabajo profesional, permitiendo que el equipo se concentre en crear funcionalidades en lugar de apagar incendios.

2. Arquitectura de Software: "Convención sobre Configuración"
Abandonamos los archivos .json para la carga de presets y adoptamos una estructura de directorios estricta como única fuente de verdad.

2.1. Estructura de Presets (No Negociable)
assets/
└── audio/
    └── presets/
        ├── [nombre_del_preset_1]/
        │   ├── bass.wav
        │   ├── mid.wav
        │   ├── high.wav
        │   └── tex.wav
        └── [nombre_del_preset_2]/
            ├── bass.wav
            ...

Regla de Oro: Cada subdirectorio en presets/ es un preset. Su nombre es el nombre del preset. Debe contener los cuatro archivos .wav nombrados exactamente como se muestra.

Beneficio: Cero errores de parseo, cero ambigüedad. El sistema es predecible.

2.2. Motor de Audio Híbrido y Aislado
Se define una interfaz común en Dart (AudioEngine) para desacoplar la UI de la implementación de audio de cada plataforma.

Interfaz Común (lib/audio/audio_engine.dart):

abstract class AudioEngine {
  Future<void> init();
  Future<bool> loadPreset(String presetName);
  void playNote(int noteNumber, {double velocity});
  void stopNote(int noteNumber);
  void stopAll();
  // Futuro: Métodos para controlar efectos
  // void setEffectParam(String effectId, String param, double value);
}

Implementación Web (WebAudioEngine): Un puente en Dart que invoca al AuraSonixEngine, un motor de audio autocontenido en JavaScript (web/js/aurasonix_engine.js). La complejidad de la Web Audio API vive aislada del código Flutter.

Implementación Móvil (MobileAudioEngine): Usará un paquete robusto como just_audio para implementar la misma interfaz AudioEngine, consumiendo los mismos archivos de assets.

2.3. Entidades del Dominio (Simplificadas y Futuras)
Las complejas entidades del V3 (LFO, EffectsChain, etc.) no se eliminan, sino que se reubican. Pasan de ser un problema de "parseo de JSON" a ser una responsabilidad interna del AudioEngine.

En la Fase Inicial: El motor solo se preocupa de cargar y reproducir los 4 samples.

En Fases Futuras (Laboratorio): El AudioEngine se expandirá internamente para manejar estas entidades. Por ejemplo, al cargar un preset del "Lab", podría buscar un lab_preset_config.json opcional dentro de la carpeta del preset para configurar efectos, LFOs, etc. Esto se hará sobre una base que ya es estable.

3. Stack Tecnológico
Framework: Flutter (última versión estable)

Gestión de Estado: Riverpod con riverpod_generator.

Motor de Audio Web: AuraSonixEngine (JavaScript nativo con Web Audio API).

Motor de Audio Móvil: just_audio.

Base de Datos Local: Isar. Se usará únicamente para configuraciones de usuario y presets creados en el "Laboratorio", no para la carga de presets base.

CI/CD & Hosting: GitHub Actions y Firebase Hosting.

4. Flujo de Trabajo y DevOps
Para garantizar la calidad y la velocidad, adoptamos un flujo de trabajo profesional.

4.1. Estrategia Git (GitFlow)
main: Rama de producción. Estable y siempre desplegable.

develop: Rama de integración. Aquí se fusionan las nuevas funcionalidades.

feature/[nombre]: Ramas para cada nueva funcionalidad.

Commits Convencionales: Todos los commits deben seguir el estándar tipo(alcance): mensaje (ej. feat(audio): add reverb effect). Esto automatiza la generación de changelogs.

4.2. Automatización (GitHub Actions)
CI (Integración Continua): En cada push a develop o main, se ejecutarán automáticamente:

flutter analyze (Análisis estático de código).

flutter test (Pruebas unitarias).

flutter build web (Para asegurar que el proyecto compila).

CD (Despliegue Continuo): En cada push a main, el workflow desplegará automáticamente la versión web a Firebase Hosting.

5. Hoja de Ruta (Roadmap)
Esta hoja de ruta prioriza la estabilidad antes de añadir complejidad.

Fase 1: Fundación Estable (Completa)

[x] Definir y construir el motor AuraSonixEngine en JS.

[x] Crear página de pruebas HTML para validación aislada.

[x] Establecer la estructura de archivos "Convención sobre Configuración".

[x] Implementar optimizaciones de rendimiento para prevenir saturación del buffer MIDI.

Fase 2: Integración y App Base

[ ] Implementar la interfaz AudioEngine y las clases WebAudioEngine y MobileAudioEngine.

[ ] Construir la UI del "Reproductor Simple" en Flutter, consumiendo el AudioEngine.

[ ] Configurar CI/CD en GitHub Actions.

Fase 3: El Laboratorio - Creación

[ ] Diseñar e implementar la UI del "Laboratorio".

[ ] Permitir al usuario cargar sus propios samples.

[ ] Guardar los presets del laboratorio (samples + configuración de efectos) usando Isar.

Fase 4: Motor de Efectos Avanzado

[ ] Expandir el AudioEngine para que soporte una cadena de efectos (Reverb, Filter, Delay).

[ ] Implementar la modulación con LFOs y Envelopes (ADSR) dentro del motor.

[ ] Conectar la UI del Laboratorio para controlar estos parámetros en tiempo real.

Fase 5: Contenido y Comunidad

[ ] Implementar la descarga de nuevos presets desde un backend (Firebase Storage).

[ ] Desarrollar un sistema para compartir presets entre usuarios.

Fase 6: Acceso Oculto (Easter Egg)

[ ] Implementar el desbloqueo del Laboratorio mediante el código Konami como se especificó en V3, usando Isar para guardar el estado de desbloqueo.

## 6. Optimizaciones de Rendimiento (Nueva Sección)

### 6.1. Problema Resuelto: Saturación del Buffer MIDI

Basado en las observaciones del ingeniero de sonido, se identificó que la aplicación experimentaba saturación del buffer MIDI cuando se enviaban muchas notas consecutivas rápidamente (aproximadamente cada 200ms). Esto ocurría porque:

- Los samples tienen una duración mayor al intervalo entre notas
- La aplicación intentaba reproducir múltiples notas simultáneamente
- No había límites en la cantidad de notas concurrentes
- El buffer MIDI se saturaba, causando problemas de rendimiento

### 6.2. Soluciones Implementadas

#### Límite de Notas Concurrentes
```javascript
// Configuración de límites de rendimiento
this.MAX_CONCURRENT_NOTES = 16; // Límite total de notas activas
this.MAX_CONCURRENT_NOTES_PER_NOTE = 3; // Máximo 3 instancias de la misma nota
```

#### Voice Stealing Inteligente
- Detecta automáticamente cuando se alcanza el límite de notas concurrentes
- Identifica la nota más antigua (por timestamp de creación)
- Detiene automáticamente esa nota para hacer espacio
- Permite que las nuevas notas se reproduzcan

#### Limpieza Automática de Fuentes Huérfanas
- Elimina fuentes de audio que han terminado pero no fueron eliminadas correctamente
- Se ejecuta cada 5 segundos para prevenir acumulación de recursos
- Incluye un período de gracia de 1 segundo para evitar eliminaciones prematuras

#### Verificación Antes de Reproducir
- Valida límites antes de crear nuevas fuentes de audio
- Implementa voice stealing cuando es necesario
- Previene la saturación del buffer MIDI

### 6.3. Configuración Adaptativa por Dispositivo

El sistema puede ajustar los límites según el rendimiento del dispositivo:

```javascript
adjustPerformanceLimits(deviceType = 'auto') {
  const limits = {
    'low': { maxConcurrent: 8, maxPerNote: 2 },
    'medium': { maxConcurrent: 16, maxPerNote: 3 },
    'high': { maxConcurrent: 32, maxPerNote: 4 },
    'auto': { maxConcurrent: 16, maxPerNote: 3 }
  };
}
```

### 6.4. Monitoreo de Rendimiento

#### Estadísticas Disponibles
```javascript
getPerformanceStats() {
  return {
    totalActiveSources: this.activeSources.size,
    maxConcurrentNotes: this.MAX_CONCURRENT_NOTES,
    maxConcurrentNotesPerNote: this.MAX_CONCURRENT_NOTES_PER_NOTE,
    activeNotesByNote: {}, // Notas activas por número de nota
    bufferSaturation: this.activeSources.size >= this.MAX_CONCURRENT_NOTES,
    lastCleanupTime: this._lastCleanupTime,
    audioContextState: this.audioCtx ? this.audioCtx.state : 'not_initialized'
  };
}
```

#### Logs de Debugging
El sistema incluye logs detallados para monitorear el rendimiento:
```
AuraSonixEngine: Max concurrent notes reached (16/16), will steal voice
AuraSonixEngine: Stealing oldest voice to prevent buffer saturation
AuraSonixEngine: Cleaned up 3 orphaned sources
AuraSonixEngine: Adjusted performance limits for medium: {maxConcurrent: 16, maxPerNote: 3}
```

### 6.5. Beneficios de las Optimizaciones

✅ **Prevención de Saturación**: El buffer MIDI ya no se satura con muchas notas consecutivas
✅ **Mejor Rendimiento**: Menos carga en el procesador de audio
✅ **Experiencia Consistente**: La aplicación funciona mejor en computadoras menos potentes
✅ **Voice Stealing Inteligente**: Las notas más antiguas se detienen automáticamente
✅ **Limpieza Automática**: No hay acumulación de fuentes de audio huérfanas
✅ **Configuración Adaptativa**: Se puede ajustar según el dispositivo

### 6.6. Resultados Observados

Durante las pruebas de rendimiento se confirmó:
- **Limpieza Automática Funcionando**: Se limpiaron 42 fuentes huérfanas en el período de observación
- **Probability Gate Activo**: Aproximadamente 30% de las notas son rechazadas por el probability gate
- **Reproducción Estable**: Las notas se reproducen sin interrupciones
- **Saturación Prevenida**: No se detectaron logs de "Max concurrent notes reached" o "buffer saturated"

### 6.7. Próximas Optimizaciones de Rendimiento

1. **Adaptación Automática**: Implementar detección automática del rendimiento del dispositivo
2. **Métricas Avanzadas**: Agregar métricas de latencia y uso de CPU
3. **Configuración Dinámica**: Ajustar límites basado en el rendimiento en tiempo real
4. **Optimización de Efectos**: Reducir la carga de efectos de audio en dispositivos lentos