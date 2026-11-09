# Laboratorio: ALU, banco de registros y UART

**Asignatura:** Arquitectura de Procesadores  
**Grupo:** [6]  

## Integrantes

- [Fernando Alexander Martínez Reyes(https://github.com/usuario1)
- [Leidy Viviana Galeano Castillo](https://github.com/usuario2)
- [Julian Ricardo Ortiz Lozano](https://github.com/usuario2)

## Informe

### Índice

1. [Documentación del diseño implementado](#documentación-del-diseño-implementado)
2. [Simulaciones](#simulaciones)
3. [Evidencias de implementación](#evidencias-de-implementación)
4. [Conclusiones](#conclusiones)
5. [Referencias](#referencias)

---

## Documentación del diseño implementado

### 1.1 Objetivos

- Comprender la ALU y el banco de registros como bloques fundamentales de la microarquitectura de un procesador.
- Implementar un banco de registros para almacenar resultados y facilitar el flujo de datos.
- Visualizar los datos almacenados y analizar el comportamiento interno del sistema.
- Corroborar el diseño mediante simulación e implementación sobre FPGA.

### 1.2 Descripción del diseño

El proyecto implementa de la integracion de operandos de 4 bits con una ALU, un banco de 16 registros de 8 bits, dos canales de lectura para displays de siete segmentos y una salida UART. La salida de la ALU se conecta a la entrada de escritura del banco. Al guardar, el control selecciona el registro destino, escribe el resultado y transmite una línea serial con la dirección y el valor.

### 1.3 Operaciones de la ALU

La señal `selec` elige la operación y el resultado se entrega en `R_byte`.

| `selec` | Operación | Descripción |
|---|---|---|
| `000` | Suma | `A + B`, incluyendo el acarreo |
| `001` | Resta | `A - B`; `segSigno` se deriva del préstamo |
| `010` | OR | Operación bit a bit entre `A` y `B` |
| `011` | NOT | Complemento bit a bit de `A` |
| `100` | EXNOR | XNOR bit a bit entre `A` y `B` |
| `101` | Desplazamiento | Desplaza `A` a la izquierda según `B` |
| `110` | Comparación | Indica si `A` es mayor, igual o menor que `B` |
| `111` | Multiplicación | `A × B`, calculada secuencialmente |

La teoría general de ALU puede incluir AND, XOR y división; esas operaciones no aparecen entre las opciones implementadas en este proyecto.

### 1.4 Banco de registros y visualización

El banco almacena 16 datos de 8 bits. `addrRa` y `addrRb` seleccionan dos registros para lectura combinacional. `addrW` elige el destino de escritura, y `RegWrite` habilita la escritura en el flanco ascendente de `clk`. El reset es activo en bajo (`rst = 0`).

Cada lectura pasa por un convertidor binario a BCD para mostrar centenas, decenas y unidades. Los displays representan los valores almacenados en las direcciones elegidas por `selectora` y `selectorb`; no muestran directamente el resultado actual de la ALU.

### 1.5 Comunicación UART

UART es un protocolo serial asíncrono en el que emisor y receptor acuerdan la velocidad de transmisión. En esta implementación la FPGA transmite por `tx`, conectado al pin RX del adaptador USB-UART. No se implementa recepción UART desde el PC.

El formato transmitido al guardar es `Rnn=vvv\r\n`: `nn` representa la dirección del registro (00–15) y `vvv` el valor decimal (000–255). La trama es 8N1: bit de inicio, ocho bits de datos con el menos significativo primero y bit de parada. Los parámetros predeterminados son 50 MHz y 115200 baudios.

### 1.6 Metodología

1. Revisar los módulos HDL de la ALU, banco de registros, visualización y UART.
2. Integrar los módulos en el nivel superior y comprobar las conexiones de datos y control.
3. Compilar y simular los casos de prueba, comparando los mensajes recibidos con los esperados.
4. Configurar Quartus, asignar pines y programar la FPGA.
5. Conectar `tx` al adaptador USB-UART y verificar los mensajes en un terminal serial.
6. Guardar evidencias de simulación y de la implementación física.

### 1.7 Diagramas

Los siguientes diagramas se generaron a partir de los módulos Verilog del proyecto:

![Diagrama de bloques de la arquitectura](arquitectura_proyecto.svg)

![Flujo de guardado y transmisión UART](flujo_guardado_uart.svg)

### 1.8 Archivos principales

- `calculadora.v`: integra el selector de operaciones y el multiplicador.
- `operaciones.v`: decodifica `selec` y selecciona el resultado de la ALU.
- `sumador_restador_4bits.v` y `sumador_1bit.v`: suma y resta.
- `comparador_1bits.v` y `comparador_4bits.v`: comparación de operandos.
- `multiplicador.v`: multiplicador secuencial por suma y desplazamiento.
- `banco_registro.v`: banco de 16 registros de 8 bits.
- `principla.v`: módulo `alus_principal`, integra ALU, banco y displays.
- `convertidorudc.v`: conversión binaria a BCD.
- `sevensegmentos.v`: decodificación de dígitos para displays.
- `principla_uart.v`: control de guardado y transmisión UART.
- `uart_msg.v`: construcción del mensaje ASCII.
- `uart_tx.v`: transmisor serial 8N1.
- `tb_uart.v`: testbench de transmisión UART.

---

## Simulaciones

Se simuló la transmisión UART con Icarus Verilog. Para la simulación se usó un baud rate acelerado de 1 Mbps. El testbench compara los nueve bytes recibidos con cada mensaje esperado.

| Operación | Entradas | Dirección | Mensaje esperado | Resultado |
|---|---|---:|---|---|
| Suma (`000`) | `A=5`, `B=3` | `03` | `R03=008\r\n` | PASS |
| OR (`010`) | `A=5`, `B=3` | `12` | `R12=007\r\n` | PASS |
| Multiplicación (`111`) | `A=15`, `B=15` | `07` | `R07=225\r\n` | PASS |
| Multiplicación (`111`) | `A=4`, `B=3` | `15` | `R15=012\r\n` | PASS |



---

## Conclusiones

- El diseño conecta una ALU, un banco de registros de dos puertos de lectura y una ruta de visualización decimal.
- La simulación no sustituye la prueba física en FPGA; la asignación de pines, displays y recepción serial deben confirmarse en el hardware.



## Referencias

1. ECCI, *Arquitectura de Procesadores ECCI 2026-II*, material y repositorio del curso: [GitHub](https://github.com/digital-ECCI/Arquitetura_de_procesadores-ECCI-2026-II).
2. IEEE, *Standard for Verilog HDL*: [IEEE 1364-2005](https://standards.ieee.org/standard/1364-2005.html).
3. Intel, *Quartus Prime Support*: [Centro de asistencia](https://www.intel.la/content/www/xl/es/support/programmable/support-resources/design-guidance/quartus-support.html).

---


