-- ============================================================================
-- BASE DE DATOS RELACIONAL: SIGAMT - MANUFACTURAS ANDINA S.A.
-- Sistema Integrado de Gestión de Activos, Mantención y Trabajadores
-- ============================================================================

CREATE DATABASE IF NOT EXISTS sigamt_andina CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sigamt_andina;

-- 1. TABLA DE USUARIOS Y ROLES (RF01 / RNF04 / RNF05)
CREATE TABLE usuarios (
    rut VARCHAR(12) PRIMARY KEY COMMENT 'Formato chileno con guión, ej: 12.345.678-9',
    nombre_completo VARCHAR(100) NOT NULL,
    rol ENUM('operario', 'jefe', 'gerencia') NOT NULL DEFAULT 'operario',
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. CATASTRO DE ACTIVOS Y FICHA TÉCNICA (RF02 / RF03 / RF04)
CREATE TABLE activos (
    codigo_activo VARCHAR(20) PRIMARY KEY COMMENT 'Código único, ej: ACT-001',
    nombre VARCHAR(100) NOT NULL,
    linea_produccion VARCHAR(80) NOT NULL,
    ubicacion_fisica VARCHAR(80) NOT NULL,
    marca VARCHAR(60) NOT NULL,
    modelo VARCHAR(60),
    especificaciones TEXT,
    codigo_qr_hash VARCHAR(120) UNIQUE NOT NULL,
    estado ENUM('Operativo', 'En Mantención', 'Detenido') NOT NULL DEFAULT 'Operativo',
    costo_acumulado INT UNSIGNED NOT NULL DEFAULT 0,
    creado_por_rut VARCHAR(12) NOT NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (creado_por_rut) REFERENCES usuarios(rut)
);

-- 3. REPORTES DE FALLAS CORRECTIVAS EN TERRENO (RF06 / RF07)
CREATE TABLE reportes_fallas (
    id_falla VARCHAR(20) PRIMARY KEY COMMENT 'Ej: FALLA-12',
    codigo_activo VARCHAR(20) NOT NULL,
    severidad ENUM('Crítica', 'Alta', 'Media', 'Baja') NOT NULL DEFAULT 'Media',
    descripcion TEXT NOT NULL,
    reportado_por_rut VARCHAR(12) NOT NULL,
    fecha_reporte DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_triage ENUM('Pendiente', 'Convertido a OT', 'Descartado') NOT NULL DEFAULT 'Pendiente',
    sincronizado_offline BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (codigo_activo) REFERENCES activos(codigo_activo),
    FOREIGN KEY (reportado_por_rut) REFERENCES usuarios(rut)
);

-- 4. ÓRDENES DE TRABAJO - OT (RF08)
CREATE TABLE ordenes_trabajo (
    id_ot VARCHAR(20) PRIMARY KEY COMMENT 'Ej: OT-101',
    codigo_activo VARCHAR(20) NOT NULL,
    id_falla_origen VARCHAR(20) NULL,
    titulo VARCHAR(120) NOT NULL,
    descripcion TEXT NOT NULL,
    tipo ENUM('Correctiva', 'Preventiva') NOT NULL DEFAULT 'Correctiva',
    prioridad ENUM('Alta', 'Media', 'Baja') NOT NULL DEFAULT 'Media',
    estado ENUM('Pendiente', 'En curso', 'Cerrada') NOT NULL DEFAULT 'Pendiente',
    tecnico_asignado_rut VARCHAR(12) NOT NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_cierre DATETIME NULL,
    FOREIGN KEY (codigo_activo) REFERENCES activos(codigo_activo),
    FOREIGN KEY (id_falla_origen) REFERENCES reportes_fallas(id_falla),
    FOREIGN KEY (tecnico_asignado_rut) REFERENCES usuarios(rut)
);

-- 5. REGISTRO DE INTERVENCIONES CON TRAZABILIDAD RUT (RF09 / RF10)
CREATE TABLE intervenciones (
    id_intervencion INT AUTO_INCREMENT PRIMARY KEY,
    id_ot VARCHAR(20) NOT NULL,
    codigo_activo VARCHAR(20) NOT NULL,
    tecnico_ejecutor_rut VARCHAR(12) NOT NULL,
    acciones_realizadas TEXT NOT NULL,
    fecha_ejecucion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    bloqueada_edicion BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (id_ot) REFERENCES ordenes_trabajo(id_ot),
    FOREIGN KEY (codigo_activo) REFERENCES activos(codigo_activo),
    FOREIGN KEY (tecnico_ejecutor_rut) REFERENCES usuarios(rut)
);

-- 6. REPUESTOS CONSUMIDOS POR OT (RF12 / RF13)
CREATE TABLE repuestos_ot (
    id_consumo INT AUTO_INCREMENT PRIMARY KEY,
    id_ot VARCHAR(20) NOT NULL,
    codigo_activo VARCHAR(20) NOT NULL,
    nombre_repuesto VARCHAR(100) NOT NULL,
    cantidad INT UNSIGNED NOT NULL DEFAULT 1,
    costo_unitario_clp INT UNSIGNED NOT NULL DEFAULT 0,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_ot) REFERENCES ordenes_trabajo(id_ot),
    FOREIGN KEY (codigo_activo) REFERENCES activos(codigo_activo)
);

