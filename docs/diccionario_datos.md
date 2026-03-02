# Diccionario de Datos

Dataframe de entrada al modelo de pronóstico de demanda eléctrica horaria para la región **GCRNO**.
Combina datos históricos de consumo energético, variables meteorológicas de 10 ciudades y festivos del calendario mexicano.

- **Índice:** `Date_timed` (`DatetimeIndex`, frecuencia horaria)
- **Total de columnas:** 75
- **Granularidad:** Horaria

---

## Grupos de columnas

### 1. Objetivo (`energy`)

| Columna | Tipo | Unidad | Descripción |
|---|---|---|---|
| `Energy_Demand` | `float64` | MW | Demanda de energía eléctrica de la zona GCRNO. Variable objetivo del modelo. Para filas futuras se inicializa en `0` |

---

### 2. Temporales (`date`)

| Columna | Tipo | Valores | Descripción |
|---|---|---|---|
| `Hour` | `int64` | 0 – 23 | Hora del día en formato 0–23 |
| `Day` | `int64` | 0 – 6 | Día de la semana (0 = lunes, 6 = domingo) |
| `Month` | `int64` | 1 – 12 | Mes del año |

---

### 3. Marca de tiempo (`date_time`)

| Columna | Tipo | Descripción |
|---|---|---|
| `Date_timed` | `datetime64` | Timestamp completo del registro. También actúa como índice del dataframe |

---

### 4. Calendario festivo mexicano (`calendar`)

Indicadores binarios (`0` / `1`) que señalan si el timestamp corresponde a un periodo especial de consumo:

| Columna | Tipo | Festivo / Periodo |
|---|---|---|
| `Tuesday_Aft_Hol` | `int64` | Martes posterior a un lunes festivo |
| `Easter_week` | `int64` | Semana Santa |
| `May_1s` | `int64` | 1 de mayo — Día del Trabajo |
| `May_10t` | `int64` | 10 de mayo — Día de las Madres |
| `Sept_16` | `int64` | 16 de septiembre — Independencia de México |
| `Nov_2nd` | `int64` | 2 de noviembre — Día de Muertos |
| `Before_Christmas_NY` | `int64` | Víspera de Navidad y Año Nuevo (24 dic / 31 dic) |
| `Christmas_NY` | `int64` | Navidad y Año Nuevo (25 dic / 1 ene) |
| `After_Christmas_NY` | `int64` | Días posteriores a Navidad y Año Nuevo |
| `Monday_Holiday` | `int64` | Lunes festivo oficial (ley de puentes) |

---

### 5. Variables meteorológicas por ciudad (`temperature` + resto)

7 variables meteorológicas medidas en cada una de las **10 ciudades** de la zona GCRNO.
Sufijo de ciudad en el nombre de columna: `_Ca`, `_Cul`, `_Guas`, `_Guay`, `_Herm`, `_Maz`, `_Moch`, `_Nav`, `_Nog`, `_Obr`.

#### Variables (×10 ciudades = 70 columnas)

| Variable | Tipo | Unidad | Descripción |
|---|---|---|---|
| `Temperature_{city}` | `float64` | °C | Temperatura del aire |
| `Perceived_Temperature_{city}` | `float64` | °C | Temperatura percibida (sensación térmica) |
| `Precipitation_{city}` | `float64` | mm | Precipitación acumulada en el periodo |
| `Humidity_{city}` | `float64` | % | Humedad relativa del aire |
| `Wind_Velocity_{city}` | `float64` | m/s | Velocidad del viento |
| `Solar_Radiation_{city}` | `float64` | W/m² | Radiación solar global horizontal |
| `Cloudiness_{city}` | `float64` | % | Cobertura de nubes |

#### Ciudades y sufijos

| Sufijo | Ciudad | Estado |
|---|---|---|
| `_Ca` | Caborca | Sonora |
| `_Cul` | Culiacán | Sinaloa |
| `_Guas` | Guasave | Sinaloa |
| `_Guay` | Guaymas | Sonora |
| `_Herm` | Hermosillo | Sonora |
| `_Maz` | Mazatlán | Sinaloa |
| `_Moch` | Los Mochis | Sinaloa |
| `_Nav` | Navojoa | Sonora |
| `_Nog` | Nogales | Sonora |
| `_Obr` | Ciudad Obregón | Sonora |

---

## Resumen de columnas

| Grupo | Cantidad | Tipo |
|---|---|---|
| Objetivo | 1 | `float64` |
| Temporales | 3 | `int64` |
| Marca de tiempo | 1 | `datetime64` |
| Calendario festivo | 10 | `int64` |
| Meteorológicas (7 × 10 ciudades) | 70 | `float64` |
| **Total** | **85** | |

---

## Origen de los datos

| Dato | Fuente |
|---|---|
| `Energy_Demand` | Archivo histórico GCRNO (`GCRNO_example_input.xlsx`) |
| Variables meteorológicas | Meteomatics API (pronóstico y datos históricos) |
| Indicadores de festivos | Dataset calendario mexicano (`df_dataset_calendario`) |
