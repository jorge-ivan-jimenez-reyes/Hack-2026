# Tests

- `UnitTests/` — Swift Testing (`@Test`) sobre ViewModels y servicios `Core/`
- `UITests/` — XCUITest para flujos críticos (clasificar → ver explicación → guardar)

Prioridad en hackathon: 0 tests > tests que solo verifican getters. Solo testear lo que evita regresión real durante el evento (ej. parser de respuesta del modelo, lógica de fallback si Apple Intelligence no está disponible).
