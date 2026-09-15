--USANDO RECORD
-------------------------------------------------------------------------------------------------------------------------------
DECLARE
    -- Definición del RECORD personalizado
    TYPE t_docente_contacto IS RECORD (
        rut_docente docente.rut%TYPE,
        nombre_completo VARCHAR2(200),
        correo docente.email%TYPE,
        telefono docente.telefono%TYPE
    );
    
    v_contacto t_docente_contacto;
    v_id_buscar NUMBER := 999; -- ID intencionalmente incorrecto para probar la excepción (Cambiar a 1 para que funcione)
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- BÚSQUEDA DE CONTACTO DOCENTE ---');
    
    -- Poblamos el RECORD con un SELECT INTO
    SELECT rut, nombres || ' ' || apellidos, email, telefono
    INTO v_contacto.rut_docente, v_contacto.nombre_completo, v_contacto.correo, v_contacto.telefono
    FROM docente 
    WHERE id_docente = v_id_buscar;
    
    DBMS_OUTPUT.PUT_LINE('Profesor: ' || v_contacto.nombre_completo);
    DBMS_OUTPUT.PUT_LINE('Email: ' || v_contacto.correo);
    DBMS_OUTPUT.PUT_LINE('Teléfono: ' || v_contacto.telefono);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR TÉCNICO: No se encontró ningún docente con el ID ' || v_id_buscar);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
END;
/

-------------------------------------------------------------------------------------------------------------------------------

--USO DEL VARRAY

DECLARE
    -- Definición del VARRAY (máximo 5 elementos de texto)
    TYPE t_estados_asistencia IS VARRAY(5) OF VARCHAR2(15);
    
    -- Inicializamos el arreglo con un estado inválido ('ENFERMO') para forzar el error
    v_lote_asistencia t_estados_asistencia := t_estados_asistencia('PRESENTE', 'AUSENTE', 'ENFERMO', 'JUSTIFICADO');
    
    e_estado_invalido EXCEPTION; -- Excepción propia
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- PROCESANDO LOTE DE ASISTENCIA ---');
    
    FOR i IN 1..v_lote_asistencia.COUNT LOOP
        -- Regla de negocio: Validar estado
        IF v_lote_asistencia(i) NOT IN ('PRESENTE', 'AUSENTE', 'JUSTIFICADO', 'ATRASADO') THEN
            RAISE e_estado_invalido; -- Disparamos la excepción
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Estado procesado con éxito: ' || v_lote_asistencia(i));
    END LOOP;

EXCEPTION
    WHEN e_estado_invalido THEN
        DBMS_OUTPUT.PUT_LINE('ERROR DE NEGOCIO: Se detectó un estado de asistencia no válido según la normativa del colegio.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
END;
/

-------------------------------------------------------------------------------------------------------------------------------

--USO DE CURSOR

DECLARE
    -- Cursor explícito con parámetro
    CURSOR c_alumnos_curso(p_id_curso NUMBER) IS
        SELECT a.nombres, a.apellidos
        FROM alumnos a
        JOIN matriculas m ON a.id_alumno = m.id_alumno
        WHERE m.id_curso = p_id_curso;
        
    v_nombres alumnos.nombres%TYPE;
    v_apellidos alumnos.apellidos%TYPE;
    v_contador NUMBER := 0;
    
    e_curso_vacio EXCEPTION;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- LISTADO DE ALUMNOS DEL CURSO ---');
    
    OPEN c_alumnos_curso(999); -- Pasamos un ID de curso que no tiene alumnos para forzar el error (usar 1 para ver datos)
    
    LOOP
        FETCH c_alumnos_curso INTO v_nombres, v_apellidos;
        EXIT WHEN c_alumnos_curso%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('- ' || v_nombres || ' ' || v_apellidos);
        v_contador := v_contador + 1;
    END LOOP;
    
    CLOSE c_alumnos_curso;
    
    -- Si el contador sigue en 0, el curso está vacío
    IF v_contador = 0 THEN
        RAISE e_curso_vacio;
    END IF;

EXCEPTION
    WHEN e_curso_vacio THEN
        DBMS_OUTPUT.PUT_LINE('ALERTA: El curso consultado no existe o no tiene alumnos matriculados.');
    WHEN OTHERS THEN
        -- Si ocurre un error, cerramos el cursor por seguridad si quedó abierto
        IF c_alumnos_curso%ISOPEN THEN
            CLOSE c_alumnos_curso;
        END IF;
        DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
END;
/

-------------------------------------------------------------------------------------------------------------------------------

--USO de VARRAY + CURSOR + RECORD

DECLARE
    -- 1. VARRAY: Lista de asignaturas a evaluar
    TYPE t_lista_asignaturas IS VARRAY(3) OF VARCHAR2(100);
    -- Insertamos una asignatura que no tiene notas registradas ('Ciencias Naturales') para disparar la excepción
    v_asignaturas t_lista_asignaturas := t_lista_asignaturas('Matemáticas', 'Lenguaje y Comunicación', 'Ciencias Naturales');
    
    -- 2. RECORD: Para guardar al mejor alumno
    TYPE t_mejor_alumno IS RECORD (
        nombre_completo VARCHAR2(200),
        nota_maxima NUMBER(3,1)
    );
    v_destacado t_mejor_alumno;
    
    -- 3. CURSOR: Trae la nota más alta de una asignatura por nombre
    CURSOR c_mejor_nota(p_asignatura VARCHAR2) IS
        SELECT a.nombres || ' ' || a.apellidos, c.nota
        FROM alumnos a
        JOIN matriculas m ON a.id_alumno = m.id_alumno
        JOIN calificaciones c ON m.id_matricula = c.id_matricula
        JOIN carga_docente cd ON c.id_carga = cd.id_carga
        JOIN asignaturas asig ON cd.id_asignatura = asig.id_asignatura
        WHERE asig.nombre = p_asignatura
        ORDER BY c.nota DESC
        FETCH FIRST 1 ROWS ONLY; -- Trae solo el mejor

    e_sin_calificaciones EXCEPTION;
    v_datos_encontrados BOOLEAN;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- REPORTE DE EXCELENCIA ACADÉMICA ---');
    
    -- Recorremos el VARRAY
    FOR i IN 1..v_asignaturas.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Evaluando asignatura: ' || v_asignaturas(i));
        v_datos_encontrados := FALSE;
        
        -- Abrimos el CURSOR pasándole el valor del VARRAY
        OPEN c_mejor_nota(v_asignaturas(i));
        FETCH c_mejor_nota INTO v_destacado; -- Guardamos en el RECORD
        
        IF c_mejor_nota%FOUND THEN
            v_datos_encontrados := TRUE;
            DBMS_OUTPUT.PUT_LINE('  -> Mejor alumno: ' || v_destacado.nombre_completo || ' (Nota: ' || v_destacado.nota_maxima || ')');
        END IF;
        CLOSE c_mejor_nota;
        
        -- Si no hay notas para esta asignatura, levantamos la excepción
        IF NOT v_datos_encontrados THEN
            RAISE e_sin_calificaciones;
        END IF;
    END LOOP;

EXCEPTION
    WHEN e_sin_calificaciones THEN
        DBMS_OUTPUT.PUT_LINE('  -> ALERTA DE NEGOCIO: Esta asignatura aún no tiene calificaciones registradas en el sistema.');
    WHEN OTHERS THEN
        IF c_mejor_nota%ISOPEN THEN
            CLOSE c_mejor_nota;
        END IF;
        DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
END;
/