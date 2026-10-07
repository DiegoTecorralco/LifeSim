# LifeSim — Simulador Inteligente de Decisiones Personales

## 1. Parte inicial del proyecto

### 1.1 Nombre del proyecto

**LifeSim — Simulador Inteligente de Decisiones Personales**

### 1.2 Descripción general

LifeSim es una aplicación orientada a la simulación de decisiones personales mediante la definición de variables, escenarios y diferentes condiciones de análisis. El sistema permitirá al usuario modelar una decisión, establecer las variables que pueden influir en ella, crear diferentes escenarios y ejecutar simulaciones para posteriormente visualizar los resultados mediante tablas, gráficas, estadísticas e indicadores.

El sistema no busca predecir el futuro ni indicar al usuario qué decisión debe tomar. Su propósito es proporcionar información que facilite el análisis y comparación de diferentes alternativas. 

### 1.3 Tecnologías principales

* **Flutter / Dart** para el desarrollo de la aplicación.
* **Flutter Web / PWA** para acceso desde dispositivos móviles y computadoras.
* **Riverpod** para la gestión del estado.
* **GoRouter** para la navegación.
* **Supabase** como plataforma de backend.
* **PostgreSQL** como sistema de base de datos.
* **Motor de simulación desarrollado en Dart**.
* **IA mediante API externa**, integrada a través de un backend o Edge Function.
* **Git y GitHub** para control de versiones. 

---

# 2. Alcance

## 2.1 Alcance funcional

El proyecto contempla el desarrollo de una aplicación capaz de permitir al usuario:

* Registrarse e iniciar sesión.
* Administrar su perfil.
* Crear, consultar, modificar y eliminar decisiones.
* Definir variables asociadas a una decisión.
* Establecer valores mínimos y máximos para las variables.
* Crear diferentes escenarios.
* Configurar las condiciones de cada escenario.
* Ejecutar simulaciones.
* Guardar los resultados de las simulaciones.
* Visualizar resultados mediante tablas, gráficas e indicadores.
* Comparar diferentes escenarios.
* Consultar el historial de simulaciones.
* Utilizar funciones de inteligencia artificial para interpretar información y resultados.
* Utilizar la aplicación mediante una interfaz responsive.
* Acceder al sistema como PWA.
* Contar con determinadas funciones de caché y funcionamiento offline.
* Sincronizar información cuando vuelva a existir conexión.  

## 2.2 Alcance técnico

La arquitectura estará organizada mediante una aplicación Flutter que se comunica con servicios y repositorios para acceder a Supabase y PostgreSQL. El motor de simulación permanecerá independiente de la interfaz para facilitar su desarrollo y pruebas. 

El sistema contemplará categorías como:

* Finanzas.
* Educación.
* Trabajo.
* Administración del tiempo.
* Proyectos personales.
* Compras.

## 2.3 Fuera del alcance

La primera versión de LifeSim **no pretende funcionar como asesor profesional financiero, médico o legal**, ni garantizar que una simulación represente lo que ocurrirá en la realidad. 

---

# 3. Muestra o sustento

El sustento del proyecto se basa en la necesidad de contar con una herramienta que permita analizar diferentes alternativas antes de tomar una decisión.

LifeSim plantea un flujo de trabajo compuesto por:

```text
Usuario
   ↓
Decisión
   ↓
Variables
   ↓
Escenarios
   ↓
Simulación
   ↓
Resultados
   ↓
Gráficas y estadísticas
   ↓
Análisis mediante IA
```

El proyecto contempla un **MVP** compuesto principalmente por:

```text
Inicio de sesión
      ↓
Dashboard
      ↓
Crear decisión
      ↓
Agregar variables
      ↓
Crear escenarios
      ↓
Ejecutar simulación
      ↓
Mostrar resultados
      ↓
Guardar simulación
```

Este flujo corresponde al MVP definido en el documento del proyecto. 

Como sustento técnico, el motor de simulación podrá trabajar con diferentes cantidades de simulaciones y generar información estadística como mínimo, máximo, promedio, mediana, percentiles y distribución de resultados. 

---

# 4. Objetivo general

Desarrollar **LifeSim**, una aplicación multiplataforma para la simulación y análisis de decisiones personales, que permita a los usuarios definir decisiones, variables y escenarios, ejecutar simulaciones y visualizar sus resultados mediante estadísticas, gráficas e indicadores, incorporando herramientas de inteligencia artificial para facilitar la interpretación de la información obtenida.

---

# 5. Objetivos específicos

1. Diseñar e implementar la arquitectura base de LifeSim utilizando Flutter y Dart.

2. Implementar un sistema de autenticación que permita el registro, inicio de sesión, recuperación de contraseña y administración del perfil.

3. Desarrollar un módulo para crear, consultar, modificar y eliminar decisiones.

4. Implementar la creación y configuración de variables relacionadas con cada decisión.

