
-- ======================================================================
-- PACKAGE: PKG_ALUMNOS
-- PROYECTO: LIBRO DE CLASES DIGITAL
-- DESCRIPCION: Consultas de alumnos y sus matriculas
-- ======================================================================


-- ======================================================================
-- 1. PACKAGE SPECIFICATION
-- Declaracion de procedimientos y funciones publicas
-- ======================================================================

CREATE OR REPLACE PACKAGE pkg_alumnos
IS

    -- Mostrar ficha de un alumno y sus matriculas
    PROCEDURE sp_ficha_alumno(
        p_id_alumno IN alumnos.id_alumno%TYPE
    );

    -- Listar todos los alumnos
    PROCEDURE sp_listar_alumnos;

    -- Contar matriculas de un alumno
    FUNCTION fn_total_matriculas_alumno(
        p_id_alumno IN alumnos.id_alumno%TYPE
    ) RETURN NUMBER;

    -- Contar todos los alumnos
    FUNCTION fn_total_alumnos
    RETURN NUMBER;

END pkg_alumnos;
/


-- ======================================================================
-- 2. PACKAGE BODY
-- Implementacion de las operaciones publicas y privadas
-- ======================================================================

CREATE OR REPLACE PACKAGE BODY pkg_alumnos
IS

    -- ==================================================================
    -- FUNCION PRIVADA: VERIFICAR SI EXISTE UN ALUMNO
    -- No aparece en la specification, por lo que solo puede utilizarse
    -- dentro de este package.
    -- ==================================================================

    FUNCTION fn_existe_alumno(
        p_id_alumno IN alumnos.id_alumno%TYPE
    ) RETURN BOOLEAN
    IS
        v_cantidad NUMBER;
    BEGIN

        SELECT COUNT(*)
        INTO v_cantidad
        FROM alumnos
        WHERE id_alumno = p_id_alumno;

        -- Si no existe el alumno, devuelve FALSE
        IF v_cantidad = 0 THEN
            RETURN FALSE;

        -- Si existe exactamente un alumno, devuelve TRUE
        ELSIF v_cantidad = 1 THEN
            RETURN TRUE;

        -- Control defensivo de duplicados
        -- La PRIMARY KEY de id_alumno ya impide esta situacion
        ELSE
            RAISE_APPLICATION_ERROR(
                -20001,
                'Error: existen alumnos duplicados con el mismo ID'
            );
        END IF;

    END fn_existe_alumno;


    -- ==================================================================
    -- 1. PROCEDIMIENTO PUBLICO CON PARAMETROS
    -- MOSTRAR FICHA DE UN ALUMNO Y SUS MATRICULAS
    -- ==================================================================

    PROCEDURE sp_ficha_alumno(
        p_id_alumno IN alumnos.id_alumno%TYPE
    )
    IS
        v_total_matriculas NUMBER := 0;
    BEGIN

        -- Validar que el alumno exista
        IF NOT fn_existe_alumno(p_id_alumno) THEN
            DBMS_OUTPUT.PUT_LINE(
                'No existe el alumno con ID: ' || p_id_alumno
            );
            RETURN;
        END IF;

        DBMS_OUTPUT.PUT_LINE('====================================');
        DBMS_OUTPUT.PUT_LINE('FICHA DEL ALUMNO');
        DBMS_OUTPUT.PUT_LINE('====================================');

        -- Mostrar los datos personales
        FOR datos IN (
            SELECT
                id_alumno,
                rut,
                nombres,
                apellidos,
                fecha_nac,
                email
            FROM alumnos
            WHERE id_alumno = p_id_alumno
        )
        LOOP

            DBMS_OUTPUT.PUT_LINE('ID: ' || datos.id_alumno);
            DBMS_OUTPUT.PUT_LINE('RUT: ' || datos.rut);
            DBMS_OUTPUT.PUT_LINE('Nombre: ' || datos.nombres || ' ' || datos.apellidos);
            DBMS_OUTPUT.PUT_LINE('Fecha de nacimiento: ' || TO_CHAR(datos.fecha_nac, 'DD/MM/YYYY'));
            DBMS_OUTPUT.PUT_LINE('Email: ' || datos.email);

        END LOOP;

        DBMS_OUTPUT.PUT_LINE('------------------------------------');
        DBMS_OUTPUT.PUT_LINE('MATRICULAS DEL ALUMNO');
        DBMS_OUTPUT.PUT_LINE('------------------------------------');

        -- Obtener los cursos en los que esta matriculado
        FOR datos IN (
            SELECT
                m.id_matricula,
                m.fecha_matr,
                c.id_curso,
                n.nombre AS nivel,
                c.letra,
                c.anio_lectivo
            FROM matriculas m
            JOIN cursos c
                ON c.id_curso = m.id_curso
            JOIN niveles n
                ON n.id_nivel = c.id_nivel
            WHERE m.id_alumno = p_id_alumno
            ORDER BY c.anio_lectivo, c.id_curso
        )
        LOOP

            -- Contar las matriculas encontradas
            v_total_matriculas := v_total_matriculas + 1;

            DBMS_OUTPUT.PUT_LINE('Matricula ID: ' || datos.id_matricula);
            DBMS_OUTPUT.PUT_LINE('Curso: ' || datos.nivel || ' ' ||datos.letra || ' (' || datos.anio_lectivo || ')');
            DBMS_OUTPUT.PUT_LINE('Fecha de matricula: ' || TO_CHAR(datos.fecha_matr, 'DD/MM/YYYY'));

        END LOOP;

        -- Mostrar mensaje si no tiene matriculas
        IF v_total_matriculas = 0 THEN
            DBMS_OUTPUT.PUT_LINE(
                'El alumno no tiene matriculas registradas'
            );
        END IF;

        DBMS_OUTPUT.PUT_LINE(
            'TOTAL DE MATRICULAS: ' || v_total_matriculas
        );

    END sp_ficha_alumno;


    -- ==================================================================
    -- 2. PROCEDIMIENTO PUBLICO SIN PARAMETROS
    -- LISTAR TODOS LOS ALUMNOS REGISTRADOS
    -- ==================================================================

    PROCEDURE sp_listar_alumnos
    IS
        v_total NUMBER := 0;
    BEGIN

        DBMS_OUTPUT.PUT_LINE('====================================');
        DBMS_OUTPUT.PUT_LINE('LISTADO GENERAL DE ALUMNOS');
        DBMS_OUTPUT.PUT_LINE('====================================');

        -- Recorrer todos los alumnos registrados
        FOR datos IN (
            SELECT
                id_alumno,
                rut,
                nombres,
                apellidos
            FROM alumnos
            ORDER BY apellidos, nombres
        )
        LOOP

            -- Incrementar el contador por cada alumno
            v_total := v_total + 1;

            DBMS_OUTPUT.PUT_LINE('ID: ' || datos.id_alumno);
            DBMS_OUTPUT.PUT_LINE('Nombre: ' || datos.nombres);
            DBMS_OUTPUT.PUT_LINE('Apellido: ' || datos.apellidos);
            DBMS_OUTPUT.PUT_LINE('RUT: ' || datos.rut);

        END LOOP;

        -- Mostrar el total de alumnos
        DBMS_OUTPUT.PUT_LINE('------------------------------------');
        DBMS_OUTPUT.PUT_LINE('TOTAL DE ALUMNOS: ' || v_total);

    END sp_listar_alumnos;


    -- ==================================================================
    -- 3. FUNCION PUBLICA CON PARAMETROS
    -- CONTAR LAS MATRICULAS DE UN ALUMNO
    -- ==================================================================

    FUNCTION fn_total_matriculas_alumno(
        p_id_alumno IN alumnos.id_alumno%TYPE
    ) RETURN NUMBER
    IS
        v_total NUMBER;
    BEGIN

        -- Contar las matriculas asociadas al alumno
        SELECT COUNT(*)
        INTO v_total
        FROM matriculas
        WHERE id_alumno = p_id_alumno;

        -- Devolver la cantidad encontrada
        RETURN v_total;

    END fn_total_matriculas_alumno;


    -- ==================================================================
    -- 4. FUNCION PUBLICA SIN PARAMETROS
    -- CONTAR TODOS LOS ALUMNOS REGISTRADOS
    -- ==================================================================

    FUNCTION fn_total_alumnos
    RETURN NUMBER
    IS
        v_total NUMBER;
    BEGIN

        -- Contar todos los alumnos
        SELECT COUNT(*)
        INTO v_total
        FROM alumnos;

        -- Devolver el total de alumnos
        RETURN v_total;

    END fn_total_alumnos;

END pkg_alumnos;
/


-- ======================================================================
-- 3. PRUEBAS DEL PACKAGE
-- Ejecutar despues de compilar la specification y el body
-- ======================================================================


-- PRUEBA 1: Mostrar la ficha de un alumno existente
BEGIN
    pkg_alumnos.sp_ficha_alumno(1);
END;
/


-- PRUEBA 2: Mostrar mensaje si el alumno no existe
BEGIN
    pkg_alumnos.sp_ficha_alumno(999);
END;
/


-- PRUEBA 3: Listar todos los alumnos
BEGIN
    pkg_alumnos.sp_listar_alumnos;
END;
/


-- PRUEBA 4: Contar las matriculas de un alumno
-- DUAL permite evaluar una funcion y mostrar su resultado en una fila,
-- sin consultar directamente una tabla del proyecto desde este SELECT.

SELECT pkg_alumnos.fn_total_matriculas_alumno(1)
    AS total_matriculas
FROM dual;


-- PRUEBA 5: Contar todos los alumnos
SELECT pkg_alumnos.fn_total_alumnos()
    AS total_alumnos
FROM dual;