-- 7. PAUTAS DE MANTENCIÓN PREVENTIVA (RF11)
CREATE TABLE pautas_preventivas (
    id_pauta VARCHAR(20) PRIMARY KEY,
    codigo_activo VARCHAR(20) NOT NULL,
    titulo_tarea VARCHAR(120) NOT NULL,
    frecuencia ENUM('Semanal', 'Quincenal', 'Mensual', 'Trimestral') NOT NULL,
    proxima_fecha DATE NOT NULL,
    FOREIGN KEY (codigo_activo) REFERENCES activos(codigo_activo)
);

-- 8. SUGERENCIAS IA DE PATRONES DE FALLA (RF15 / RNF06)
CREATE TABLE sugerencias_ia (
    id_sugerencia VARCHAR(20) PRIMARY KEY,
    codigo_activo VARCHAR(20) NOT NULL,
    titulo VARCHAR(120) NOT NULL,
    analisis_historico TEXT NOT NULL,
    recomendacion TEXT NOT NULL,
    decision_humana ENUM('Pendiente', 'Aceptada', 'Descartada') NOT NULL DEFAULT 'Pendiente',
    decidido_por_rut VARCHAR(12) NULL,
    fecha_decision DATETIME NULL,
    FOREIGN KEY (codigo_activo) REFERENCES activos(codigo_activo),
    FOREIGN KEY (decidido_por_rut) REFERENCES usuarios(rut)
);

-- ============================================================================
-- DATOS INICIALES DE PRUEBA (SEED DATA)
-- ============================================================================
INSERT INTO usuarios (rut, nombre_completo, rol) VALUES
('12.345.678-9', 'Cleiver Namoc', 'operario'),
('15.432.109-8', 'Francisca Pardo', 'jefe');

INSERT INTO activos (codigo_activo, nombre, linea_produccion, ubicacion_fisica, marca, especificaciones, codigo_qr_hash, estado, costo_acumulado, creado_por_rut) VALUES
('ACT-001', 'Prensa Hidráulica 50T', 'Línea 1 - Estampado', 'Nave A-1', 'Bosch Rexroth', 'Presión máx 250 bar • 380V', 'QR-SIGAMT-ACT001', 'Operativo', 1250000, '15.432.109-8'),
('ACT-002', 'Torno CNC UltraCut', 'Línea 1 - Estampado', 'Nave A-2', 'Haas Automation', 'Husillo 12.000 RPM • 15kW', 'QR-SIGAMT-ACT002', 'En Mantención', 890000, '15.432.109-8'),
('ACT-003', 'Cinta Transportadora V3', 'Línea 2 - Envasado', 'Nave B-1', 'Siemens Drive', 'Motor 5.5kW • Banda PVC 800mm', 'QR-SIGAMT-ACT003', 'Operativo', 420000, '15.432.109-8'),
('ACT-004', 'Compresor Industrial 100HP', 'Servicios Generales', 'Salón Máquinas', 'Kaeser Compressors', 'Caudal 14 m³/min • 8 bar', 'QR-SIGAMT-ACT004', 'Operativo', 1560000, '15.432.109-8');
