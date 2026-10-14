-- ==========================================
-- 1. BASE, PACIENTES Y PERSONAL (7 tablas)
-- ==========================================

CREATE TABLE IF NOT EXISTS sede (
    id_sede SERIAL PRIMARY KEY,
    nombre_sede VARCHAR(100) NOT NULL,
    direccion TEXT NULL
);

CREATE TABLE IF NOT EXISTS tipo_documento ( 
    id_tipo_doc SERIAL PRIMARY KEY, 
    abreviatura VARCHAR(10) NOT NULL, 
    nombre_completo VARCHAR(50) NOT NULL 
);

CREATE TABLE IF NOT EXISTS empleado (
    id_empleado SERIAL PRIMARY KEY,
    id_tipo_doc INT NOT NULL,
    numero_doc VARCHAR(20) UNIQUE NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    fecha_contratacion DATE DEFAULT CURRENT_DATE,
    CONSTRAINT fk_emp_tipodoc FOREIGN KEY (id_tipo_doc) REFERENCES tipo_documento(id_tipo_doc)
);

CREATE TABLE IF NOT EXISTS paciente (
    id_paciente SERIAL PRIMARY KEY,
    dni VARCHAR(8) UNIQUE NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    genero CHAR(1) NOT NULL,
    ubigeo VARCHAR(6) NULL
);

CREATE TABLE IF NOT EXISTS especialidad (
    id_especialidad SERIAL PRIMARY KEY,
    especialidad VARCHAR(100) UNIQUE NOT NULL,
    descripcion TEXT NULL
);

