# PCA — Preprocesamiento de Variables Meteorológicas

## ¿Qué es PCA?

**PCA (Principal Component Analysis)** es un algoritmo de reducción de dimensionalidad.
Toma N columnas correlacionadas entre sí y las transforma en M columnas nuevas (M < N) llamadas **componentes principales**, que:

- Son **independientes entre sí** (ortogonales)
- Están **ordenadas por varianza explicada** (PC1 explica más que PC2, etc.)
- **No se interpretan directamente** — son combinaciones lineales de las originales

En este proyecto se usa para comprimir **20 columnas de temperatura** de 10 ciudades en **1 sola columna** (`PC1_Weather`).

---

## ¿Por qué se aplica aquí?

Las 10 ciudades de la zona GCRNO tienen climas muy correlacionados: cuando sube la temperatura en Hermosillo, también sube en Caborca, Guaymas, etc. Mandar esas 20 columnas redundantes al LSTM añade ruido sin información nueva.

```
Antes del PCA:  20 columnas muy correlacionadas
                Temperature_Ca, Perceived_Temperature_Ca,
                Temperature_Cul, Perceived_Temperature_Cul,
                ...  (×10 ciudades)

Después del PCA: 1 columna  →  PC1_Weather
                 (señal térmica regional resumida)
```

---

## Flujo completo

```
         ENTRENAMIENTO                          PRODUCCIÓN / INFERENCIA
         ─────────────────────────             ──────────────────────────
         exogen_pca(df_train)                  transform_data(df_new)
              │                                     │
              ▼                                     ▼
         pcafunction(x_clima)            scaler.transform(x_clima)
              │                                     │
              ├─ StandardScaler.fit()               ▼
              │  aprende media y std           pca.transform()
              │                                     │
              ├─ scaler.transform()                 ▼
              │  estandariza los datos         PC1_Weather (nuevo dato)
              │
              ├─ PCA.fit_transform()
              │  calcula componentes
              │
              ▼
         Guarda modelos:
         pca_clima.pkl
         scaler_model_clima.pkl
```

---

## Función 1: `pcafunction` — Núcleo del PCA

```python
def pcafunction(x_data, y_data, num_componentes, name_column, name_index):
    scaler_model = StandardScaler().fit(x_data)
    x = scaler_model.transform(x_data)
    pca = PCA(n_components=num_componentes)
    principalComponents = pca.fit_transform(x)
    pca_df = pd.DataFrame(principalComponents, columns=[f'PC1_{name_column}'])
    pca_df['Date_timed'] = y_data
    return pca, pca_df, scaler_model
```

### Parámetros

| Parámetro | Descripción |
|---|---|
| `x_data` | Array numpy con las 20 columnas de temperatura |
| `y_data` | Timestamps — solo para hacer join después, NO entra al PCA |
| `num_componentes` | Número de componentes a extraer (siempre `1` en este proyecto) |
| `name_column` | Sufijo del nombre de columna resultado (`'Weather'` → `PC1_Weather`) |
| `name_index` | Nombre de la columna llave para el merge posterior (`'Date_timed'`) |

### Paso a paso interno

**Paso 1 — Estandarización**
```python
scaler_model = StandardScaler().fit(x_data)
x = scaler_model.transform(x_data)
```
PCA es sensible a la escala. Si `Temperature` va de 5–45°C y `Humidity` de 10–100%,
PCA daría más peso a Humidity solo por su rango mayor.
`StandardScaler` normaliza cada columna a **media=0 y desviación estándar=1**.

```
Antes:  Temperature_Ca = [11.6, 10.8, 9.5, ...]   (escala °C)
Después: Temperature_Ca = [-0.8, -0.9, -1.1, ...]  (escala z-score)
```

**Paso 2 — Ajuste y transformación PCA**
```python
pca = PCA(n_components=1)
principalComponents = pca.fit_transform(x)
```
- `.fit()` calcula la dirección de máxima varianza en el espacio de 20 dimensiones
- `.transform()` proyecta cada fila sobre esa dirección → resultado: 1 valor por hora
- Ese valor es `PC1_Weather`: un número que resume el estado térmico regional en esa hora

**Paso 3 — Empaquetado en DataFrame**
```python
pca_df = pd.DataFrame(principalComponents, columns=['PC1_Weather'])
pca_df['Date_timed'] = y_data
```
Se agrega el timestamp para poder hacer join con el resto de variables después.

### Retorna
| Variable | Contenido |
|---|---|
| `pca` | Objeto PCA entrenado (se guarda como `.pkl`) |
| `pca_df` | DataFrame con columnas `PC1_Weather` y `Date_timed` |
| `scaler_model` | Objeto StandardScaler entrenado (se guarda como `.pkl`) |

