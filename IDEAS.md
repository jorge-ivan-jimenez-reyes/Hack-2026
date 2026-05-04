# Brainstorm — Reto "Residuos" + Human-Centered AI

> Mientras no anuncien el reto específico, tener 4-5 ideas pre-cocinadas reduce 2-3 horas de bloqueo el día 1.
> Cada idea anota qué casillas del rubro pegaría más fuerte.

---

## 1. EcoLens — clasificador con coach
**Qué hace:** apuntas la cámara a cualquier objeto. La app dice a qué bote va (orgánico/inorgánico/PET/vidrio/metal/electrónico). Foundation Models explica **por qué** y da 1 tip para reducir.
**IA:** Vision + Core ML (clasificación) + Foundation Models (explicación).
**Pegada en rubro:**
- HCAI Interpretabilidad (3) — muestra confianza y razonamiento
- HCAI Carga cognitiva (4) — cero texto que escribir
- IA on-device (10) — combo perfecto
- Originalidad (5-10) — depende del giro
**Riesgo:** muy "obvio", muchos equipos lo van a hacer. Necesita un giro original.

## 2. ReCircular — economía circular barrial
**Qué hace:** mercado local hiper-cercano. Ofreces residuos reutilizables (cartón, frascos, ropa) y la app sugiere usos creativos vía LLM, conecta con vecinos que los necesitan.
**IA:** Foundation Models para generar usos creativos a partir de la foto + descripción. Vision para auto-clasificar el objeto.
**Pegada en rubro:**
- Originalidad (10) — pocas apps cubren circularidad hiperlocal
- Impacto / Inclusividad (3) — sirve a comunidades sin acceso a centros de reciclaje
- Sustentabilidad (1) — claro
**Riesgo:** demo difícil de mostrar en 5 min sin red de usuarios.

## 3. SinVer — reciclaje accesible para personas con discapacidad visual
**Qué hace:** app voice-first. "¿Qué tengo en la mano?" → la app describe y dice a qué bote va. Sin botones complejos. Todo VoiceOver-nativo.
**IA:** Vision + Core ML para identificación + Speech para input + Foundation Models para diálogo natural + AVSpeechSynthesizer para output.
**Pegada en rubro:**
- HCAI Inclusividad (3) — máximo
- Accesibilidad (5) — máximo
- Diseño responsable (3) — atiende grupo subatendido
- Originalidad (10) — nicho real, alto impacto
**Riesgo:** ningún integrante del equipo es ciego, validar con cuidado para no caer en supuestos.

## 4. Compostera — coach de compostaje casero
**Qué hace:** diagnóstico visual de tu compostera ("se ve seca", "demasiado verde"). Recordatorios de volteo. Q&A en lenguaje natural.
**IA:** Vision para diagnosticar estado + Foundation Models para coaching conversacional + notificaciones locales.
**Pegada en rubro:**
- Confianza (3) — explica diagnóstico con regiones de la imagen
- Agencia (4) — usuario decide acciones
- Sustentabilidad (1) — directo
- IA on-device (10)
**Riesgo:** dataset de compostas en distintos estados es difícil de conseguir.

## 5. Trazabilidad escolar — residuos en la UP
**Qué hace:** registra qué genera cada salón/oficina del campus. Heatmap de generación. Sugerencias por área.
**IA:** Vision para foto rápida del bote → estimación de volumen y tipo. Foundation Models para reportes ejecutivos.
**Pegada en rubro:**
- Factibilidad (10) — escenario real verificable
- Pitch (10) — historia local fuerte
**Riesgo:** depende de adopción, demo abstracta.

---

## Heurística para escoger el día 1
1. ¿El reto específico me deja usar **cámara + LLM combinados**? Si sí → EcoLens-style.
2. ¿El reto pide impacto en grupo específico? → SinVer u otra adaptada.
3. ¿El reto pide datos / trazabilidad? → Trazabilidad.
4. ¿En 6 horas puedo tener demo que clasifique 3 categorías? Sí → seguir. No → simplificar.
5. **Regla de oro:** lo que sí funcione en simulador a las 12h del evento es lo que se entrega. Cortar features sin piedad.
