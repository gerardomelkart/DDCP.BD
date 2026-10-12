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

Los scripts seleccionan `DDCP` explícitamente. La carpeta de mantenimiento reúne reparaciones puntuales, no pasos obligatorios de cada publicación. La reorganización solo mueve la verificación y añade esta guía; conserva el contenido SQL.

## Objetos principales

- `CAT_ENTIDAD`: catálogo y alcance territorial.
- `DISPOSITIVOS_DECOMISADOS`: cantidades vigentes por entidad y periodo mensual.
- `SEQ_DECOMISO`: asignación de identificadores.
- `ING_USUARIO`, `ING_MODULO`, `ING_USUARIO_MODULO`: autenticación y acceso a módulos.
- `DDCP_CARGA`: archivo original, vista previa y estado de la carga.
- `DDCP_HISTORICO`: versiones anteriores de los registros reemplazados.

La validación y la confirmación pertenecen a la API. La confirmación conserva histórico y comprueba que los datos no hayan cambiado desde la vista previa.

No se requiere ejecutar ningún SQL por este cambio de organización. La base existente ya operativa se mantiene y los scripts de instalación siguen en el repositorio del Front, carpeta `publicacion`.
