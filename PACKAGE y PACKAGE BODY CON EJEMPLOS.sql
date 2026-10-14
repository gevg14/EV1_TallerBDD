SET SERVEROUTPUT ON;

CREATE OR REPLACE PACKAGE pkg_gestion_academica
IS

    -- Procedimiento publico CON parametros
    PROCEDURE sp_listar_alumnos_curso(
        p_id_curso IN cursos.id_curso%TYPE
    );

    -- Procedimiento publico SIN parametros
    PROCEDURE sp_resumen_matriculas;

    -- Funcion publica CON parametros
    FUNCTION fn_promedio_asignatura(
        p_id_matricula IN matriculas.id_matricula%TYPE,
        p_id_carga IN carga_docente.id_carga%TYPE
    ) RETURN NUMBER;

    -- Funcion publica SIN parametros
    FUNCTION fn_total_matriculas
    RETURN NUMBER;

END pkg_gestion_academica;
/




CREATE OR REPLACE PACKAGE BODY pkg_gestion_academica
IS

    -- =========================================================
    -- FUNCION PRIVADA: verificar si existe un curso
    -- =========================================================

    FUNCTION fn_existe_curso(
        p_id_curso IN cursos.id_curso%TYPE
    ) RETURN NUMBER
    IS
        v_existe NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_existe
        FROM cursos
        WHERE id_curso = p_id_curso;

        RETURN v_existe;
    END fn_existe_curso;


    -- =========================================================
    -- 1. PROCEDIMIENTO PUBLICO CON PARAMETROS
    -- =========================================================

    PROCEDURE sp_listar_alumnos_curso(
        p_id_curso IN cursos.id_curso%TYPE
    )
    IS
        v_existe NUMBER;
        v_contador NUMBER := 0;
    BEGIN
        -- Utilizamos la funcion privada
        v_existe := fn_existe_curso(p_id_curso);

        IF v_existe = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No existe el curso ID ' || p_id_curso);
            RETURN;
        END IF;

        DBMS_OUTPUT.PUT_LINE('ALUMNOS DEL CURSO ID ' || p_id_curso);

        FOR r IN (
            SELECT a.id_alumno, a.nombres, a.apellidos
            FROM matriculas m
            JOIN alumnos a ON a.id_alumno = m.id_alumno
            WHERE m.id_curso = p_id_curso
            ORDER BY a.apellidos, a.nombres
        ) LOOP

            v_contador := v_contador + 1;

            DBMS_OUTPUT.PUT_LINE(
                r.id_alumno || ' - ' || r.nombres || ' ' || r.apellidos
            );

        END LOOP;

        DBMS_OUTPUT.PUT_LINE('Total matriculados: ' || v_contador);

    END sp_listar_alumnos_curso;


    -- =========================================================
    -- 2. PROCEDIMIENTO PUBLICO SIN PARAMETROS
    -- =========================================================

    PROCEDURE sp_resumen_matriculas
    IS
        v_total NUMBER := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('RESUMEN DE MATRICULAS POR CURSO');

        FOR r IN (
            SELECT
                c.id_curso,
                n.nombre AS nivel,
                c.letra,
                c.anio_lectivo,
                COUNT(m.id_matricula) AS cantidad
            FROM cursos c
            JOIN niveles n
                ON n.id_nivel = c.id_nivel
            LEFT JOIN matriculas m
                ON m.id_curso = c.id_curso
            GROUP BY
                c.id_curso,
                n.nombre,
                c.letra,
                c.anio_lectivo
            ORDER BY
                c.anio_lectivo,
                c.id_curso
        ) LOOP

            DBMS_OUTPUT.PUT_LINE(
                'Curso ' || r.id_curso ||
                ' (' || r.nivel || ' ' ||
                r.letra || ', ' ||
                r.anio_lectivo || '): ' ||
                r.cantidad || ' matricula(s)'
            );

            v_total := v_total + r.cantidad;

        END LOOP;

        DBMS_OUTPUT.PUT_LINE('TOTAL GENERAL: ' || v_total);

    END sp_resumen_matriculas;


    -- =========================================================
    -- 3. FUNCION PUBLICA CON PARAMETROS
    -- =========================================================

    FUNCTION fn_promedio_asignatura(
        p_id_matricula IN matriculas.id_matricula%TYPE,
        p_id_carga IN carga_docente.id_carga%TYPE
    ) RETURN NUMBER
    IS
        v_promedio NUMBER;
    BEGIN

        SELECT ROUND(
            SUM(c.nota * c.ponderacion) /
            NULLIF(SUM(c.ponderacion), 0),
            2
        )
        INTO v_promedio
        FROM calificaciones c
        JOIN matriculas m
            ON m.id_matricula = c.id_matricula
        JOIN carga_docente cd
            ON cd.id_carga = c.id_carga
        WHERE c.id_matricula = p_id_matricula
          AND c.id_carga = p_id_carga
          AND m.id_curso = cd.id_curso;

        RETURN v_promedio;

    END fn_promedio_asignatura;


    -- =========================================================
    -- 4. FUNCION PUBLICA SIN PARAMETROS
    -- =========================================================

    FUNCTION fn_total_matriculas
    RETURN NUMBER
    IS
        v_total NUMBER;
    BEGIN

        SELECT COUNT(*)
        INTO v_total
        FROM matriculas;

        RETURN v_total;

    END fn_total_matriculas;

END pkg_gestion_academica;
/


-- ==========================================================

-- EJEMPLOS DE USO DEL PAQUETE pkg_gestion_academica

-- Procedimiento con parametros
BEGIN
    pkg_gestion_academica.sp_listar_alumnos_curso(1); -- Listar alumnos del curso con ID 1
END;
/

-- Procedimiento sin parametros
BEGIN
    pkg_gestion_academica.sp_resumen_matriculas; -- Mostrar resumen de matriculas por curso
END;
/

-- Funcion con parametros
SELECT pkg_gestion_academica.fn_promedio_asignatura(1, 1) -- Obtener promedio de la asignatura para la matricula ID 1 y carga docente ID 1
    AS promedio
FROM dual; -- El dual lo utilizamos cuano no necesitamos una tabla especifica

-- Funcion sin parametros
SELECT pkg_gestion_academica.fn_total_matriculas() -- Obtener el total de matriculas
    AS total_matriculas
FROM dual;