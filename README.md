# Inventario para Casa de Eventos

Base de datos en MySQL para controlar el inventario interno de una casa de eventos.

## Contiene:

- Categorías de objetos
- Ítems inventariados (sillas, mesas, etc.)
- Movimientos de inventario (ingresos/salidas)
- Triggers para:
  - Evitar stock negativo
  - Actualizar cantidad automáticamente
  - Generar alertas cuando el stock es bajo

## Despliegue

Este repositorio está preparado para ser desplegado en Railway con Docker.

1. Conecta tu cuenta de GitHub a Railway
2. Crea un nuevo proyecto desde este repositorio
3. Railway construirá la imagen con MySQL y tu base de datos estará lista

## Acceso

Por defecto:
- Usuario: `root`
- Contraseña: `root`
- Base de datos: `inventario_`