CREATE TABLE IF NOT EXISTS medico (
    id_medico SERIAL PRIMARY KEY,
    id_empleado INT NOT NULL, 
    cmp VARCHAR(10) UNIQUE NOT NULL,
    id_especialidad INT NOT NULL,
    correo VARCHAR(100) NOT NULL,
    CONSTRAINT fk_medico_especialidad FOREIGN KEY (id_especialidad) REFERENCES especialidad(id_especialidad) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_medico_empleado FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS disponibilidad_medica (
    id_disponibilidad SERIAL PRIMARY KEY,
    id_medico INT NOT NULL,
    dia_semana VARCHAR(15) NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    CONSTRAINT fk_dispo_medico FOREIGN KEY (id_medico) REFERENCES medico(id_medico) ON UPDATE CASCADE ON DELETE CASCADE
);


-- ==========================================
-- 2. CITAS Y AGENDAMIENTO (3 tablas)
-- ==========================================

CREATE TABLE IF NOT EXISTS consultorio (
    id_consultorio SERIAL PRIMARY KEY,
    nro_consultorio VARCHAR(10) NOT NULL,
    nro_piso INT NOT NULL,
    id_sede INT NULL,
    CONSTRAINT fk_consultorio_sede FOREIGN KEY (id_sede) REFERENCES sede(id_sede) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS estado_cita (
    id_estado SERIAL PRIMARY KEY,
    descripcion VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS cita (
    id_cita SERIAL PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_medico INT NOT NULL,
    id_consultorio INT NOT NULL,
    id_estado INT NOT NULL,
    fecha_cita DATE NOT NULL,
    hora_cita TIME NOT NULL,
    CONSTRAINT fk_cita_paciente FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_cita_medico FOREIGN KEY (id_medico) REFERENCES medico(id_medico) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_cita_consultorio FOREIGN KEY (id_consultorio) REFERENCES consultorio(id_consultorio) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_cita_estado FOREIGN KEY (id_estado) REFERENCES estado_cita(id_estado) ON UPDATE CASCADE ON DELETE CASCADE
);


-- ==========================================
-- 3. HOSPITALIZACIÓN (7 tablas)
-- ==========================================

CREATE TABLE IF NOT EXISTS cama (
    id_cama SERIAL PRIMARY KEY,
    codigo_cama VARCHAR(20) NOT NULL UNIQUE,
    tipo_cama VARCHAR(50) NOT NULL,
    estado VARCHAR(50) NOT NULL DEFAULT 'Disponible'
);

CREATE TABLE IF NOT EXISTS admision (
    id_admision SERIAL PRIMARY KEY,
    id_paciente INT NOT NULL,
    fecha_ingreso TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    motivo_ingreso TEXT NOT NULL,
    id_medico_responsable INT NOT NULL,
    CONSTRAINT fk_admision_paciente FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    CONSTRAINT fk_admision_medico FOREIGN KEY (id_medico_responsable) REFERENCES medico(id_medico)
);

CREATE TABLE IF NOT EXISTS hospitalizacion (
    id_hospitalizacion SERIAL PRIMARY KEY,
    id_admision INT NOT NULL UNIQUE,
    id_cama INT NOT NULL,
    fecha_asignacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_liberacion TIMESTAMP,
    CONSTRAINT fk_hosp_admision FOREIGN KEY (id_admision) REFERENCES admision(id_admision),
    CONSTRAINT fk_hosp_cama FOREIGN KEY (id_cama) REFERENCES cama(id_cama)
);

CREATE TABLE IF NOT EXISTS visita_medica_diaria (
    id_visita SERIAL PRIMARY KEY,
    id_hospitalizacion INT NOT NULL,
    id_medico INT NOT NULL,
    fecha_visita TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    observaciones TEXT NOT NULL,
    CONSTRAINT fk_visita_hosp FOREIGN KEY (id_hospitalizacion) REFERENCES hospitalizacion(id_hospitalizacion) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_visita_medico FOREIGN KEY (id_medico) REFERENCES medico(id_medico) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS alta_medica (
    id_alta SERIAL PRIMARY KEY,
    id_hospitalizacion INT NOT NULL UNIQUE,
    fecha_alta TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    diagnostico_final TEXT NOT NULL,
    indicaciones TEXT,
    CONSTRAINT fk_alta_hosp FOREIGN KEY (id_hospitalizacion) REFERENCES hospitalizacion(id_hospitalizacion)
);

CREATE TABLE IF NOT EXISTS traslado_cama (
    id_traslado SERIAL PRIMARY KEY,
    id_hospitalizacion INT NOT NULL,
    id_cama_origen INT NOT NULL,
    id_cama_destino INT NOT NULL,
    motivo TEXT NOT NULL,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tras_hosp FOREIGN KEY (id_hospitalizacion) REFERENCES hospitalizacion(id_hospitalizacion),
    CONSTRAINT fk_tras_cama_orig FOREIGN KEY (id_cama_origen) REFERENCES cama(id_cama),
    CONSTRAINT fk_tras_cama_dest FOREIGN KEY (id_cama_destino) REFERENCES cama(id_cama),
    CONSTRAINT chk_tras_cama CHECK (id_cama_origen <> id_cama_destino)
);

CREATE TABLE IF NOT EXISTS apoderado (
    id_apoderado SERIAL PRIMARY KEY,
    id_paciente INT NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    numero_doc VARCHAR(20) NOT NULL,
    telefono VARCHAR(20),
    parentesco VARCHAR(50) NOT NULL,
    CONSTRAINT fk_apoderado_paciente FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente) ON UPDATE CASCADE ON DELETE CASCADE
);


-- ==========================================
-- 4. FARMACIA E INVENTARIO (6 tablas)
-- ==========================================

CREATE TABLE IF NOT EXISTS medicamento (
    id_medicamento SERIAL PRIMARY KEY,
    nombre_comercial VARCHAR(150) NOT NULL,
    principio_activo VARCHAR(150) NOT NULL,
    presentacion VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS proveedor (
    id_proveedor SERIAL PRIMARY KEY,
    ruc VARCHAR(20) UNIQUE NOT NULL,
    razon_social VARCHAR(150) NOT NULL,
    telefono VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS almacen (
    id_almacen SERIAL PRIMARY KEY,
    id_sede INT NULL,
    nombre_almacen VARCHAR(100) NOT NULL,
    CONSTRAINT fk_almacen_sede FOREIGN KEY (id_sede) REFERENCES sede(id_sede) ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS lote (
    id_lote SERIAL PRIMARY KEY,
    id_medicamento INT NOT NULL,
    id_proveedor INT NOT NULL,
    codigo_lote VARCHAR(50) NOT NULL,
    fecha_vencimiento DATE NOT NULL,
    CONSTRAINT fk_lote_medicamento FOREIGN KEY (id_medicamento) REFERENCES medicamento(id_medicamento) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_lote_proveedor FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS inventario (
    id_inventario SERIAL PRIMARY KEY,
    id_almacen INT NOT NULL,
    id_lote INT NOT NULL,
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    CONSTRAINT fk_inv_almacen FOREIGN KEY (id_almacen) REFERENCES almacen(id_almacen),
    CONSTRAINT fk_inv_lote FOREIGN KEY (id_lote) REFERENCES lote(id_lote)
);

CREATE TABLE IF NOT EXISTS receta_medica (
    id_receta SERIAL PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_medico INT NOT NULL,
    fecha_emision TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_receta_paciente FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    CONSTRAINT fk_receta_medico FOREIGN KEY (id_medico) REFERENCES medico(id_medico)
);


-- ==========================================
-- 5. LABORATORIO (4 tablas)
-- ==========================================

CREATE TABLE IF NOT EXISTS tipo_examen (
    id_tipo_examen SERIAL PRIMARY KEY,
    nombre_tipo VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS examen (
    id_examen SERIAL PRIMARY KEY,
    id_tipo_examen INT NOT NULL,
    nombre_examen VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL CHECK (precio >= 0),
    CONSTRAINT fk_examen_tipo FOREIGN KEY (id_tipo_examen) REFERENCES tipo_examen(id_tipo_examen)
);

CREATE TABLE IF NOT EXISTS orden_laboratorio (
    id_orden SERIAL PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_medico INT NOT NULL,
    fecha_orden TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_orden_paciente FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    CONSTRAINT fk_orden_medico FOREIGN KEY (id_medico) REFERENCES medico(id_medico)
);

CREATE TABLE IF NOT EXISTS muestra (
    id_muestra SERIAL PRIMARY KEY,
    id_orden INT NOT NULL,
    tipo_muestra VARCHAR(50) NOT NULL,
    fecha_recepcion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_muestra_orden FOREIGN KEY (id_orden) REFERENCES orden_laboratorio(id_orden) ON UPDATE CASCADE ON DELETE CASCADE
);


-- ==========================================
-- 6. FACTURACIÓN Y CAJA (10 tablas)
-- ==========================================

CREATE TABLE IF NOT EXISTS caja (
    id_caja SERIAL PRIMARY KEY,
    id_sede INT NULL,
    codigo_caja VARCHAR(20) NOT NULL,
    CONSTRAINT fk_caja_sede FOREIGN KEY (id_sede) REFERENCES sede(id_sede)
);

CREATE TABLE IF NOT EXISTS cajero (
    id_cajero SERIAL PRIMARY KEY,
    id_empleado INT NOT NULL UNIQUE,
    CONSTRAINT fk_cajero_empleado FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado)
);

CREATE TABLE IF NOT EXISTS apertura_caja (
    id_apertura SERIAL PRIMARY KEY,
    id_caja INT NOT NULL,
    id_cajero INT NOT NULL,
    monto_inicial DECIMAL(10,2) NOT NULL CHECK (monto_inicial >= 0),
    fecha_apertura TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_cierre TIMESTAMP NULL,
    CONSTRAINT fk_apertura_caja FOREIGN KEY (id_caja) REFERENCES caja(id_caja),
    CONSTRAINT fk_apertura_cajero FOREIGN KEY (id_cajero) REFERENCES cajero(id_cajero)
);

CREATE TABLE IF NOT EXISTS servicio_hospitalario (
    id_servicio SERIAL PRIMARY KEY,
    nombre_servicio VARCHAR(150) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS tarifario (
    id_tarifario SERIAL PRIMARY KEY,
    id_servicio INT NOT NULL,
    precio DECIMAL(10,2) NOT NULL CHECK (precio >= 0),
    CONSTRAINT fk_tarifario_servicio FOREIGN KEY (id_servicio) REFERENCES servicio_hospitalario(id_servicio)
);

CREATE TABLE IF NOT EXISTS comprobante_pago (
    id_comprobante SERIAL PRIMARY KEY,
    tipo VARCHAR(20) NOT NULL,
    serie VARCHAR(10) NOT NULL,
    numero VARCHAR(20) NOT NULL,
    CONSTRAINT uq_comprobante UNIQUE (tipo, serie, numero)
);

CREATE TABLE IF NOT EXISTS facturacion (
    id_facturacion SERIAL PRIMARY KEY,
    id_paciente INT NOT NULL,
    id_comprobante INT NOT NULL UNIQUE,
    fecha_emision TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    monto_total DECIMAL(10,2) NOT NULL CHECK (monto_total >= 0),
    CONSTRAINT fk_facturacion_paciente FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    CONSTRAINT fk_facturacion_comprobante FOREIGN KEY (id_comprobante) REFERENCES comprobante_pago(id_comprobante)
);

CREATE TABLE IF NOT EXISTS detalle_facturacion (
    id_detalle_facturacion SERIAL PRIMARY KEY,
    id_facturacion INT NOT NULL,
    id_tarifario INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_detfact_facturacion FOREIGN KEY (id_facturacion) REFERENCES facturacion(id_facturacion) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_detfact_tarifario FOREIGN KEY (id_tarifario) REFERENCES tarifario(id_tarifario)
);

CREATE TABLE IF NOT EXISTS metodo_pago (
    id_metodo SERIAL PRIMARY KEY,
    nombre_metodo VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS pago (
    id_pago SERIAL PRIMARY KEY,
    id_facturacion INT NOT NULL,
    id_apertura INT NOT NULL,
    id_metodo INT NOT NULL,
    monto DECIMAL(10,2) NOT NULL CHECK (monto > 0),
    fecha_pago TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pago_facturacion FOREIGN KEY (id_facturacion) REFERENCES facturacion(id_facturacion),
    CONSTRAINT fk_pago_apertura FOREIGN KEY (id_apertura) REFERENCES apertura_caja(id_apertura),
    CONSTRAINT fk_pago_metodo FOREIGN KEY (id_metodo) REFERENCES metodo_pago(id_metodo)
);