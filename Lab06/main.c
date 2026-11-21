/*
 *  PicoSoC Shell — DE10-Lite (MAX10, 50 MHz)
 *  Compilar: riscv-none-elf-gcc -march=rv32im -mabi=ilp32 ...
 */

#include <stdint.h>


/* Prototipos de las funciones de hardware                             */

void     uart_putchar(char c);
int      uart_getchar_nb(void);
void     write_leds(uint32_t v);
uint32_t read_switches(void);


// Utilidades UART                                                     
static char uart_getchar(void) {
    int c;
    do { c = uart_getchar_nb(); } while (c < 0);
    return (char)c;
}

static void uart_puts(const char *s) {
    while (*s) uart_putchar(*s++);
}

static void uart_crlf(void) {
    uart_putchar('\r'); uart_putchar('\n');
}

static void uart_put_dec(int v) {
    char buf[12];
    int  i = 0;
    unsigned u;
    if (v < 0) { uart_putchar('-'); u = (unsigned)(-v); }
    else         u = (unsigned)v;
    if (u == 0) { uart_putchar('0'); return; }
    while (u) { buf[i++] = '0' + (u % 10); u /= 10; }
    while (i) uart_putchar(buf[--i]);
}

static void uart_put_hex(uint8_t val) {
    static const char hex[] = "0123456789ABCDEF";
    uart_putchar(hex[(val >> 4) & 0xF]);
    uart_putchar(hex[val & 0xF]);
}


/* Utilidades de string                                                */

static int str_eq(const char *a, const char *b) {
    while (*a && *b) { if (*a != *b) return 0; a++; b++; }
    return *a == *b;
}

static int parse_int(const char *s, int *ok) {
    int sign = 1, val = 0;
    *ok = 1;
    if (*s == '-') { sign = -1; s++; }
    if (!*s) { *ok = 0; return 0; }
    while (*s) {
        if (*s < '0' || *s > '9') { *ok = 0; return 0; }
        val = val * 10 + (*s - '0');
        s++;
    }
    return sign * val;
}

static int tokenize(char *line, char *argv[], int max) {
    int n = 0;
    while (*line) {
        while (*line == ' ' || *line == '\t') line++;
        if (!*line) break;
        if (n < max) argv[n++] = line;
        while (*line && *line != ' ' && *line != '\t') line++;
        if (*line) *line++ = 0;
    }
    return n;
}


// Estado de los LEDs                                                  

static uint8_t led_state = 0;


// Delay simple por ciclos

static void delay_cycles(uint32_t n) {
    volatile uint32_t i;
    for (i = 0; i < n; i++);
}


// Comandos                                                           