---

## Función 2: `exogen_pca` — Entrenamiento completo

```python
def exogen_pca(dataframe, var_index):
    dfvar = dataframe[energy + date + temperature + calendar]
    dfvar['Date_timed'] = dfvar.index
    y = dataframe.loc[:, [var_index]].values

    x_clima = dataframe.loc[:, 'Temperature_Ca':'Perceived_Temperature_Obr'].values
    pca_clima, pca_df_clima, scaler_model_clima = pcafunction(x_clima, y, 1, 'Weather', var_index)

    pca_df = pd.merge(pca_df_clima, dfvar, left_on=var_index, right_on='Date_timed', how='left')
    del pca_df['Date_timed']

    return pca_df, pca_clima, scaler_model_clima
```

**Se llama solo una vez con los datos de entrenamiento.**

### Paso a paso

1. Selecciona todas las columnas relevantes: `energy + date + temperature + calendar`
2. Extrae solo las 20 columnas de temperatura como array numpy (`x_clima`)
3. Llama a `pcafunction` → entrena scaler + PCA, obtiene `PC1_Weather`
4. Hace **merge** entre `PC1_Weather` y el resto de variables usando `Date_timed` como llave
5. Elimina la columna `Date_timed` duplicada

### DataFrame de salida (`pca_df`)

```
Date_timed | PC1_Weather | Energy_Demand | Hour | Day | Month | Tuesday_Aft_Hol | ...
──────────────────────────────────────────────────────────────────────────────────────
2010-01-01  |   -1.23    |    1450.5     |  1   |  4  |   1   |        0        | ...
2010-01-01  |   -1.31    |    1380.2     |  2   |  4  |   1   |        0        | ...
```

Las 20 columnas de temperatura fueron reemplazadas por **1 sola columna `PC1_Weather`**.

---

## Función 3: `transform_data` — Inferencia (producción)

```python
def transform_data(dataframe, var_index, pca_clima, scaler_model_clima):
    dfvar = dataframe[energy + date + temperature + calendar]
    dfvar['Date_timed'] = dfvar.index
    y = dfvar.index

    x_clima = dataframe.loc[:, 'Temperature_Ca':'Perceived_Temperature_Obr'].values
    x_df_clima = scaler_model_clima.transform(x_clima)   # NO .fit()
    clima = pca_clima.transform(x_df_clima)               # NO .fit()
    df_clima = new_dataframe(clima, y, 'Weather', var_index)

    pca_df = pd.merge(df_clima, dfvar, left_on=var_index, right_on='Date_timed', how='left')
    return pca_df
```

**Se llama con datos de validación, test o datos nuevos de pronóstico.**

### Diferencia clave con `exogen_pca`

| | `exogen_pca` | `transform_data` |
|---|---|---|
| Scaler | `.fit_transform()` — aprende parámetros | `.transform()` — aplica los ya aprendidos |
| PCA | `.fit_transform()` — calcula componentes | `.transform()` — proyecta sobre componentes ya calculadas |
| Cuándo se usa | Solo con datos de **entrenamiento** | Con datos de **validación, test y pronóstico** |

> **Regla crítica:** Nunca se debe hacer `.fit()` con datos de validación o test.
> Si se recalcularan los parámetros del scaler con datos nuevos, se produciría **data leakage**
> (el modelo "vería" el futuro durante el entrenamiento).

---

## Función 4: `new_dataframe` — Helper auxiliar

```python
def new_dataframe(my_array, y_data, name_column, name_index):
    df = pd.DataFrame(my_array, columns=[f'PC1_{name_column}'])
    df['Date_timed'] = y_data
    return df
```

Simplemente convierte el array numpy resultado del PCA en un DataFrame con nombre de columna y timestamps. Solo existe para evitar repetir ese código en `transform_data`.

---

## Resumen visual del resultado

```
df_input (antes del PCA)               df_input (después del PCA)
────────────────────────               ───────────────────────────
Energy_Demand                          Energy_Demand
Hour                                   Hour
Day                                    Day
Month                                  Month
Temperature_Ca          ─┐             PC1_Weather  ← 20 columnas → 1
Perceived_Temperature_Ca │
Temperature_Cul          │ PCA
Perceived_Temperature_Cul│ ────►
...                      │
Temperature_Obr          │
Perceived_Temperature_Obr─┘
Tuesday_Aft_Hol                        Tuesday_Aft_Hol
Easter_week                            Easter_week
...                                    ...
Monday_Holiday                         Monday_Holiday

Total: 34 columnas                     Total: 15 columnas  ✓
```

Estas 15 columnas son exactamente la forma de entrada del encoder LSTM: `(None, 180, 15)`.
