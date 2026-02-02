# App SST - Gestión de Seguridad y Salud en el Trabajo

Una aplicacion movil desarrollada con Flutter para la recoleccion y gestion de datos relacionados con la Seguridad y Salud en el Trabajo (SST). Permite a los usuarios reportar, incidentes, accidentes, enfermedades laborales y gestionar inspecciones, todo ello con funcionalidad offline y sincronizacion automatica.

## Caracteristicas Principales

*   **Desarrollo Offline-First:** Funciona sin conexion a internet, guardando datos localmente en SQLite.
*   **Sincronizacion Inteligente:** Detecta la conexion y sube los datos pendientes automaticamente.
*   **Autenticacion Segura:** Registro de verificacion por correo electronico y contraseña encriptadas.
*   **Base de datos Relacional:** Estructura completa de 19 tablas para garantizar la integridad de los datos.
*   **Formularios Dinamicos:**
    * Listas desplegables en cascadas (Proyecto $\to$ Contratista $\to$ Trabajador).
    * Validaciones de campos.
*   **Gestion de Evidencias:** Captura y almacenamiento seguro de fotos (hasta 3 por reporte).
*   **Reportes PDF:** Generacion de informes detallados con informacion relacional.
*   **Interfaz Intuitiva:** Diseño limpio y responsivo adaptado a diferentes tamaños de pantalla.
*   **Rol de Administrador:** Acceso a funcionalidades de gestion global (Usuarios, Reportes, Exportaciones).

## Estructura de Proyectos (Clean Architecture)

*   **`lib/`**: Codigo fuente principal
    *   **`core/`**: Utilidades y servicios transversales (Base de Datos, Notificaciones, Sincronizacion, Crypto, Image Picker).
    *   **`features/`**: Modulos de funcionalidad.
        *   **`auth/`**: Manejo de usuarios, login, registro, perfil.
            * **`screens/`**: Pantallas organizadas por flujo de usuario:
                * **`startup/`**: Pantallas de carga inicial y verificacion de sesion.
                * **`login/`**: Pantalla de inicio de sesion.
                * **`register/`**: Flujo de registro y verificacion de codigo OTP.
                * **`recovery/`**: Flujo completo de recuperacion de contraseña (Solicitud -> Codigo -> Nueva Contraseña).
                * **`user/`**: Dashboard edl usuario y edicion de perfil.
                * **`admin/`**: Panel de control y gestion para administradores.
        *   **`forms/`**: Modulos para cada tipo de reportes
            *   **`data/`**: Fuentes de datos (local), Modelos, Repositorios.
            *   **`domain/`**: Entidades, Repositorios (abstractos), Casos de Uso.
            *   **`presentation/`**: UI (Screens, Notifiers, Providers, States).
        *   **`shared/`**: Widgets y utilidades reutilizables en toda la app.
    *   **`android/`**: Configuracion especifica de Android.
    *   **`ios/`**: Configuracion especifica de iOS.

## Tecnologias Utilizadas

*   **Lenguaje**: Dart
*   **Framework**: Flutter
*   **Gestion de Estado**: Riverpod + Hooks
*   **Base de Datos Local**: SQLite (sqflite)
<!-- *   **API Backend**: Python (Flask)  -->
*   **Servicio de Email**: EmailJS
*   **Notificaciones**: flutter_local_notificacions
*   **Permisos**: permission_handler
*   **Seleccion de Imagenes**: image_picker
*   **Generacion PDF**: pdf, printing
*   **Compartir**: share_plus

## Faltante (Proximos Pasos)
*   Construccion del Backend (API Flask).
*   Configurar la sincronizacion real.
*   Implementar notificaciones push
