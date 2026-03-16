
# 📊 Simulador FIC — Fondo de Inversión Colectiva

> **Proyecto académico-práctico** desarrollado en el marco de la carrera
> de **Economía**, que replica la operación de un Fondo de Inversión
> Colectiva (FIC) real: contabilidad diaria de activos, seguimiento de
> inversionistas, métricas de riesgo y pronóstico econométrico del Valor
> de la Unidad mediante un modelo **ARIMA(3,1,3) + GARCH(1,1)**.

------------------------------------------------------------------------

## 🗂️ Estructura del Repositorio

```         
simulador-fic/
│
├── simulador.xlsx          # Libro de trabajo principal (Google Sheets → Excel)
├── ARIMAGARCH.R            # Script R: modelo de series de tiempo y riesgo
└── README.md
```

------------------------------------------------------------------------

## 🧠 Contexto Económico

Un **Fondo de Inversión Colectiva (FIC)** es un vehículo de inversión
regulado (Decreto 1242 de 2013, Colombia) en el que varios
inversionistas aportan capital que es administrado colectivamente. El
rendimiento se distribuye mediante el mecanismo de **valor de la unidad
(VU)**: cada depósito compra unidades al precio del día; el crecimiento
del VU refleja la valorización del portafolio.

Este simulador replica esa lógica aplicando herramientas de: -
**Macroeconomía financiera**: valoración de portafolios mixtos (renta
fija + renta variable + efectivo) donde en renta fija se valoran CDT, 
Deuda corporativa o microcrédito con distintas tasas y tiempo, renta variable 
corresponden acciones de la BVC y el MGC seleccionadas aleatoriamente
- **Econometría de series de tiempo**:
ARIMA para la tendencia, GARCH para la volatilidad condicional -
**Gestión del riesgo**: VaR paramétrico diario y a 10 días (estándar de
Basilea), Expected Shortfall (ES), Maximum Drawdown (MDD) - **Análisis
de benchmark**: comparación del VU frente al índice COLCAP

------------------------------------------------------------------------

## 📋 Descripción de las Hojas del Simulador (`simulador.xlsx`)

### 1. `FVA` — Panel de Control Principal

Dashboard del fondo. Concentra los indicadores clave en tiempo real:

| Sección | Contenido |
|----|----|
| **Resumen del fondo** | Fecha de inicio, días en operación, total depositado, unidades circulantes |
| **Valor de la Unidad** | VU inicial (base $10.000), VU actual, VU máximo histórico |
| **Rentabilidad** | Ganancia acumulada, tasa efectiva anual (EA), rentabilidad del período |
| **Cartera de activos** | Valor de depósito vs. valor actual de cada activo, variación % |
| **Indicadores adicionales** | Efectivo disponible, activos totales, comisión de administración |

> El VU se calcula como:
> `VU = Volumen Total del Portafolio / Unidades Circulantes`

------------------------------------------------------------------------

### 2. `DATOS` — Registro Histórico Diario

Serie temporal completa desde la fecha de inicio del fondo. Para cada
día registra:

-   `DEPOSITO`: nuevas suscripciones del día
-   `TOTAL`: capital total depositado acumulado
-   `UNIDADES`: unidades en circulación
-   `VOLUMEN`: valor de mercado del portafolio
-   `GANANCIA`: variación diaria del portafolio
-   `RENTABILIDAD`: rentabilidad acumulada del fondo

Esta hoja es la fuente principal para el análisis econométrico en R.

------------------------------------------------------------------------

### 3. `GRAFICO` — Métricas Técnicas y de Riesgo

Hoja de soporte para visualizaciones. Calcula para cada día:

| Métrica | Descripción económica |
|----|----|
| `Valor Unidad` | Precio diario de la unidad |
| `EMA-5 / EMA-15 / EMA-50` | Medias móviles exponenciales (señales de tendencia) |
| `Pronóstico / Bandas` | Intervalo de confianza ARIMA+GARCH |
| `Variación % diaria` | Retorno logarítmico diario |
| `Desviación estándar` | Volatilidad realizada |
| `Desviación anualizada` | Volatilidad anualizada (× √252) |
| `VaR histórico` | Value at Risk al 95% de confianza |
| `VaR (30 días)` | VaR de horizonte mensual |
| `MDD` | Maximum Drawdown: caída máxima desde el pico |