static void cmd_help(void) {
    uart_puts("Comandos disponibles:\r\n");
    uart_puts("  help               muestra esta ayuda\r\n");
    uart_puts("  about              informacion del sistema\r\n");
    uart_puts("  clear              limpia la pantalla\r\n");
    uart_puts("  led <n> <on|off>   enciende/apaga el LED n (0-3)\r\n");
    uart_puts("  leds <valor>       enciende LEDs segun valor hex (0-F)\r\n");
    uart_puts("  sw                 lee el estado de los switches\r\n");
    uart_puts("  blink <n> <
        veces>  parpadea el LED n N veces\r\n");
    uart_puts("  calc <a> <op> <b>  calcula a op b  (+ - * /)\r\n");
    uart_puts("  pika               pikachu baila\r\n");
    uart_puts("  raichu             raichu baila\r\n");
}

static void cmd_led(int argc, char *argv[]) {
    int ok, n;
    if (argc < 3) { uart_puts("uso: led <n> <on|off>\r\n"); return; }
    n = parse_int(argv[1], &ok);
    if (!ok || n < 0 || n > 3) { uart_puts("LED invalido (0-3)\r\n"); return; }
    if      (str_eq(argv[2], "on"))  led_state |=  (1 << n);
    else if (str_eq(argv[2], "off")) led_state &= ~(1 << n);
    else { uart_puts("usa 'on' u 'off'\r\n"); return; }
    write_leds(led_state);
    uart_puts("ok\r\n");
}

static void cmd_leds(int argc, char *argv[]) {
    int ok, val;
    if (argc < 2) { uart_puts("uso: leds <valor hex 0-F>\r\n"); return; }
    // acepta tanto decimal como hex (0x...)
    const char *s = argv[1];
    if (s[0] == '0' && (s[1] == 'x' || s[1] == 'X')) {
        // parseo hex manual
        val = 0;
        s += 2;
        ok = 1;
        while (*s) {
            int d;
            if (*s >= '0' && *s <= '9')      d = *s - '0';
            else if (*s >= 'a' && *s <= 'f') d = *s - 'a' + 10;
            else if (*s >= 'A' && *s <= 'F') d = *s - 'A' + 10;
            else { ok = 0; break; }
            val = val * 16 + d;
            s++;
        }
    } else {
        val = parse_int(argv[1], &ok);
    }
    if (!ok || val < 0 || val > 15) { uart_puts("valor invalido (0-15 o 0x0-0xF)\r\n"); return; }
    led_state = (uint8_t)val;
    write_leds(led_state);
    uart_puts("LEDs = 0x");
    uart_put_hex(led_state);
    uart_crlf();
}

static void cmd_sw(void) {
    uint32_t sw = read_switches();
    uart_puts("Switches = 0x");
    uart_put_hex((uint8_t)(sw & 0x0F));
    uart_puts("  (");
    // muestra cada switch individualmente
    int i;
    for (i = 3; i >= 0; i--) {
        uart_putchar('S');
        uart_putchar('0' + i);
        uart_putchar(':');
        uart_putchar((sw >> i) & 1 ? '1' : '0');
        if (i > 0) uart_putchar(' ');
    }
    uart_puts(")\r\n");
}

static void cmd_blink(int argc, char *argv[]) {
    int ok1, ok2, n, veces;
    if (argc < 3) { uart_puts("uso: blink <n> <veces>\r\n"); return; }
    n     = parse_int(argv[1], &ok1);
    veces = parse_int(argv[2], &ok2);
    if (!ok1 || n < 0 || n > 3)    { uart_puts("LED invalido (0-3)\r\n"); return; }
    if (!ok2 || veces < 1 || veces > 20) { uart_puts("veces invalido (1-20)\r\n"); return; }

    uart_puts("Parpadeando LED ");
    uart_putchar('0' + n);
    uart_puts("...\r\n");

    int i;
    for (i = 0; i < veces; i++) {
        led_state |=  (1 << n);  write_leds(led_state);
        delay_cycles(200000);
        led_state &= ~(1 << n);  write_leds(led_state);
        delay_cycles(200000);
    }
    uart_puts("listo\r\n");
}

static void cmd_calc(int argc, char *argv[]) {
    int ok1, ok2, a, b, r;
    char op;
    if (argc < 4) { uart_puts("uso: calc <a> <op> <b>\r\n"); return; }
    a = parse_int(argv[1], &ok1);
    b = parse_int(argv[3], &ok2);
    if (!ok1 || !ok2) { uart_puts("numeros invalidos\r\n"); return; }
    op = argv[2][0];
    switch (op) {
        case '+': r = a + b; break;
        case '-': r = a - b; break;
        case '*': r = a * b; break;
        case '/':
            if (b == 0) { uart_puts("error: division por cero\r\n"); return; }
            r = a / b; break;
        default: uart_puts("operador invalido (+ - * /)\r\n"); return;
    }
    uart_put_dec(a); uart_putchar(' '); uart_putchar(op); uart_putchar(' ');
    uart_put_dec(b); uart_puts(" = ");  uart_put_dec(r); uart_crlf();
}


// ---------- Pikachu bailarin ----------

static const char *const pika_a[] = {
    "    /\\      /\\     ",
    "   /  \\____/  \\    ",
    "  | (o)    (o) |    ",
    "  |  (  w  )   |    ",
    "   \\  \\___/   /     ",
    "  \\_|        |_/    ",
    "    |  |  |  |      ",
    "    (__)  (__)      ",
};

static const char *const pika_b[] = {
    "    /\\      /\\     ",
    "   /  \\____/  \\    ",
    "  | (^)    (^) |    ",
    "  |  (  w  )   |    ",
    " \\_\\  \\___/  /_/    ",
    "    |        |      ",
    "    /  /  \\  \\      ",
    "   (__)    (__)     ",
};

static const char *const raichu_a[] = {
    "   __        __       ",
    "  /  \\      /  \\  /\\  ",
    "  \\_  \\____/  _/ /  / ",
    "   /  (o)  (o)  \\/  /  ",
    "  |  (O) w (O)  |  /   ",
    "   \\    \\___/   /_/    ",
    "  \\_|          |_/     ",
    "    |   |  |   |       ",
    "    (___)  (___)       ",
};

static const char *const raichu_b[] = {
    "   __        __   /\\  ",
    "  /  \\      /  \\ /  / ",
    "  \\_  \\____/  _/ \\  \\ ",
    "   /  (^)  (^)  \\ /  / ",
    "  |  (O) w (O)  |/ /  ",
    " \\_\\    \\___/   /_/    ",
    "    |          |       ",
    "    /  /    \\  \\       ",
    "   (__)      (__)      ",
};

static void dance_draw(const char *title, const char *const *f, int n) {
    int i;
    uart_puts("\x1b[H");                 // cursor al inicio
    uart_puts(title);
    uart_puts("\r\n\r\n");
    for (i = 0; i < n; i++) { uart_puts(f[i]); uart_crlf(); }
}

static void dance(const char *title,
                  const char *const *fa, const char *const *fb, int n) {
    int i;
    uart_puts("\x1b[2J\x1b[?25l");       // limpia y oculta cursor
    for (i = 0; i < 12; i++) {
        if (i & 1) { dance_draw(title, fb, n); write_leds(0x0A); }
        else       { dance_draw(title, fa, n); write_leds(0x05); }
        delay_cycles(2000000);           // ~0.5 s aprox.
    }
    led_state = 0;
    write_leds(0);
    uart_puts("\x1b[?25h");              // muestra cursor
}

static void cmd_pikachu(void) {
    dance("   PIKA PIKA!           ", pika_a, pika_b, 8);
    uart_puts("\r\nPikaaachu!\r\n");
}

static void cmd_raichu(void) {
    dance("   RAI RAI!             ", raichu_a, raichu_b, 9);
    uart_puts("\r\nRaaaichu!\r\n");
}


// Shell                                                               

static void shell_exec(char *line) {
    char *argv[8];
    int   argc = tokenize(line, argv, 8);
    if (argc == 0) return;

    if      (str_eq(argv[0], "help"))  cmd_help();
    else if (str_eq(argv[0], "about")) uart_puts("picoSoC Shell v1.0 - RISC-V PicoRV32 @ DE10-Lite\r\n");
    else if (str_eq(argv[0], "clear")) uart_puts("\x1b[2J\x1b[H");
    else if (str_eq(argv[0], "led"))   cmd_led(argc, argv);
    else if (str_eq(argv[0], "leds"))  cmd_leds(argc, argv);
    else if (str_eq(argv[0], "sw"))    cmd_sw();
    else if (str_eq(argv[0], "blink")) cmd_blink(argc, argv);
    else if (str_eq(argv[0], "calc"))  cmd_calc(argc, argv);
    else if (str_eq(argv[0], "pika"))  cmd_pikachu();
    else if (str_eq(argv[0], "raichu") || str_eq(argv[0], "raicun")) cmd_raichu();
    else {
        uart_puts("comando desconocido: ");
        uart_puts(argv[0]);
        uart_crlf();
        uart_puts("escribe 'help'\r\n");
    }
}

static void readline(char *buf, int max) {
    int i = 0;
    for (;;) {
        char c = uart_getchar();
        if (c == '\r' || c == '\n') { uart_crlf(); buf[i] = 0; return; }
        else if (c == 0x7f || c == 0x08) {
            if (i > 0) { i--; uart_puts("\b \b"); }
        }
        else if (c >= 32 && c < 127 && i < max - 1) {
            buf[i++] = c;
            uart_putchar(c);
        }
    }
}


// Hardware — DE10-Lite (MAX10, 50 MHz)

#define REG_UART_CLK  (*(volatile uint32_t *)0x02000004)
#define REG_UART_DATA (*(volatile uint32_t *)0x02000008)
#define REG_LEDS      (*(volatile uint32_t *)0x03000000)
#define REG_SWITCHES  (*(volatile uint32_t *)0x03000004)

#define CLK_FREQ   50000000
#define BAUD_RATE  115200

void     uart_putchar(char c)    { REG_UART_DATA = (uint8_t)c; }
int      uart_getchar_nb(void)   { return (int)(int32_t)REG_UART_DATA; }
void     write_leds(uint32_t v)  { REG_LEDS = v; }
uint32_t read_switches(void)     { return REG_SWITCHES; }

int main(void) {
    char line[64];

    // Configura baudrate UART
    REG_UART_CLK = CLK_FREQ / BAUD_RATE;

    write_leds(0);

    uart_puts("\r\n=====================================\r\n");
    uart_puts("   picoSoC Shell - Arquitectura 2026\r\n");
    uart_puts("=====================================\r\n");
    uart_puts("Escribe 'help' para ver los comandos.\r\n");

    for (;;) {
        uart_puts("> ");
        readline(line, sizeof(line));
        shell_exec(line);
    }

    return 0;
}
