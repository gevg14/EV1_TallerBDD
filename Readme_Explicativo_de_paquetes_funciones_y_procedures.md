# Sistema de Gestión Académica (PL/SQL)

Este proyecto contiene el esquema de base de datos y el paquete PL/SQL `pkg_gestion_academica` para la administración de alumnos, matrículas, notas y reportes académicos.

---

## 🚀 Instalación y Configuración

1. Ejecuta el script de la base de datos (`info_ev1.sql`) para crear las tablas e insertar los datos iniciales.
2. Compila la especificación y el cuerpo del paquete `pkg_gestion_academica`.
3. Activa la salida de consola en tu cliente SQL:
   ```sql
   SET SERVEROUTPUT ON;
   ```

---

## 📦 Componentes del Paquete

| Tipo | Nombre | Descripción |
| :--- | :--- | :--- |
| **Procedimiento** | `sp_listar_alumnos_curso(p_id_curso)` | Lista los alumnos pertenecientes a un curso específico. |
| **Procedimiento** | `sp_resumen_matriculas` | Muestra la cantidad de alumnos matriculados por curso. |
| **Función** | `fn_promedio_asignatura(p_id_matricula, p_id_carga)` | Retorna el promedio ponderado de notas de un estudiante. |
| **Función** | `fn_total_matriculas` | Devuelve el total general de alumnos matriculados. |

---

## 💡 Ejemplos Rápidos de Uso

```sql
-- 1. Listar alumnos del Curso ID 1
BEGIN
    pkg_gestion_academica.sp_listar_alumnos_curso(1);
END;
/

-- 2. Mostrar resumen global de matrículas
BEGIN
    pkg_gestion_academica.sp_resumen_matriculas;
END;
/

-- 3. Consultar promedio de nota (Matrícula ID 1, Carga ID 1)
SELECT pkg_gestion_academica.fn_promedio_asignatura(1, 1) AS promedio FROM dual;

-- 4. Consultar total de matriculados en el colegio
SELECT pkg_gestion_academica.fn_total_matriculas() AS total FROM dual;
```