------------------------------------------------------------------------

### 4. `BALANCE` — Estado Financiero del Fondo

Balance contable que separa:

-   **Activos brutos**: valor total de mercado del portafolio
-   **Pasivos**: apalancamiento y obligaciones
-   **Activo neto**: patrimonio real del fondo
-   **Distribución**: peso de renta fija, renta variable y efectivo
-   **Liquidez**: activos líquidos vs. ilíquidos

Permite evaluar la **estructura de capital** del fondo y su nivel de
apalancamiento.

------------------------------------------------------------------------

### 5. `CUENTAS` — Registro Diario por Activo

Tabla de doble entrada `[fecha × activo]`. Registra el valor de mercado
de cada uno de los **20 activos** del portafolio día a día, junto con:

-   `CARTERA`: valor total de todos los activos
-   `ACTIVOS`: activos + efectivo
-   `APALANCAMIENTO`: deuda contratada
-   `GASTOS`: comisiones y gastos operativos
-   `ACTIVO BRUTO`: suma total
-   `EFC/ACT`: ratio efectivo / activos totales

Esta hoja permite calcular la **contribución individual** de cada activo
al rendimiento del fondo.

------------------------------------------------------------------------

### 6. `COLCAP VS VU` — Análisis de Benchmark

Compara el desempeño del fondo contra el **índice COLCAP** (índice
bursátil de referencia de la Bolsa de Valores de Colombia). Ambas series
se reescalan a base 1 en la fecha inicial para hacer comparables sus
trayectorias.

Indicadores calculados: - **Correlación** entre el VU y el COLCAP -
**Varianza** de cada serie - **Diferencia máxima** (alfa máximo generado
vs. el índice)

> Una correlación alta indica exposición sistémica al mercado accionario
> colombiano.

------------------------------------------------------------------------

### 7. `FACTURAS` — Comprobantes de Transacciones

Genera el recibo de inversión individual por cliente. Para cada
inversionista muestra:

-   Fecha y VU de cada depósito realizado
-   Unidades adquiridas por transacción
-   Valorización actual de cada depósito

Útil para la **rendición de cuentas** con cada inversionista.

------------------------------------------------------------------------

### 8. `CLIENTES` — Resumen Consolidado por Inversionista

Tabla resumen con la posición actual de cada inversionista:

| Columna | Descripción |
|----|----|
| `Cantidad` | Unidades en poder del inversionista |
| `CProm. Uni` | Costo promedio de adquisición por unidad |
| `Depósito` | Capital total invertido |
| `Valorización` | Valor actual de su participación |
| `Diferencia` | Ganancia o pérdida absoluta |
| `Rentabilidad` | Retorno porcentual desde el primer depósito |
| `TIR` | Tasa Interna de Retorno individual (flujos de caja descontados) |

La **TIR** es la métrica clave para el inversionista, ya que pondera el
momento de cada depósito.

------------------------------------------------------------------------

### 9. `INVERSIONISTAS` — Historial Completo de Depósitos

Registro granular de **cada transacción** realizada por cada
inversionista, con:

-   Fecha exacta del depósito
-   VU vigente al momento de la transacción
-   Unidades adquiridas
-   Rentabilidad individual desde esa fecha
-   Rentabilidad anualizada del depósito

Permite reconstruir el **costo promedio ponderado** y la TIR individual.

------------------------------------------------------------------------

### 10. `F.graficos` — Datos Auxiliares para Visualización

Alimenta los gráficos del panel. Contiene:

-   **Histograma de rendimientos** del VU (distribución empírica diaria)
-   **Histograma de rendimientos extremos** (colas de la distribución)
-   **Evolución anual del VU**: series separadas por año (2024, 2025,
    2026) con sus retornos logarítmicos
-   **Retornos diarios por activo**: para análisis de correlación y
    diversificación

------------------------------------------------------------------------

### 11. `ECO 2` — Serie Temporal para Modelado Econométrico

Exporta la serie limpia `[FECHA, VU]` que se importa directamente al
script R para el análisis ARIMA+GARCH. Actúa como interfaz entre el
modelo de hoja de cálculo y el modelo econométrico.

------------------------------------------------------------------------

## 📉 Modelo Econométrico (`ARIMAGARCH.R`)

### Metodología

El script implementa la **metodología Box-Jenkins** para modelar y
pronosticar el Valor de la Unidad:

