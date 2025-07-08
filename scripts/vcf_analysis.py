import os
import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict

def count_variants(vcf_file):
    """Cuenta variantes en archivo VCF (excluye headers)"""
    try:
        with open(vcf_file, 'r') as f:
            return sum(1 for line in f if not line.startswith('#'))
    except FileNotFoundError:
        print(f"Archivo no encontrado: {vcf_file}")
        return 0

def plot_variants():
    # Configurar datos
    samples = ['SRR33190466', 'SRR33436961']
    pipelines = ['pipecov', 'viralrecon', 'vpipe', 'pipecovX']
    
    # Diccionario para almacenar conteos
    data = defaultdict(list)
    
    # Leer archivos VCF (ajusta los nombres según tus archivos)
    for sample in samples:
        for pipeline in pipelines:
            vcf_file = f"{sample}_{pipeline}.vcf"  # Ajusta formato según tus archivos
            count = count_variants(vcf_file)
            data[pipeline].append(count)
            print(f"{vcf_file}: {count} variantes")
    
    # Crear gráfico
    x = np.arange(len(samples))
    width = 0.2
    
    fig, ax = plt.subplots(figsize=(12, 6))
    
    # Barras para cada pipeline
    bars1 = ax.bar(x - 1.5*width, data['pipecov'], width, label='pipecov', alpha=0.8)
    bars2 = ax.bar(x - 0.5*width, data['viralrecon'], width, label='viralrecon', alpha=0.8)
    bars3 = ax.bar(x + 0.5*width, data['vpipe'], width, label='v-pipe', alpha=0.8)
    bars4 = ax.bar(x + 1.5*width, data['pipecovX'], width, label='pipecovX', alpha=0.8)
    
    # Configurar gráfico
    ax.set_xlabel('Muestras')
    ax.set_ylabel('Número de Variantes')
    ax.set_title('Comparación de Variantes Detectadas por Pipeline')
    ax.set_xticks(x)
    ax.set_xticklabels(samples)
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Añadir valores en las barras
    for bars in [bars1, bars2, bars3, bars4]:
        for bar in bars:
            height = bar.get_height()
            ax.annotate(f'{int(height)}',
                       xy=(bar.get_x() + bar.get_width() / 2, height),
                       xytext=(0, 3),
                       textcoords="offset points",
                       ha='center', va='bottom')
    
    plt.tight_layout()
    
    # Guardar el gráfico
    plt.savefig('comparacion_variantes_pipelines.png', dpi=300, bbox_inches='tight')
    plt.savefig('comparacion_variantes_pipelines.pdf', bbox_inches='tight')
    print("Gráfico guardado como 'comparacion_variantes_pipelines.png' y '.pdf'")
    
    plt.show()
    
    # Mostrar resumen
    print("\nResumen:")
    for pipeline in pipelines:
        total = sum(data[pipeline])
        print(f"{pipeline}: {total} variantes totales")

if __name__ == "__main__":
    plot_variants()