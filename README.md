<<<<<<< HEAD
        
# Lab01 - Sumador/Restador de 4 bits

## Integrantes
* [Fernando Alexander Martínez Reyes](https://github.com/usuario1)  
* [Leidy Viviana Galeano Castillo](https://github.com/usuario2)  

## Informe

### Índice
1. [Documentación](#documentación-del-diseño-implementado)  
2. [Simulaciones](#simulaciones)  
3. [Evidencias de implementación](#evidencias-de-implementación)  
4. [Preguntas](#preguntas)  
5. [Conclusiones](#conclusiones)  
6. [Referencias](#referencias)  

---

## Documentación del diseño implementado

### 1.1 Descripción
La implementación de este laboratorio se basa en la descripción de la estructura del **sumador completo de un bit (Full Adder)**, con el propósito de comprender e implementar las herramientas necesarias para el desarrollo de estructuras más complejas y realizar pruebas físicas en la FPGA.  

#### Sumador de 1 bit
En el laboratorio se siguieron los siguientes pasos:  
1. **Tabla de verdad**  
   Se evalúan todas las combinaciones posibles de entrada en un bit, considerando los casos en los que la salida y el `cout` son 1.  
2. **Álgebra de Boole**  
   A partir de la tabla de verdad, se identifican las combinaciones donde el resultado es 1. Mediante mapas de Karnaugh, maxitérminos o minitérminos se reduce la expresión a su forma mínima.  

#### Sumador de 4 bits
En Verilog se desarrolló mediante bloques lógicos, reutilizando el módulo del sumador de 1 bit.  
Pasos:  
1. Instanciar el sumador de 1 bit cuatro veces.  
2. Consideraciones:  
   * Los archivos deben estar en la misma carpeta.  
   * Los nombres de los módulos son sensibles a mayúsculas y minúsculas.  
   * Verificar las entradas y salidas al instanciar.  

#### Restador de 4 bits
Para la resta se reutiliza el bloque lógico del sumador de 4 bits, aplicando la técnica del **complemento a dos**:  

1. **Complemento a 2**  
   Fórmula:  
   

\[
   A - B = A + (~B + 1)
   \]

  
   * Se invierte el valor de B (`~B`).  
   * Se suma 1 al resultado (`~B + 1`).  
   * Se realiza la suma con A, obteniendo la resta.  

2. **Segundo complemento a 2**  
   Si el resultado es negativo, se obtiene el inverso de la respuesta real.  
   * Se detecta el signo negativo.  
   * Se invierte el resultado y se suma 1 mediante otra instancia del sumador de 4 bits.  

---

### 1.2 Diagramas
![Diagrama lógico sumador 1 bit](./lab01/sumador1.png)  
![Diagrama lógico sumador 4 bits](./lab01/sumador4bits.png)  
![Diagramas internos sumador 1 bit](./lab01/sumadores_internos.png)  

---

## Simulaciones
![Simulación del sumador de 4 bits](./lab01/simulacion4bits.png)  
### 1. Simulación del sumador/restador
![Simulación sumadores internos](./lab01/sumadores_internos.png)  

---

## Evidencias de implementación
[Ver video en YouTube](https://youtube.com/shorts/bdAMLEy2f6I?feature=share)  

---

## Conclusiones
- Se comprendió la diferencia entre los enfoques estructural y comportamental, aplicándolos en el diseño de sumadores de 1 y 4 bits.  
- La instanciación permitió escalar un diseño básico hasta lograr un circuito más complejo y funcional.  
- Se verificó el uso eficiente de recursos en la FPGA, confirmando que diseños simples ocupan muy poca área.  
- Se profundizó en la diferencia entre `wire`, `reg` y `logic`, entendiendo que su elección depende del contexto de diseño.  

---

## Referencias
## Referencias
1. ASIC World, *Verilog Tutorial*, 2023. [Enlace](http://www.asic-world.com/verilog/)
2. IEEE, *Standard for Verilog HDL*, 2005. [Enlace](https://standards.ieee.org/standard/1364-2005.html)
3. Intel, *Quartus II Handbook*, 2016. [PDF](https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/hb/qts/qts_qii51002.pdf)
4. Intel, *Centro de asistencia Quartus Prime*, 2025. [Enlace](https://www.intel.la/content/www/xl/es/support/programmable/support-resources/design-guidance/quartus-support.html)

=======
# arquitecturaDeProcesadoresG1E6

Arquitectura de Procesadores - Grupo 1 Equipo 6

## Descripción
Este es el repositorio número 6 del la asignatura Arquitectura de Procesadores.

## Integrantes
    * [<!-- Remplace aqui nombre 1. -->](<!-- Remplace aqui link de usario 1 de github -->) 
    * [<!-- Remplace aqui nombre 2. -->](<!-- Remplace aqui link de usario 2 de github -->) 
    * [<!-- Remplace aqui nombre 3. -->](<!-- Remplace aqui link de usario 3 de github -->) 

>>>>>>> b9a24595f11a015051c6bea51f24e3b468bc2004
