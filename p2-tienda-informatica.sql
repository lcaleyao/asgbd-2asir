-- =====================================================================
-- PRÁCTICA: SISTEMA DE GESTIÓN DE TIENDA DE INFORMÁTICA Y REPARACIONES
-- Módulo: Administración y Gestión de Bases de Datos (2º ASIR)
-- =====================================================================

-- ---------------------------------------------------------------------
-- PARTE 1: CREACIÓN DE LA BASE DE DATOS Y LAS TABLAS
-- ---------------------------------------------------------------------

-- Eliminar la base de datos si ya existe para empezar desde cero de forma limpia
DROP DATABASE IF EXISTS tienda_informatica;

-- Crear la base de datos con soporte para caracteres UTF-8
CREATE DATABASE tienda_informatica CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Seleccionar la base de datos para trabajar sobre ella
USE tienda_informatica;

-- 1. Tabla fabricantes
CREATE TABLE fabricantes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    pais VARCHAR(50) NOT NULL
) ENGINE=InnoDB;

-- 2. Tabla articulos
CREATE TABLE articulos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    fabricante_id INT  NOT NULL,
    CONSTRAINT fk_articulos_fabricante FOREIGN KEY (fabricante_id) 
        REFERENCES fabricantes(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 3. Tabla tecnicos
CREATE TABLE tecnicos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    especialidad VARCHAR(50) NOT NULL,
    salario DECIMAL(10,2) NOT NULL
) ENGINE=InnoDB;

