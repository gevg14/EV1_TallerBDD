# PKG_ALUMNOS - Libro de Clases Digital

## Que hace este package?

El package `PKG_ALUMNOS` sirve para consultar información de los alumnos que están registrados en nuestra base de datos.

Con este package podemos:

- Ver los datos de un alumno y sus matrículas.
- Mostrar una lista de todos los alumnos.
- Saber cuántas matrículas tiene un alumno.
- Saber cuántos alumnos hay registrados.

Este package solo realiza consultas, por lo que no agrega, modifica ni elimina datos, tenemos pensado mas adelante hacer otro especifico para profesores.

## Procedimientos y funciones

### sp_ficha_alumno

Recibe el ID de un alumno y muestra su información, como el nombre, RUT, fecha de nacimiento y correo.

También muestra los cursos en los que está matriculado y las fechas de matrícula.

Antes de mostrar los datos, utiliza la función privada `fn_existe_alumno` para comprobar que el alumno exista.

Si no existe, muestra un mensaje y termina el procedimiento.

### sp_listar_alumnos

Muestra todos los alumnos registrados en la base de datos.

Utiliza un `FOR` para recorrer los alumnos y mostrar sus nombres, RUT e ID.

También lleva un contador para mostrar cuántos alumnos hay en total.

### fn_total_matriculas_alumno

Recibe el ID de un alumno y devuelve la cantidad de matrículas que tiene registradas.

Para esto utilizamos `COUNT(*)` en la tabla `MATRICULAS`.

Si no encuentra matrículas, devuelve `0`.

### fn_total_alumnos

Cuenta todos los alumnos registrados en la tabla `ALUMNOS`.

No necesita recibir parámetros porque cuenta todos los registros de la tabla.

### fn_existe_alumno (función privada)

Esta función comprueba si existe un alumno utilizando su ID.

Devuelve `TRUE` cuando encuentra al alumno y `FALSE` cuando no lo encuentra.

La función es privada porque está declarada solamente dentro del Package Body. Por eso no podemos llamarla directamente desde fuera del package.

La utilizamos en `sp_ficha_alumno` para evitar buscar información de un alumno que no existe y de paso avisarnos con un mensaje.

## Tablas que utilizamos

El package trabaja con cuatro tablas:

- `ALUMNOS`: contiene los datos personales de los estudiantes(rut, nombre, apellido, fecha de nacimiento y email).
- `MATRICULAS`: guarda las matrículas de cada alumno(id_ alumno, id_curso y fecha de la matricula).
- `CURSOS`: contiene información de los cursos(id_ colegio, id_nivel, letra del curos y anio electivo).
- `NIVELES`: contiene los nombres de los niveles(1ero, 2do, etc).

En `sp_ficha_alumno` utilizamos `JOIN` para relacionar las matrículas con los cursos y sus niveles.

De esta forma podemos mostrar en qué curso está matriculado un alumno.

### Mostrar la ficha de un alumno

```sql
BEGIN
    pkg_alumnos.sp_ficha_alumno(1);
END;
/
```

Muestra la información y las matrículas del alumno con ID 1.

### Buscar un alumno que no existe

```sql
BEGIN
    pkg_alumnos.sp_ficha_alumno(999);
END;
/
```

Si el alumno no existe, muestra:

```text
No existe el alumno con ID: 999
```

### Listar todos los alumnos

```sql
BEGIN
    pkg_alumnos.sp_listar_alumnos;
END;
/
```

Muestra todos los alumnos registrados y la cantidad total.

### Contar las matrículas de un alumno

```sql
SELECT pkg_alumnos.fn_total_matriculas_alumno(1)
AS total_matriculas
FROM dual;
```

Devuelve cuántas matrículas tiene el alumno con ID 1.

### Contar todos los alumnos

```sql
SELECT pkg_alumnos.fn_total_alumnos()
AS total_alumnos
FROM dual;
```

Devuelve la cantidad total de alumnos registrados.

En estas últimas consultas utilizamos `DUAL`, una tabla especial de Oracle que nos permite mostrar el resultado de una función sin necesidad de llamar a una tabla en especifico.

## Cómo comprobar si funciona?

Podemos revisar si el package y su body se compilaron correctamente utilizando:
