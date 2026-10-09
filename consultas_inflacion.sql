-- ============================================================
-- consultas_inflacion.sql
-- Mini proyecto: inflación en Colombia (IPC DANE, agosto 2026)
-- Base: inflacion.db (DB Browser for SQLite)
-- Tablas: ipc_divisiones, ipc_agosto_anios, ipc_ciudad_division_anual,
--         ipc_series, gobiernos
-- Ejecutar UNA consulta a la vez (selecciónala y Ctrl+Enter).
-- ============================================================


-- ============================================================
-- BLOQUE 1: PREGUNTAS SIMPLES (Q1 a Q4)
-- ============================================================

-- Q1. ¿Cuántas divisiones de gasto hay (sin contar el Total)?
SELECT COUNT(division) AS n_divisiones
FROM ipc_divisiones
WHERE division <> 'Total';

-- Q2. ¿Qué división tuvo la mayor variación anual?
SELECT division, var_anual
FROM ipc_divisiones
WHERE division <> 'Total'
ORDER BY var_anual DESC
LIMIT 1;

-- Q3. ¿Qué división aportó más a la inflación total (contribución anual)?
SELECT division, contrib_anual
FROM ipc_divisiones
WHERE division <> 'Total'
ORDER BY contrib_anual DESC
LIMIT 1;

-- Q3b. Contribución calculada a mano
SELECT division,
       var_anual,
       contrib_anual,
       (ponderacion * var_anual) / 100 AS contrib_cal
FROM ipc_divisiones;

-- Q4. ¿Qué agosto tuvo la mayor inflación anual?
SELECT anio, var_anual
FROM ipc_agosto_anios
ORDER BY var_anual DESC
LIMIT 1;


-- ============================================================
-- BLOQUE 2: CIUDADES (Q5 a Q7)
-- ============================================================

-- Q5. Ciudad con la mayor inflación anual total
SELECT ciudad, var_anual
FROM ipc_ciudad_division_anual
WHERE division = 'Total' AND ciudad <> 'Total Ipc'
ORDER BY var_anual DESC
LIMIT 1;

-- Q6. División con la mayor variación en Bogotá
SELECT division, var_anual
FROM ipc_ciudad_division_anual
WHERE ciudad = 'Bogotá, D.C.' AND division <> 'Total'
ORDER BY var_anual DESC
LIMIT 1;

-- Q7. Ciudad con la mayor diferencia entre su división más alta y la más baja
SELECT ciudad,
       MAX(var_anual) - MIN(var_anual) AS diferencia
FROM ipc_ciudad_division_anual
WHERE ciudad <> 'Total Ipc' AND division <> 'Total'
GROUP BY ciudad
ORDER BY diferencia DESC
LIMIT 1;


-- ============================================================
-- BLOQUE 3: EJERCICIOS DE PRÁCTICA
-- ============================================================

-- ---------- Nivel 1: WHERE, ORDER BY, LIMIT ----------

-- Ej 1. ¿Cuántas ciudades distintas hay (sin el total nacional)?
SELECT COUNT(DISTINCT ciudad) AS ciudades_dis
FROM ipc_ciudad_division_anual
WHERE ciudad <> 'Total Ipc';

-- Ej 2. Las 5 ciudades con menor inflación total
SELECT ciudad, var_anual
FROM ipc_ciudad_division_anual
WHERE ciudad <> 'Total Ipc' AND division = 'Total'
ORDER BY var_anual ASC
LIMIT 5;

-- Ej 3. Las 3 divisiones con mayor ponderación
SELECT division, ponderacion
FROM ipc_divisiones
WHERE division <> 'Total'
ORDER BY ponderacion DESC
LIMIT 3;

-- Ej 4. ¿En cuántos agostos la var_anual fue mayor a 5?
SELECT COUNT(*) AS n_agostos
FROM ipc_agosto_anios
WHERE var_anual > 5;

-- ---------- Nivel 2: resumir sin agrupar ----------