-- 4. Tabla reparaciones
CREATE TABLE reparaciones (
    id INT  AUTO_INCREMENT PRIMARY KEY,
    descripcion_averia VARCHAR(200) NOT NULL,
    coste_reparacion DECIMAL(10,2) NOT NULL,
    tecnico_id INT  NOT NULL,
    CONSTRAINT fk_reparaciones_tecnico FOREIGN KEY (tecnico_id) 
        REFERENCES tecnicos(id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;


-- ---------------------------------------------------------------------
-- INSERCIÓN DE DATOS INICIALES
-- ---------------------------------------------------------------------

-- Inserción de fabricantes
INSERT INTO fabricantes (id, nombre, pais) VALUES
(1, 'Kingston', 'Estados Unidos'),
(2, 'Asus', 'Taiwán'),
(3, 'Samsung', 'Corea del Sur'),
(4, 'Logitech', 'Suiza'),
(5, 'Intel', 'Estados Unidos');

-- Inserción de artículos
INSERT INTO articulos (id, nombre, precio, fabricante_id) VALUES
(1, 'Memoria RAM 16GB DDR4', 45.50, 1),
(2, 'SSD NVMe 1TB', 79.99, 1),
(3, 'Placa Base ROG Strix', 185.00, 2),
(4, 'Monitor 27" IPS 144Hz', 249.00, 2),
(5, 'Monitor 32" Curved', 320.00, 3),
(6, 'Ratón Óptico Inalámbrico', 29.99, 4),
(7, 'Teclado Mecánico RGB', 89.90, 4),
(8, 'Procesador Core i7', 310.00, 5);

-- Inserción de técnicos
INSERT INTO tecnicos (id, nombre, especialidad, salario) VALUES
(1, 'Carlos Pérez', 'Hardware', 1800.00),
(2, 'Ana Gómez', 'Redes y Servidores', 2100.00),
(3, 'Luis Martínez', 'Portátiles', 1650.00),
(4, 'Marta Ruiz', 'Movilidad y Tablets', 1750.00);

-- Inserción de reparaciones
INSERT INTO reparaciones (id, descripcion_averia, coste_reparacion, tecnico_id) VALUES
(1, 'Sustitución de pantalla rota', 120.50, 3),
(2, 'Cambio de fuente de alimentación', 65.00, 1),
(3, 'Recuperación de datos en disco dañado', 150.00, 2),
(4, 'Limpieza interna y cambio de pasta térmica', 45.00, 1),
(5, 'Sustitución de conector de carga', 50.00, 3),
(6, 'Ampliación de RAM y formateo', 80.00, 4);


-- ---------------------------------------------------------------------
-- PARTE 2: BATERÍA DE CONSULTAS (SIN USAR JOIN)
-- ---------------------------------------------------------------------

-- Consulta 1: Muestra el nombre y el precio de todos los artículos ordenados de forma descendente por su precio.
SELECT nombre, precio 
FROM articulos 
ORDER BY precio DESC;


-- Consulta 2: Muestra los nombres de los fabricantes cuyo país sea "Estados Unidos".
SELECT nombre 
FROM fabricantes 
WHERE pais = 'Estados Unidos';


-- Consulta 3: Muestra todos los datos de aquellos artículos cuyo precio sea mayor o igual a 100 y menor o igual a 300.
SELECT id, nombre, precio, fabricante_id 
FROM articulos 
WHERE precio BETWEEN 100 AND 300;


-- Consulta 4: Calcula el precio medio de todos los artículos almacenados en la tabla articulos.
SELECT AVG(precio) AS precio_medio 
FROM articulos;


-- Consulta 5: Muestra el identificador del fabricante y el número de artículos que tiene cada uno.
SELECT fabricante_id, COUNT(*) AS total_articulos 
FROM articulos 
GROUP BY fabricante_id;


-- Consulta 6: Muestra los tecnico_id que han realizado más de una reparación.
SELECT tecnico_id 
FROM reparaciones 
GROUP BY tecnico_id 
HAVING COUNT(*) > 1;


-- Consulta 7: Muestra el nombre y el precio de los artículos fabricados por empresas de 'Taiwán' (usando subconsulta).
SELECT nombre, precio 
FROM articulos 
WHERE fabricante_id IN (
    SELECT id 
    FROM fabricantes 
    WHERE pais = 'Taiwán'
);


-- Consulta 8: Muestra la descripción y el coste de la reparación más cara registrada (usando subconsulta).
SELECT descripcion_averia, coste_reparacion 
FROM reparaciones 
WHERE coste_reparacion = (
    SELECT MAX(coste_reparacion) 
    FROM reparaciones
);


-- Consulta 9: Muestra el nombre de los técnicos y el importe resultante de sumar a su salario actual un 10% de subida.
SELECT nombre, (salario * 1.10) AS salario_con_subida 
FROM tecnicos;


-- Consulta 10: Muestra el nombre de los técnicos que no han realizado ninguna reparación (usando NOT IN).
SELECT nombre 
FROM tecnicos 
WHERE id NOT IN (
    SELECT DISTINCT tecnico_id 
    FROM reparaciones
);



-- =====================================================================
-- SOLUCIONARIO DE LA PRÁCTICA AVANZADA - Parte 1 sin join
-- =====================================================================

-- Consulta 1: Artículo más caro de cada fabricante (Subconsulta correlacionada)
SELECT nombre, precio 
FROM articulos a1
WHERE precio = (
    SELECT MAX(precio) 
    FROM articulos a2 
    WHERE a2.fabricante_id = a1.fabricante_id
);


-- Consulta 2: Fabricantes sin ningún artículo con precio <= a la media general
SELECT nombre 
FROM fabricantes 
WHERE id NOT IN (
    SELECT fabricante_id 
    FROM articulos 
    WHERE precio <= (SELECT AVG(precio) FROM articulos)
);


-- Consulta 3: Reparaciones con coste superior a la media del propio técnico (Correlacionada)
SELECT descripcion_averia, coste_reparacion 
FROM reparaciones r1
WHERE coste_reparacion > (
    SELECT AVG(coste_reparacion) 
    FROM reparaciones r2 
    WHERE r2.tecnico_id = r1.tecnico_id
);


-- Consulta 4: Técnicos cuya suma de reparaciones supera el doble de su salario
SELECT id, especialidad 
FROM tecnicos 
WHERE (
    SELECT SUM(coste_reparacion) 
    FROM reparaciones 
    WHERE reparaciones.tecnico_id = tecnicos.id
) > (salario * 2);










-- Consulta 5: Fabricante con mayor número de artículos (Tabla derivada / Subconsulta en FROM)
SELECT fabricante_id 
FROM articulos 
GROUP BY fabricante_id 
HAVING COUNT(*) = (
    SELECT MAX(total_arts) 
    FROM (
        SELECT COUNT(*) AS total_arts 
        FROM articulos 
        GROUP BY fabricante_id
    ) AS t_max
);


-- Consulta 6: Técnicos que han reparado pero nunca por encima de 100€
SELECT nombre 
FROM tecnicos 
WHERE id IN (SELECT DISTINCT tecnico_id FROM reparaciones)
  AND id NOT IN (
      SELECT DISTINCT tecnico_id 
      FROM reparaciones 
      WHERE coste_reparacion > 100.00
  );


-- Consulta 7: Técnicos con salario menor que la media de su especialidad (Correlacionada)
SELECT nombre, salario 
FROM tecnicos t1
WHERE salario < (
    SELECT AVG(salario) 
    FROM tecnicos t2 
    WHERE t2.especialidad = t1.especialidad
);


-- Consulta 8: Fabricantes del mismo país que el fabricante del artículo más caro
SELECT nombre 
FROM fabricantes 
WHERE pais = (
    SELECT f.pais 
    FROM fabricantes f 
    JOIN articulos a ON f.id = a.fabricante_id -- (O sin join con subconsulta anidada)
    -- Versión estrictamente sin JOIN:
    -- (SELECT pais FROM fabricantes WHERE id = (SELECT fabricante_id FROM articulos WHERE precio = (SELECT MAX(precio) FROM articulos)))
);
-- Nota: La versión estricta sin JOIN para la Consulta 8 sería:
SELECT nombre 
FROM fabricantes 
WHERE pais = (
    SELECT f.pais 
    FROM fabricantes f 
    WHERE f.id = (
        SELECT fabricante_id 
        FROM articulos 
        WHERE precio = (SELECT MAX(precio) FROM articulos)
    )
);


-- Consulta 9: Artículo más barato de fabricantes de Estados Unidos
SELECT nombre, precio 
FROM articulos 
WHERE fabricante_id IN (
    SELECT id 
    FROM fabricantes 
    WHERE pais = 'Estados Unidos'
)
  AND precio = (
      SELECT MIN(precio) 
      FROM articulos 
      WHERE fabricante_id IN (
          SELECT id 
          FROM fabricantes 
          WHERE pais = 'Estados Unidos'
      )
  );


-- Consulta 10: Técnico con mayor coste acumulado en reparaciones (Usando ORDER BY y LIMIT 1 en subconsulta/agrupación)
SELECT tecnico_id 
FROM reparaciones 
GROUP BY tecnico_id 
ORDER BY SUM(coste_reparacion) DESC 
LIMIT 1;

-- =====================================================================
-- SOLUCIONARIO DE LA PRÁCTICA DE JOINS Y AGREGACIONES
-- =====================================================================

-- Consulta 1: Artículos con precio > 100 y su fabricante
SELECT a.nombre AS articulo, a.precio, f.nombre AS fabricante
FROM articulos a
JOIN fabricantes f ON a.fabricante_id = f.id
WHERE a.precio > 100.00;


-- Consulta 2: Todos los fabricantes y sus artículos (incluso los sin artículos)
SELECT f.nombre AS fabricante, a.nombre AS articulo
FROM fabricantes f
LEFT JOIN articulos a ON f.id = a.fabricante_id;


-- Consulta 3: Fabricantes con precio medio > 150€
SELECT f.nombre AS fabricante, AVG(a.precio) AS precio_medio
FROM fabricantes f
JOIN articulos a ON f.id = a.fabricante_id
GROUP BY f.id, f.nombre
HAVING AVG(a.precio) > 150.00;


-- Consulta 4: Descripción, coste y nombre del técnico de cada reparación
SELECT r.descripcion_averia, r.coste_reparacion, t.nombre AS tecnico
FROM reparaciones r
JOIN tecnicos t ON r.tecnico_id = t.id
ORDER BY r.coste_reparacion DESC;


-- Consulta 5: Técnicos sin reparaciones usando JOIN externo
SELECT t.nombre
FROM tecnicos t
LEFT JOIN reparaciones r ON t.id = r.tecnico_id
WHERE r.id IS NULL;


-- Consulta 6: Técnicos y su recaudación total (con HAVING > 100)
SELECT t.nombre, SUM(r.coste_reparacion) AS total_recaudado
FROM tecnicos t
JOIN reparaciones r ON t.id = r.tecnico_id
GROUP BY t.id, t.nombre
HAVING SUM(r.coste_reparacion) > 100.00;


-- Consulta 7: Artículos y fabricantes de EE.UU. o Taiwán usando IN y JOIN
SELECT a.nombre AS articulo, f.nombre AS fabricante, f.pais
FROM articulos a
JOIN fabricantes f ON a.fabricante_id = f.id
WHERE f.pais IN ('Estados Unidos', 'Taiwán');


-- Consulta 8: Todos los técnicos y el recuento de sus reparaciones (incluyendo ceros)
SELECT t.nombre, COUNT(r.id) AS total_reparaciones
FROM tecnicos t
LEFT JOIN reparaciones r ON t.id = r.tecnico_id
GROUP BY t.id, t.nombre;


-- Consulta 9: Fabricantes con 2 o más artículos
SELECT f.nombre AS fabricante, COUNT(a.id) AS total_articulos
FROM fabricantes f
JOIN articulos a ON f.id = a.fabricante_id
GROUP BY f.id, f.nombre
HAVING COUNT(a.id) >= 2;


-- Consulta 10: Técnico, especialidad y la reparación más costosa por cada uno
SELECT t.nombre, t.especialidad, MAX(r.coste_reparacion) AS reparacion_mas_cara
FROM tecnicos t
JOIN reparaciones r ON t.id = r.tecnico_id
GROUP BY t.id, t.nombre, t.especialidad;