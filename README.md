# 📚 Sistema de Libro de Clases Digital - Oracle PL/SQL

**Asignatura:** Taller de Base de Datos  
**Evaluación:** Parcial N°1  
**Docente:** Carlos Alberto Orellana Soto  
**Institución:** Duoc UC  
**Fecha:** Septiembre 2026  

---

## 👥 Integrantes del Equipo
* Alexander Oyarzun
* Nicolas Lopez
* Gerardo Vera

---

## 📝 Descripción del Proyecto
Backend para un **Sistema de Gestión Escolar (Libro de Clases Digital)** desarrollado sobre **Oracle Database**. El sistema centraliza la gestión académica de Educación Media (colegios, alumnos, profesores, matrículas, asistencia, calificaciones y anotaciones) asegurando la integridad de datos mediante lógica de negocio en **PL/SQL**.

---

## 📐 Modelo Relacional
El sistema está compuesto por **11 tablas** interrelacionadas:

![Diagrama Relacional](img/modelo_relacional.png)

---

## ⚡ Resumen de Bloques Anónimos PL/SQL Desarrollados

| Bloque | Objeto Principal | Problemática de Negocio | Excepción Manejada |
| :--- | :--- | :--- | :--- |
| **Bloque 1** | `RECORD` | Consulta estructurada de datos de contacto docente para notificaciones rápidas. | `NO_DATA_FOUND` |
| **Bloque 2** | `VARRAY` | Validación masiva en memoria de estados de asistencia diaria segun normativa. | `e_estado_invalido` (Definida por usuario) |
| **Bloque 3** | `CURSORES` | Generación de nómina de alumnos matriculados por curso mediante cursor explícito con parámetro. | `e_curso_vacio` (Definida por usuario) |
| **Bloque 4** | **INTEGRACIÓN**<br>*(RECORD + VARRAY + CURSOR)* | Reporte de excelencia académica: Identifica al mejor alumno por asignatura evaluando un arreglo de materias. | `e_sin_calificaciones` (Definida por usuario) |

---

## 🚀 Instrucciones de Ejecución
1. Clonar este repositorio:
   ```bash
   git clone [[https://github.com/TU_USUARIO/TU_REPOSITORIO.git](https://github.com/TU_USUARIO/TU_REPOSITORIO.git](https://github.com/gevg14/EV1_TallerBDD.git))