5. Permitir la creación de diferentes escenarios para una misma decisión.

6. Desarrollar un motor de simulación independiente de la interfaz de usuario.

7. Ejecutar simulaciones a partir de las variables y escenarios definidos por el usuario.

8. Almacenar las simulaciones y sus resultados utilizando Supabase y PostgreSQL.

9. Representar los resultados mediante tablas, gráficas, indicadores y comparaciones.

10. Implementar un historial que permita consultar simulaciones anteriores.

11. Integrar herramientas de inteligencia artificial para interpretar información proporcionada por el usuario y explicar los resultados obtenidos.

12. Adaptar la aplicación para dispositivos móviles, tablets y computadoras mediante un diseño responsive.

13. Implementar las características principales de una Progressive Web App.

14. Incorporar mecanismos de caché y funcionamiento offline.

15. Realizar pruebas unitarias, de integración, responsive y PWA antes del despliegue final. 

---

# 6. Justificación

Tomar decisiones personales puede involucrar diferentes factores que deben analizarse antes de elegir una alternativa. Cuando una decisión depende de varias variables, comparar manualmente diferentes posibilidades puede resultar complicado.

LifeSim busca proporcionar una herramienta que permita representar una decisión mediante variables y escenarios, ejecutar diferentes simulaciones y analizar los resultados obtenidos.

La aplicación puede facilitar la comparación de alternativas al presentar los resultados mediante estadísticas, gráficas e indicadores, permitiendo que el usuario tenga una perspectiva más amplia de los posibles resultados de los escenarios planteados.

Además, la incorporación de inteligencia artificial permitirá interpretar información proporcionada mediante lenguaje natural y ayudar a explicar los resultados de las simulaciones. Sin embargo, el sistema mantendrá como finalidad el **análisis y apoyo a la toma de decisiones**, sin presentar sus resultados como predicciones garantizadas. 

---

# 7. Partes interesadas

| Parte interesada                             | Rol / interés en el proyecto                                                 | Nivel de interés | Nivel de influencia |
| -------------------------------------------- | ---------------------------------------------------------------------------- | ---------------: | ------------------: |
| **Usuarios finales**                         | Utilizar LifeSim para modelar y analizar decisiones                          |             Alto |                Alto |
| **Equipo de desarrollo**                     | Diseñar, desarrollar, probar y desplegar el sistema                          |             Alto |                Alto |
| **Product Owner / responsable del proyecto** | Definir prioridades y validar funcionalidades                                |             Alto |                Alto |
| **Docente / asesor académico**               | Supervisar y evaluar el desarrollo del proyecto                              |             Alto |                Alto |
| **Equipo de pruebas**                        | Verificar funcionamiento y calidad del sistema                               |            Medio |                Alto |
| **Supabase**                                 | Proporcionar servicios de backend, autenticación y base de datos             |            Medio |               Medio |
| **Proveedor de IA**                          | Proporcionar los servicios de inteligencia artificial utilizados por LifeSim |            Medio |               Medio |
| **GitHub**                                   | Proporcionar control de versiones y colaboración                             |            Medio |               Medio |

---

# 8. Matriz de riesgos

| ID   | Riesgo                                                   | Probabilidad | Impacto | Nivel | Estrategia de mitigación                                                                |
| ---- | -------------------------------------------------------- | ------------ | ------- | ----- | --------------------------------------------------------------------------------------- |
| R-01 | Retraso en el desarrollo de funcionalidades              | Media        | Alto    | Alto  | Priorizar las funcionalidades del MVP y dividir el trabajo en sprints                   |
| R-02 | Problemas de integración con Supabase/PostgreSQL         | Media        | Alto    | Alto  | Realizar pruebas de integración durante el desarrollo                                   |
| R-03 | Errores en el motor de simulación                        | Media        | Alto    | Alto  | Implementar pruebas unitarias y validar los cálculos con diferentes escenarios          |
| R-04 | Dificultad para implementar la integración con IA        | Media        | Medio   | Medio | Mantener la IA como módulo independiente y utilizar un backend/Edge Function            |
| R-05 | Problemas de funcionamiento offline                      | Media        | Medio   | Medio | Implementar progresivamente caché, almacenamiento local y sincronización                |
| R-06 | Problemas de compatibilidad entre dispositivos           | Media        | Medio   | Medio | Realizar pruebas responsive en móvil, tablet y escritorio                               |
| R-07 | Pérdida o corrupción de información                      | Baja         | Alto    | Medio | Utilizar PostgreSQL/Supabase y validar operaciones de almacenamiento                    |
| R-08 | Vulnerabilidades de seguridad                            | Media        | Alto    | Alto  | Implementar autenticación, control de acceso, validaciones y protección de credenciales |
| R-09 | Falta de tiempo para completar todas las funcionalidades | Alta         | Alto    | Alto  | Priorizar el MVP y reservar los últimos días para pruebas y despliegue                  |
| R-10 | Fallos durante el despliegue                             | Media        | Medio   | Medio | Realizar pruebas de producción antes del lanzamiento definitivo                         |

