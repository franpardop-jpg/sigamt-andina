# Entrega Final: Sprint 2 y Aplicación Terminada - SIGAMT

Empresa: Manufacturas Andina S.A.
Sistema: SIGAMT (Sistema Integrado de Gestión de Activos, Mantención y Trabajadores)
Equipo: Cleiver Namoc • Francisca Pardo

## 1. Funcionalidades Operativas Sprint 2
- Gestión completa de Órdenes de Trabajo (RF08–RF10): Creación manual, conversión desde fallas, flujo Pendiente → En curso → Cerrada y cierre inmutable con RUT.
- Control de Repuestos y Costos (RF12–RF13): Registro de insumos consumidos, cálculo acumulado en CLP y exportación a CSV.
- Planificación Preventiva (RF11): Programación periódica (Quincenal, Mensual, Trimestral) y generación directa de OTs preventivas.
- Panel Gerencial KPI e IA (RF14–RF15 / RNF06): Indicadores clave de negocio (RN1–RN3) y recomendaciones predictivas sujetas a decisión humana.

## 2. Integración con Base de Datos (database.sql)
Base de datos relacional normalizada (3FN) con 8 tablas operativas: usuarios, activos, reportes_fallas, ordenes_trabajo, intervenciones, repuestos_ot, pautas_preventivas y sugerencias_ia.

## 3. Pruebas Individuales, Finales y Correcciones
- PI-01 (Preventivos): Programación de pauta mensual y generación de OT preventiva -> APROBADO.
- PI-02 (Repuestos/Costos): Cierre de OT con repuesto ($85.000), actualización de costo acumulado y exportación CSV -> APROBADO.
- PI-03 (Sugerencias IA): Validación y aprobación humana de recomendación técnica con registro de usuario -> APROBADO.
- PF-01 (Flujo Integrado End-to-End): Reporte Offline -> Sincronización Online -> Conversión a OT -> Cierre con RUT -> Historial QR y KPIs -> APROBADO.
- PF-02 (Interfaces PC/Móvil): Verificación responsiva en escritorio y smartphone (Modo Oscuro/Claro) -> APROBADO.
- Correcciones aplicadas: Reemplazo de alertas nativas por notificaciones Toast no bloqueantes y recálculo automático del KPI de gasto total al cerrar OTs.
