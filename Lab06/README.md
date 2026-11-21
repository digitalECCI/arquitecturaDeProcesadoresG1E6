PicoSoC Simple - Sistema en chip para FPGA MAX10

## Integrantes
- [Fernando Alexander Martine]
- [Julian Ricardo Ortiz Lozano]
- [Leidy Viviana Galeano Castillo]



## Informe

### Índice

1. [Descripción del proyecto](#descripción-del-proyecto)
2. [Documentación del diseño implementado](#documentación-del-diseño-implementado)
3. [Estructura de archivos](#estructura-de-archivos)
4. [Compilación e implementación](#compilación-e-implementación)
5. [Uso de la consola UART](#uso-de-la-consola-uart)
6. [Simulación y evidencias](#simulación-y-evidencias)
7. [Resultados esperados](#resultados-esperados)
8. [Conclusiones](#conclusiones)
9. [Referencias](#referencias)

---

## Descripción del proyecto

Este proyecto implementa un sistema en chip (SoC) sencillo basado en el procesador RISC-V PicoRV32. Está orientado a una FPGA MAX10 y combina el procesador, una memoria para el programa, una memoria RAM pequeña, una UART y entradas/salidas mapeadas en memoria para switches y LEDs.

El firmware está escrito en C. La interfaz de consola se comunica con un computador mediante UART y permite enviar comandos para consultar los switches y controlar los LEDs.

## Documentación del diseño implementado

### 1.1 Arquitectura

El módulo superior `top.v` conecta el SoC con las señales físicas de la placa. El procesador ejecuta el programa guardado en la ROM descrita en `progmem.v`. El bloque `picosoc_noflash.v` integra el núcleo PicoRV32, las memorias y la UART.

La interfaz de GPIO usa estas direcciones:

| Dirección | Función |
|---|---|
| `0x03000000` | Registro de salida para los LEDs |
| `0x03000004` | Registro de entrada para los switches |
| `0x02000004` | Divisor de reloj de la UART |
| `0x02000008` | Registro de datos de la UART |

El firmware configura la UART para 115200 baudios, sujeto a la frecuencia de reloj configurada para el diseño, y ofrece estos comandos:

| Comando | Función |
|---|---|
| `help` | Muestra la lista de comandos |
| `about` | Muestra información del sistema |
| `clear` | Limpia la terminal (si esta interpreta secuencias ANSI) |
| `led <n> <on|off>` | Enciende o apaga un LED, con `n` entre 0 y 3 |
| `leds <valor>` | Escribe un patrón de 0 a 15 en los cuatro LEDs; también acepta hexadecimal con prefijo `0x` |
| `sw` | Lee el estado de los cuatro switches |
| `blink <n> <veces>` | Hace parpadear un LED entre 1 y 20 veces |
| `calc <a> <op> <b>` | Calcula suma, resta, multiplicación o división entera |
| `pika` | Muestra una animación de texto y alterna un patrón en los LEDs |
| `raichu` | Muestra otra animación de texto y alterna un patrón en los LEDs |

### 1.2 Comandos esperados animados: `pika` y `raichu`

Estos comandos ejecutan animaciones de texto en la terminal y acompañan cada cuadro con un patrón en los cuatro LEDs:

- `pika` muestra dos dibujos ASCII alternados de Pikachu y termina con el mensaje `Pikaaachu!`.
- `raichu` muestra dos dibujos ASCII alternados de Raichu y termina con el mensaje `Raaaichu!`.

En ambos casos, los LEDs alternan entre `0x05` (`LED0` y `LED2`) y `0x0A` (`LED1` y `LED3`). La animación presenta 12 cuadros con una pausa de software entre ellos, por lo que su duración es aproximada y depende del reloj y de la compilación del firmware. Al terminar, apaga los LEDs, vuelve a mostrar el cursor y regresa al ciclo de la consola para presentar de nuevo el prompt `>`.

Ejemplos de uso:

```text
> pika
> raichu
```

La limpieza de pantalla y el ocultamiento/restauración del cursor usan secuencias ANSI; para ver esos efectos, la terminal serial debe interpretarlas. Si no lo hace, los comandos siguen enviando los dibujos y mensajes por UART, aunque las secuencias de control podrían aparecer como caracteres extraños.

### 1.3 Recursos, memoria y asignaciones de pines

El dispositivo configurado en `top.qsf` es un **Intel MAX 10 10M50DAF484C7G**. El reporte disponible en `output_files/top.fit.summary` registra 5.354 de 49.760 elementos lógicos y 2.048 bits de memoria usados. Estos valores describen el uso de recursos de una compilación guardada; pueden cambiar al recompilar el diseño.

La capacidad física de la FPGA no debe confundirse con la memoria accesible al programa del PicoSoC:

| Memoria | Capacidad configurada | Definición |
|---|---:|---|
| RAM del SoC | 128 bytes (32 palabras de 32 bits) | `MEM_WORDS = 32` en `picosoc_noflash.v` |
| ROM del programa | 1.024 palabras direccionables (4 KiB) | `MEM_SIZE_BITS = 10` en `progmem.v` |
| Imagen actualmente generada | 276 bytes (69 palabras) | Tamaño del `main.bin` encontrado en la carpeta |
| Regiones del firmware | FLASH: 512 bytes; RAM: 128 bytes | `main.lds` |

`progmem.v` declara el arreglo con el rango `[0:MEM_SIZE]`, aunque el bus de dirección de 10 bits solo selecciona las 1.024 posiciones de 0 a 1.023.

Las asignaciones físicas registradas en `top.qsf` son:

| Señal | Pin FPGA |
|---|---|
| `clk` | P11 |
| UART `rx` / `tx` | W10 / V10 |
| `led[0]` a `led[3]` | A8, A9, A10, B10 |
| `sw[0]` a `sw[3]` | C10, C11, D12, C12 |

La asignación indica qué pines usa la configuración de Quartus; para validar la conexión física de UART también se debe comprobar el cableado y el adaptador serie utilizado.

Las direcciones de los periféricos están definidas en `main.c` y se decodifican en `picosoc_noflash.v` y `top.v`:

| Dirección | Registro / función |
|---|---|
| `0x03000000` | Salida de LEDs (lectura/escritura) |
| `0x03000004` | Entrada de switches (solo lectura) |
| `0x02000004` | Divisor de reloj de UART |
| `0x02000008` | Datos de UART para transmisión y recepción |

### 1.4 Organización del diseño

- **Procesador y SoC:** `picorv32.v` y `picosoc_noflash.v`.
- **Módulo superior e interfaz física:** `top.v`.
- **UART:** `simpleuart.v`.
- **Memoria del programa:** `progmem.v`, generada a partir de `main.bin` por `progmem.py`.
- **Firmware:** `main.c` y rutina de arranque `start.s`.
- **Enlace del firmware:** `sections.lds` y `main.lds`.
- **Proyecto y restricciones de Quartus:** `top.qpf`, `top.qsf` y `picosoc.sdc`.
- **Pruebas y visualización:** `top_tb.v` y `waveform.gtkw`.
- **Automatización de compilación:** `Makefile`.

## Estructura de archivos

```text
picoSoC_simple/
├── main.c                 # Firmware y comandos de consola
├── start.s                # Inicialización al arrancar el procesador
├── sections.lds           # Distribución de secciones de memoria
├── main.lds               # Script de enlace generado
├── picorv32.v             # Núcleo RISC-V PicoRV32
├── picosoc_noflash.v      # Integración del SoC y memoria RAM
├── simpleuart.v           # UART serie
├── progmem.py             # Generador de la ROM Verilog
├── progmem.v              # ROM del programa generada
├── top.v                  # Módulo de nivel superior con GPIO
├── top.qpf, top.qsf       # Proyecto y asignación de pines de Quartus
├── picosoc.sdc             # Restricciones de tiempo
├── top_tb.v                # Banco de pruebas
├── waveform.gtkw           # Configuración de GTKWave
├── Makefile                # Flujo de compilación
├── db/                     # Base de datos de compilación de Quartus
├── incremental_db/         # Datos de compilación incremental
└── output_files/           # Reportes y archivos de programación generados
```

Los directorios `db/`, `incremental_db/` y `output_files/`, junto con archivos como `main.elf` y `main.bin`, son resultados generados; no reemplazan los archivos fuente.

## Compilación e implementación

El flujo previsto requiere una cadena de herramientas RISC-V compatible con el prefijo `riscv-none-elf-` y Quartus Prime configurado para la FPGA correspondiente.

1. Compilar el firmware y generar la ROM Verilog:

   ```sh
   make firmware
   ```

2. Seleccionar el objetivo MAX10 y ejecutar el flujo de Quartus:

   ```sh
   make TARGET=max10 build
   ```

3. Programar la FPGA con el archivo de configuración generado, usando Quartus Programmer o el objetivo disponible en el entorno:

   ```sh
   make TARGET=max10 program
   ```


## Uso de la consola UART

1. Programar la FPGA y conectar el puerto serie de la placa al computador.
2. Abrir una terminal serie con los parámetros configurados para el diseño: **115200 baudios, 8 bits de datos, sin paridad y 1 bit de parada (8N1)**.
3. Reiniciar la placa. Si el firmware correcto está cargado y la UART está conectada, deben aparecer el mensaje de bienvenida y el prompt `>`.
4. Escribir un comando, por ejemplo `help`, y presionar Enter.



## Resultados esperados

- El procesador sale del reinicio y ejecuta el firmware residente en la ROM.
- La UART transmite el mensaje inicial y presenta el prompt `>`.
- El comando `leds 0xA` activa los LEDs correspondientes a los bits 1 y 3.
- El comando `sw` informa el estado de los cuatro switches.
- `blink`, `calc`, `pika` y `raichu` ejecutan sus funciones y muestran resultados por UART.



## Conclusiones

- El proyecto integra un núcleo RISC-V, memorias, UART y GPIO en un sistema orientado a FPGA.
- El firmware muestra cómo controlar periféricos mediante registros mapeados en memoria.
- La verificación requiere comprobar que el firmware, la ROM generada, las restricciones de memoria y el diseño programado correspondan a la misma versión del proyecto.

## Referencias

1. Clifford Wolf, [PicoRV32: README y documentación del proyecto](https://github.com/YosysHQ/picorv32).
2. Intel, [Quartus Prime: documentación y recursos de soporte](https://www.intel.com/content/www/us/en/products/details/fpga/development-tools/quartus-prime.html).
3. RISC-V International, [Especificaciones de RISC-V](https://riscv.org/technical/specifications/).


