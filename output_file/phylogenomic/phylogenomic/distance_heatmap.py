"""import pandas as pd 
import seaborn as sb 
import matplotlib.pyplot as plt

#Lectura matriz de distancias

matriz = pd.read_table ("sarscov2_iqtree.mldist", index_col = 0, delim_whitespace= True, header = None, skiprows=1)

#Asignación de etiquetas a las columnas de la matriz

matriz.columns = matriz.index

#Generación figura 10x10 y titulo

fig, ax = plt.subplots(figsize=(12,12))

#Heatmap con anotaciones

sb.heatmap(matriz, xticklabels=True, yticklabels=True, cmap = "mako", linewidths=".5", square=True, annot=True, fmt=".2f", annot_kws={"size":8}, ax=ax, cbar_kws={"shrink":.8})

#Rotación etiquetas

ax.set_xticklabels(ax.get_xticklabels(),rotation=30, ha='center', fontsize=8)
ax.set_yticklabels(ax.get_yticklabels(),fontsize=8)
ax.set_title("Matriz de Distancias", pad = 20)
fig.subplots_adjust(bottom=0.25, left=0.2)

#Guardar figura png

plt.tight_layout()
plt.savefig("Distance_matrix.png", bbox_inches = "tight")

#Mostrar figura

plt.show()
"""

import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd

# (1) máscara de diagonal
# mask = np.zeros_like(matriz, dtype=bool)
# np.fill_diagonal(mask, True)

#Lectura matriz de distancias

matriz = pd.read_table ("sarscov2.mldist", index_col = 0, delim_whitespace= True, header = None, skiprows=1)

#Asignación de etiquetas a las columnas de la matriz

matriz.columns = matriz.index

# (2) creamos fig y ax
fig, ax = plt.subplots(figsize=(10,10))

# (3) dibujamos el heatmap
sns.heatmap(
    matriz,
    cmap="mako",
    annot=True, fmt=".2f",
    annot_kws={"size":8},
    cbar_kws={"shrink": .8},
    linewidths=.5,
    square=True,
    ax=ax,
    xticklabels=False,  # desactivamos el xticklabels automático
    yticklabels=True
)

# (4) calculamos las posiciones centrales de cada celda
n = matriz.shape[1]
pos = np.arange(n) + 0.5

# (5) fijamos ticks y etiquetas X manualmente
ax.set_xticks(pos)
ax.set_xticklabels(matriz.columns, rotation=45, ha='right', fontsize=10)

# (6) etiquetas Y (salen bien con el automático, pero puedes ajustarlas igual)
ax.set_yticklabels(matriz.index, fontsize=10)

# (7) título y márgenes
ax.set_title("Matriz de Distancias", pad=20)
fig.subplots_adjust(bottom=0.25, left=0.2)

plt.savefig("Distance_matrix_masked_centered.png", bbox_inches="tight")
plt.show()