```         
Retorno log-diario: r_t = ln(VU_t) - ln(VU_{t-1})
```

#### Paso 1 — Estadística Descriptiva

-   Media, mediana, varianza, desviación estándar, asimetría (skewness),
    curtosis
-   Graficación de la serie original y de los retornos

#### Paso 2 — Modelo ARIMA(3,1,3)

-   Se aplica sobre el **nivel** del VU con transformación Box-Cox (λ=0,
    equivalente a logaritmo)
-   El orden (3,1,3) captura la dinámica autorregresiva de la serie

#### Paso 3 — Diagnóstico de Residuos ARIMA

-   Prueba de Ljung-Box sobre los residuos (hipótesis nula: residuos son
    ruido blanco)
-   ACF de residuos, QQ-plot para normalidad

#### Paso 4 — Modelo GARCH(1,1) sobre los Residuos

-   Especificación: `sGARCH(1,1)` con distribución t de Student
-   Captura la **heterocedasticidad condicional** (clusters de
    volatilidad)
-   Volatilidad condicional σ_t estimada diariamente

#### Paso 5 — Gestión del Riesgo

| Métrica | Fórmula | Interpretación |
|----|----|----|
| **VaR diario (95%)** | `-(μ_t + z_{0.05} · σ_t) · Inversión` | Pérdida máxima diaria con 95% de confianza |
| **VaR 10 días** | `VaR_diario × √10` | Estándar regulatorio de Basilea II/III |
| **Expected Shortfall (ES)** | `-(μ_t + φ(z_{0.05})/0.05 · σ_t) · Inversión` | Pérdida esperada más allá del VaR |

#### Paso 6 — Pronóstico a 5 días

-   Pronóstico puntual de la **media** (ARIMA)
-   Pronóstico de la **volatilidad condicional** (GARCH)
-   Intervalos de confianza ajustados por GARCH: `[μ̂ ± 1.96·σ̂_t]`

### Librerías R Utilizadas

``` r
rugarch      # Modelos GARCH univariados
forecast     # ARIMA automático y pronóstico
tseries      # Pruebas de raíz unitaria
urca         # Cointegración y pruebas unitarias
moments      # Asimetría y curtosis
ggplot2      # Visualización
```

------------------------------------------------------------------------

## 🚀 Cómo Usar el Proyecto

### Excel / Google Sheets

1.  Abrir `simulador.xlsx` o importar a Google Sheets
2.  En la hoja `CUENTAS`, actualizar diariamente el valor de mercado de
    cada activo
3.  Los indicadores del panel `FVA`, el `BALANCE` y los gráficos se
    actualizan automáticamente
4.  Registrar nuevos depósitos en la hoja `INVERSIONISTAS`

### Script R

1.  Instalar dependencias:

``` r
install.packages(c("rugarch", "forecast", "tseries", "urca", "moments", "ggplot2", "easypackages"))
```

2.  Exportar la hoja `ECO 2` como CSV y cargarla:

``` r
datos <- read.csv("eco2.csv")
```

3.  Ejecutar el script completo (`ARIMAGARCH.R`)

------------------------------------------------------------------------

## 📐 Conceptos Económicos Aplicados

| Concepto | Aplicación en el proyecto |
|----|----|
| **Teoría de portafolios (Markowitz)** | Diversificación en renta fija, variable y efectivo |
| **Valor del dinero en el tiempo** | TIR individual por inversionista |
| **Hipótesis de mercados eficientes** | Contrastada mediante diagnóstico de residuos (Ljung-Box) |
| **Riesgo sistémico vs. idiosincrático** | Correlación con COLCAP como benchmark |
| **Regulación financiera** | VaR a 10 días según estándar de Basilea |
| **Series de tiempo financieras** | Retornos log-normales, heterocedasticidad condicional |

------------------------------------------------------------------------

## ⚠️ Advertencia

Este proyecto es de carácter **académico y demostrativo**. Los nombres
de activos e inversionistas son ficticios. No constituye asesoría
financiera ni oferta de inversión.

------------------------------------------------------------------------

## 👤 Autor

Emmanuel Pérez López - Jose Alejandro Salgado
Estudiantes de **Economía** — Proyecto de gestión de portafolios e
introducción a las finanzas cuantitativas.

------------------------------------------------------------------------

*Medellín, Colombia · 2024-2026*