La seguridad del proyecto contempla autenticación, control de acceso, validación, protección de endpoints, seguridad de base de datos y manejo adecuado de variables de entorno. Las claves privadas relacionadas con IA no deben almacenarse directamente en Flutter. 

---

# 9. Cronograma / Desglose de trabajo

El proyecto se dividirá en **3 sprints**, considerando el periodo establecido del **05 de octubre de 2026 al 05 de diciembre de 2026**.

> **Nota:** El último sprint incluye los últimos 5 días destinados específicamente a pruebas y despliegue, tal como se estableció para el proyecto.

## Sprint 1 — Base del sistema

**Periodo:** 05/10/2026 – 25/10/2026

**Objetivo:** Construir la base técnica de LifeSim y desarrollar autenticación y gestión de decisiones.

| ID    | Actividad                              |
| ----- | -------------------------------------- |
| US-01 | Crear proyecto Flutter                 |
| US-02 | Implementar arquitectura               |
| US-03 | Configurar navegación                  |
| US-04 | Implementar registro                   |
| US-05 | Implementar inicio de sesión           |
| US-06 | Implementar cierre de sesión           |
| US-07 | Implementar recuperación de contraseña |
| US-08 | Administrar perfil                     |
| US-09 | Crear decisión                         |
| US-10 | Consultar decisiones                   |
| US-11 | Editar decisión                        |
| US-12 | Eliminar decisión                      |

**Entregable del Sprint 1:**

Sistema base funcional con autenticación, navegación y CRUD de decisiones.

---

## Sprint 2 — Funcionalidad principal del MVP

**Periodo:** 26/10/2026 – 15/11/2026

**Objetivo:** Implementar el núcleo de LifeSim: variables, escenarios, simulación y resultados.

| ID    | Actividad                 |
| ----- | ------------------------- |
| US-13 | Agregar variables         |
| US-14 | Editar variables          |
| US-15 | Crear escenarios          |
| US-16 | Configurar escenario      |
| US-17 | Crear motor de simulación |
| US-18 | Ejecutar simulación       |
| US-19 | Guardar simulación        |
| US-20 | Mostrar resultados        |
| US-21 | Mostrar gráficas          |
| US-23 | Consultar historial       |

**Entregable del Sprint 2:**

MVP funcional capaz de realizar el flujo:

```text
Crear decisión
      ↓
Agregar variables
      ↓
Crear escenarios
      ↓
Ejecutar simulación
      ↓
Mostrar resultados
      ↓
Guardar simulación
      ↓
Consultar historial
```

---

## Sprint 3 — Complementos, pruebas y despliegue

**Periodo:** 16/11/2026 – 05/12/2026

**Objetivo:** Incorporar las funcionalidades complementarias de LifeSim, preparar la aplicación para producción y realizar las pruebas finales.

### Desarrollo de funcionalidades

| ID    | Actividad                               |
| ----- | --------------------------------------- |
| US-22 | Comparar escenarios                     |
| US-24 | Interpretar lenguaje natural            |
| US-25 | Convertir lenguaje natural en variables |
| US-26 | Explicar resultados mediante IA         |
| US-27 | Implementar diseño responsive           |
| US-28 | Configurar PWA                          |
| US-29 | Implementar caché                       |
| US-30 | Implementar funcionamiento offline      |
| US-31 | Sincronizar información                 |

### Últimos 5 días — Pruebas y despliegue

**Periodo:** 01/12/2026 – 05/12/2026

| ID    | Actividad                         |
| ----- | --------------------------------- |
| US-32 | Realizar pruebas unitarias        |
| US-33 | Realizar pruebas de integración   |
| US-34 | Realizar pruebas responsive y PWA |
| US-35 | Desplegar LifeSim                 |

**Entregable del Sprint 3:**

Versión final de LifeSim probada y preparada para su despliegue.

---

# 10. Resumen del cronograma

```text
05 OCT ───────────────── 25 OCT
          SPRINT 1
     Base del sistema
     Autenticación
     Decisiones
              ↓
26 OCT ───────────────── 15 NOV
          SPRINT 2
       Funcionalidad MVP
 Variables + Escenarios
   Simulación + Resultados
              ↓
16 NOV ───────────────── 05 DIC
          SPRINT 3
 IA + PWA + Offline + Comparación
              ↓
01 DIC ──── 05 DIC
      PRUEBAS FINALES
      Integración
      Responsive/PWA
      Despliegue
```

El desglose sigue la estructura funcional planteada en el documento de LifeSim y prioriza primero el MVP, dejando las funcionalidades complementarias y las pruebas finales para el último sprint.
