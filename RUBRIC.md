# Rúbrica — Checklist accionable

Niveles: **Limitado (0)** · **Básico (1)** · **Efectivo (2)**.
Marca antes de entregar. Si algo está vacío, ahí estás dejando puntos en la mesa.

---

## Fit Problema · Solución · Justificación · 40 pts

- [ ] **Planteamiento alineado · 10**
  - Problema claro en una oración
  - Persona/usuario objetivo definido (con nombre, edad, contexto)
  - La solución mapea 1:1 al problema; ningún feature huérfano
- [ ] **Originalidad · 10**
  - ¿Qué hace que esto NO exista ya en App Store?
  - Si existe algo parecido, ¿qué hacemos distinto y por qué importa?
- [ ] **Factibilidad y escala · 10**
  - Demo funciona end-to-end en simulador o dispositivo
  - Hay un camino creíble a producción (no requiere infra imposible)
- [ ] **Pitch / storytelling · 10**
  - 10 min cronometrados con reloj
  - Estructura: gancho → problema → usuario → solución → demo → impacto → cierre
  - Demo en simulador o iPhone/iPad real
  - Todos los integrantes presentes

## Human-Centered AI · 30 pts

### Diseño · 10
- [ ] **Carga cognitiva · 4** — Input por foto/voz cuando sea posible. Si hay prompt, autocompletar o chips de sugerencias. Cero campos de texto vacíos sin guía.
- [ ] **Modelo mental · 3** — Cada pantalla deja claro qué pasa después. Pasos numerados o progress visible.
- [ ] **Ingeniería de la experiencia · 3** — Funciona offline. Manejo de batería, permisos denegados, cámara no disponible.

### Control · 10
- [ ] **Agencia · 4** — Usuario puede editar/corregir/rechazar la sugerencia de la IA. Nada se hace automático sin confirmación.
- [ ] **Interpretabilidad · 3** — Se muestra **por qué** el modelo dijo lo que dijo (confianza %, regiones detectadas, razonamiento del LLM).
- [ ] **Confianza · 3** — Mostrar nivel de confianza, alternativas, link a fuente cuando aplique. Indicar cuando la IA "no sabe".

### Impacto · 10
- [ ] **Inclusividad · 3** — VoiceOver, Dynamic Type, alto contraste, internacionalización mínima ES/EN, sin asumir alfabetización digital alta.
- [ ] **Diseño responsable · 3** — No fomenta comportamiento dañino. Sin gamificación tóxica. Sin dark patterns.
- [ ] **Seguridad de datos · 3** — Todo on-device. Sin tracking. Sin red salvo APIs públicas justificadas. Decirlo en pitch y en pantalla de privacidad.
- [ ] **Sustentabilidad · 1** — La app misma no derrocha (sin polling continuo, sin uploads innecesarios).

## Implementación Técnica · 30 pts

- [ ] **UX/UI · 5** — SF Symbols, jerarquía tipográfica clara, espaciado consistente, navegación nativa. Diseñador documenta el sistema.
- [ ] **Accesibilidad · 5**
  - VoiceOver navegable en TODA la app
  - Dynamic Type respetado en TODAS las vistas
  - Touch targets ≥ 44pt
  - `.accessibilityLabel` en imágenes y botones de ícono
  - Probado con simulador en modo accesibilidad
- [ ] **Frameworks Apple on-device · 10** — Lista en pitch. Mínimo 4-5 frameworks con justificación de por qué cada uno (no por usar todos, sino por necesidad).
- [ ] **IA on-device · 10**
  - Mínimo 1 de: Core ML, Vision, Foundation Models, MLX, Natural Language
  - Idealmente combinar visión (Core ML/Vision) + lenguaje (Foundation Models)
  - Justificar en pitch: por qué on-device (privacidad, latencia, offline)
  - Demostrar el modelo funcionando, no solo mencionarlo

---

## Entregables obligatorios

- [ ] Código en iCloud asignado, antes de la hora límite
- [ ] Keynote con plantilla del comité, llenando:
  - [ ] Título de proyecto
  - [ ] Propósito de la aplicación
  - [ ] Necesidad que resuelve
  - [ ] Nombres de los 3 integrantes
  - [ ] Universidad Panamericana
  - [ ] Lab Manager / Profesor
  - [ ] Lista completa de tecnologías y frameworks
  - [ ] Lista de repositorios necesarios (SPM packages, modelos)
  - [ ] Demo en video o en vivo
- [ ] Consentimiento de uso de imagen firmado por los 3 integrantes