-- Ej 5. Promedio de var_anual de los 10 agostos
SELECT AVG(var_anual) AS prom
FROM ipc_agosto_anios;

-- Ej 6. Máximo y mínimo de var_anual de los agostos
SELECT MAX(var_anual) AS maximo,
       MIN(var_anual) AS minimo
FROM ipc_agosto_anios;

-- ---------- Nivel 3: GROUP BY ----------

-- Ej 7. ¿Cuántas filas tiene cada serie?
SELECT serie, COUNT(*) AS n_filas
FROM ipc_series
GROUP BY serie;

-- Ej 8. Promedio de var_anual por serie, de mayor a menor
SELECT serie, AVG(var_anual) AS avg_var
FROM ipc_series
GROUP BY serie
ORDER BY avg_var DESC;

-- ---------- Nivel 4 ----------

-- Ej 9. Mínimo y máximo de var_anual por serie
SELECT serie,
       MIN(var_anual) AS min_var,
       MAX(var_anual) AS max_var
FROM ipc_series
GROUP BY serie;

-- Ej 10. Promedio de var_anual por serie, desde 2020 en adelante
SELECT serie, AVG(var_anual) AS avg_var
FROM ipc_series
WHERE anio >= 2020
GROUP BY serie
ORDER BY avg_var DESC;

-- Ej 11. Promedio de var_anual por año, serie 'servicios'
SELECT anio, AVG(var_anual) AS avg_var
FROM ipc_series
WHERE serie = 'servicios'
GROUP BY anio
ORDER BY anio;

-- Ej 12. ¿En qué año 'energeticos' tuvo el mayor promedio de var_anual?
SELECT anio, AVG(var_anual) AS avg_var
FROM ipc_series
WHERE serie = 'energeticos'
GROUP BY anio
ORDER BY avg_var DESC
LIMIT 1;

-- ---------- Nivel 5: HAVING y GROUP BY con dos columnas ----------

-- Ej 14. Meses con var_anual mayor a 10, por serie
SELECT serie, COUNT(*) AS n_meses
FROM ipc_series
WHERE var_anual > 10
GROUP BY serie;

-- Ej 15. Series con promedio mayor a 5 desde 2020
SELECT serie, AVG(var_anual) AS avg_var
FROM ipc_series
WHERE anio >= 2020
GROUP BY serie
HAVING AVG(var_anual) > 5
ORDER BY avg_var DESC;

-- Ej 16. Promedio de var_anual por serie y por año, de 2022 a 2024
SELECT serie, anio, AVG(var_anual) AS avg_var
FROM ipc_series
WHERE anio BETWEEN 2022 AND 2024
GROUP BY serie, anio
ORDER BY serie, anio;


-- ============================================================
-- BLOQUE 4: PREGUNTA AVANZADA - INFLACIÓN POR GOBIERNO
-- ============================================================

-- Tabla de gobiernos (ejecutar UNA sola vez, luego Write Changes / Ctrl+S)
-- CREATE TABLE gobiernos (nombre TEXT, inicio TEXT, fin TEXT);
-- INSERT INTO gobiernos VALUES
--   ('Uribe II', '2009-01', '2010-07'),
--   ('Santos I',  '2010-08', '2014-07'),
--   ('Santos II', '2014-08', '2018-07'),
--   ('Duque',     '2018-08', '2022-07'),
--   ('Petro',     '2022-08', '2026-07');

-- Inflación anual promedio (serie sin_alimentos) por gobierno
-- n_meses: cuántos meses con dato entran al promedio
SELECT g.nombre,
       AVG(s.var_anual)   AS prom,
       COUNT(s.var_anual) AS n_meses
FROM ipc_series s
JOIN gobiernos g ON s.periodo BETWEEN g.inicio AND g.fin
WHERE s.serie = 'sin_alimentos'
GROUP BY g.nombre
ORDER BY prom DESC;
-- Resultado visto: Petro 7.66, Santos II 4.77, Duque 3.16, Santos I 2.86, Uribe II 2.77
