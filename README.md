# DDCP Base de Datos

Scripts SQL Server de soporte para Dispositivos decomisados centros penitenciarios.

## Carpetas y orden

| Carpeta | Archivo | Uso |
| --- | --- | --- |
| `estructura` | `01_adaptar_ddcp.sql` | Adapta las tablas originales: entidad, periodo, revisión, índices, restricciones y secuencia. |
| `estructura` | `02_ingesta.sql` | Crea los objetos de usuarios, módulos, cargas e histórico que falten. Ejecutar después del 01. |
| `mantenimiento` | `corregir-catalogo-ddcp-prod.sql` | Corrección puntual de los nombres con acentos del catálogo. |
| `mantenimiento` | `crear-secuencia-ddcp-prod.sql` | Reparación de la secuencia y sus permisos en una instalación existente. |
| `verificacion` | `verificar.sql` | Consultas de revisión de entidades, periodos, duplicados, secuencia, usuarios, cargas e histórico. |

Los scripts usan la base seleccionada por el administrador; no fuerzan un nombre de base. La carpeta de mantenimiento reúne reparaciones puntuales, no pasos obligatorios de cada publicación. Los scripts de mantenimiento siguen siendo reparaciones puntuales, independientes de la carga de catálogos.

## Objetos principales

- `CAT_ENTIDAD`: catálogo y alcance territorial.
- `DISPOSITIVOS_DECOMISADOS`: cantidades vigentes por entidad y periodo mensual.
- `SEQ_DECOMISO`: asignación de identificadores.
- `ING_USUARIO`, `ING_MODULO`, `ING_USUARIO_MODULO`: autenticación y acceso a módulos.
- `DDCP_CARGA`: archivo original, vista previa y estado de la carga.
- `DDCP_HISTORICO`: versiones anteriores de los registros reemplazados.

La validación y la confirmación pertenecen a la API. La confirmación conserva histórico y comprueba que los datos no hayan cambiado desde la vista previa.

Para esta versión sí se requiere el script 03 de catálogos descrito a continuación. La base existente ya operativa se mantiene y los scripts de instalación siguen en el repositorio del Front, carpeta `publicacion`.



## Catálogos de esta versión

Aplicar una sola vez `estructura/03_catalogos.sql`, con la base correcta seleccionada, antes de publicar la versión que lee catálogos. En bases operativas no repetir los scripts 01/02. El script 03 no modifica cargas ni credenciales y es repetible: inserta valores iniciales solo si faltan, sin restablecer etiquetas o permisos ajustados en catálogo.

- `CAT_ENTIDAD`: se reutiliza el catálogo existente.
- `CAT_ROL`: claves/nombres de roles, capacidades de carga/administración, alcance nacional obligatorio, orden y rol predeterminado. La clave existente en `ING_USUARIO.ROL` se conserva y queda referenciada por FK.
- `CAT_MES`: identificadores de los doce meses y nombres usados por Front, lectura y exportación de Excel.
- `ING_MODULO`: se reutilizan identificación, nombre y habilitación del módulo.

Las listas de roles de los CHECK anteriores se sustituyen por la referencia al catálogo. El alcance obligatorio se comprueba al asignar el rol y al autenticar al usuario. Los administradores de BD deben mantener la coherencia al editar capacidades directamente, conservar al menos un administrador activo y un rol predeterminado habilitado.

La cuenta de la API requiere SELECT sobre los nuevos catálogos. No hay creación automática de permisos ni ejecución de migraciones desde el instalador. El preflight de publicación comprueba que los catálogos existan antes de reemplazar la API.

Los ejemplos de conexión y los perfiles están en los repositorios API y Front. No guardar contraseñas, respaldos ni archivos de datos en este repo.


### Mantenimiento de secuencia con usuario parametrizado

Solo si se necesita reparar la secuencia, definir el usuario de la API en la misma sesión antes de ejecutar `mantenimiento/crear-secuencia-ddcp-prod.sql`:

```sql
EXEC sys.sp_set_session_context @key = N'UsuarioApi', @value = N'USUARIO_DE_LA_API';
```

El mantenimiento verifica que el usuario exista y aplica el permiso con `QUOTENAME`. No contiene nombres de login de ningún ambiente.
