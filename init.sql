-- Crear base de datos
CREATE DATABASE IF NOT EXISTS inventario_;
USE inventario_;

-- Tabla de categorías
CREATE TABLE categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT
);

-- Tabla de ítems
CREATE TABLE items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    categoria_id INT,
    cantidad INT DEFAULT 0,
    estado VARCHAR(50),
    FOREIGN KEY (categoria_id) REFERENCES categorias(id)
);

-- Tabla de movimientos de inventario
CREATE TABLE movimientos_inventario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT,
    tipo_movimiento ENUM('Ingreso', 'Salida') NOT NULL,
    cantidad INT NOT NULL,
    fecha_movimiento DATETIME DEFAULT CURRENT_TIMESTAMP,
    observaciones TEXT,
    FOREIGN KEY (item_id) REFERENCES items(id)
);

-- Tabla de alertas
CREATE TABLE alertas_stock (
    id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT,
    mensaje TEXT,
    fecha_alerta DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES items(id)
);

-- TRIGGER: Evitar salidas que dejen stock negativo
DELIMITER $$
CREATE TRIGGER evitar_stock_negativo
BEFORE INSERT ON movimientos_inventario
FOR EACH ROW
BEGIN
    IF NEW.tipo_movimiento = 'Salida' THEN
        DECLARE stock_actual INT;
        SELECT cantidad INTO stock_actual FROM items WHERE id = NEW.item_id;
        IF stock_actual IS NULL OR stock_actual - NEW.cantidad < 0 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error: el movimiento dejaría el stock en negativo';
        END IF;
    END IF;
END$$
DELIMITER ;

-- TRIGGER: Actualizar stock después de movimiento
DELIMITER $$
CREATE TRIGGER actualizar_stock
AFTER INSERT ON movimientos_inventario
FOR EACH ROW
BEGIN
    IF NEW.tipo_movimiento = 'Ingreso' THEN
        UPDATE items SET cantidad = cantidad + NEW.cantidad WHERE id = NEW.item_id;
    ELSE
        UPDATE items SET cantidad = cantidad - NEW.cantidad WHERE id = NEW.item_id;
    END IF;
END$$
DELIMITER ;

-- TRIGGER: Generar alerta si el stock es bajo
DELIMITER $$
CREATE TRIGGER generar_alerta_stock
AFTER UPDATE ON items
FOR EACH ROW
BEGIN
    IF NEW.cantidad < 5 THEN
        INSERT INTO alertas_stock (item_id, mensaje)
        VALUES (NEW.id, CONCAT('ALERTA: Stock bajo para ', NEW.nombre, ' (', NEW.cantidad, ' unidades disponibles)'));
    END IF;
END$$
DELIMITER ;

-- Datos de prueba
INSERT INTO categorias (nombre, descripcion) VALUES ('Mobiliario', 'Mesas, sillas, muebles para eventos');

INSERT INTO items (nombre, descripcion, categoria_id, cantidad, estado) 
VALUES 
('Sillas', 'Sillas blancas plegables', 1, 15, 'Bueno'),
('Mesas', 'Mesas rectangulares plásticas', 1, 10, 'Bueno');

INSERT INTO movimientos_inventario (item_id, tipo_movimiento, cantidad, observaciones)
VALUES 
(1, 'Ingreso', 10, 'Primer ingreso de sillas'),
(1, 'Ingreso', 5, 'Llegaron más sillas'),
(2, 'Ingreso', 10, 'Ingreso inicial de mesas');