-- =============================================================
--  JUEGO DB - Script actualizado
--  Servicios: JugadorService, NivelService, PartidaService,
--             CombinacionService, ReglaService
--  Motor: MySQL 8.x
-- =============================================================

CREATE DATABASE IF NOT EXISTS juego_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE juego_db;

-- =============================================================
--  JugadorService → tabla jugador
--  guardarJugador(), buscarPorApodo(), apodoDisponible(), eliminarJugador()
-- =============================================================
CREATE TABLE IF NOT EXISTS jugador (
    id               VARCHAR(36)  NOT NULL,
    apodo            VARCHAR(10)  NOT NULL,
    sesion_activa    BOOLEAN      NOT NULL DEFAULT FALSE,
    fecha_registro   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_jugador       PRIMARY KEY (id),
    CONSTRAINT uq_jugador_apodo UNIQUE (apodo)
);

-- =============================================================
--  NivelService → tablas nivel y config_nivel
--  obtenerNivel(), listarNiveles(), guardarConfigNivel()
-- =============================================================
CREATE TABLE IF NOT EXISTS nivel (
    id                   VARCHAR(36)  NOT NULL,
    nombre               VARCHAR(20)  NOT NULL,
    vidas                INT          NOT NULL,
    tiene_temporizador   BOOLEAN      NOT NULL DEFAULT FALSE,
    puntuacion_base      INT          NOT NULL DEFAULT 0,

    CONSTRAINT pk_nivel        PRIMARY KEY (id),
    CONSTRAINT uq_nivel_nombre UNIQUE (nombre)
);

CREATE TABLE IF NOT EXISTS config_nivel (
    id                       VARCHAR(36)  NOT NULL,
    id_nivel                 VARCHAR(36)  NOT NULL,
    max_intentos             INT          NOT NULL,
    max_pistas               INT          NOT NULL DEFAULT 0,
    tiempo_seg               INT          NULL,
    intentos_pista_trigger   INT          NOT NULL DEFAULT 5,
    top_records              INT          NOT NULL DEFAULT 5,

    CONSTRAINT pk_config_nivel PRIMARY KEY (id),
    CONSTRAINT fk_config_nivel
        FOREIGN KEY (id_nivel) REFERENCES nivel (id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =============================================================
--  PartidaService → tabla partida
--  guardarPartida(), obtenerPartidaActiva(), finalizarPartida(), reiniciarPartida()
-- =============================================================
CREATE TABLE IF NOT EXISTS partida (
    id                VARCHAR(36)  NOT NULL,
    apodo_jugador     VARCHAR(10)  NOT NULL,
    id_nivel          VARCHAR(36)  NOT NULL,
    vidas_restantes   INT          NOT NULL,
    puntuacion        INT          NOT NULL DEFAULT 0,
    intentos_fallidos INT          NOT NULL DEFAULT 0,
    activa            BOOLEAN      NOT NULL DEFAULT TRUE,
    fecha_inicio      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_partida PRIMARY KEY (id),
    CONSTRAINT fk_partida_jugador
        FOREIGN KEY (apodo_jugador) REFERENCES jugador (apodo)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_partida_nivel
        FOREIGN KEY (id_nivel) REFERENCES nivel (id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- =============================================================
--  CombinacionService → tabla combinacion_entrada
--  guardarCombinacion(), listarPorPartida(), validarCombinacion()
-- =============================================================
CREATE TABLE IF NOT EXISTS combinacion_entrada (
    id           VARCHAR(36)  NOT NULL,
    id_partida   VARCHAR(36)  NOT NULL,
    letras       VARCHAR(6)   NOT NULL,
    numeros      VARCHAR(5)   NOT NULL,
    es_correcta  BOOLEAN      NOT NULL DEFAULT FALSE,
    timestamp    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_combinacion PRIMARY KEY (id),
    CONSTRAINT fk_combinacion_partida
        FOREIGN KEY (id_partida) REFERENCES partida (id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =============================================================
--  ReglaService → tabla regla
--  guardarRegla(), obtenerReglaPorPartida(), generarNuevaRegla(), desactivarRegla()
-- =============================================================
CREATE TABLE IF NOT EXISTS regla (
    id              VARCHAR(36)   NOT NULL,
    id_partida      VARCHAR(36)   NOT NULL,
    descripcion     TEXT          NOT NULL,
    valor_secreto   VARCHAR(100)  NOT NULL,
    activa          BOOLEAN       NOT NULL DEFAULT TRUE,
    fecha_creacion  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_regla PRIMARY KEY (id),
    CONSTRAINT fk_regla_partida
        FOREIGN KEY (id_partida) REFERENCES partida (id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- =============================================================
--  ÍNDICES
-- =============================================================
CREATE INDEX idx_partida_jugador     ON partida            (apodo_jugador);
CREATE INDEX idx_partida_nivel       ON partida            (id_nivel);
CREATE INDEX idx_partida_activa      ON partida            (activa);
CREATE INDEX idx_combinacion_partida ON combinacion_entrada(id_partida);
CREATE INDEX idx_regla_partida       ON regla              (id_partida);
CREATE INDEX idx_regla_activa        ON regla              (activa);

-- =============================================================
--  DATOS INICIALES
-- =============================================================
INSERT INTO nivel (id, nombre, vidas, tiene_temporizador, puntuacion_base) VALUES
    ('nivel-facil-001',   'FACIL',   5, FALSE, 100),
    ('nivel-dificil-001', 'DIFICIL', 3, TRUE,  200);

INSERT INTO config_nivel (id, id_nivel, max_intentos, max_pistas, tiempo_seg, intentos_pista_trigger, top_records) VALUES
    ('config-facil-001',   'nivel-facil-001',   20, 2, NULL, 5, 5),
    ('config-dificil-001', 'nivel-dificil-001', 10, 0, 120,  0, 5);

-- =============================================================
--  FIN DEL SCRIPT
-- =============================================================