import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns
from collections import defaultdict

def read_fasta(fasta_file):
    """Lee archivo FASTA y retorna la secuencia concatenada"""
    try:
        with open(fasta_file, 'r') as f:
            sequence = ""
            for line in f:
                if not line.startswith('>'):
                    sequence += line.strip()
        return sequence.upper()
    except FileNotFoundError:
        print(f"Archivo no encontrado: {fasta_file}")
        return ""

def count_n_bases(sequence):
    """Cuenta bases indeterminadas (N y n)"""
    return sequence.count('N') + sequence.count('n')

def plot_n_comparison():
    # Configurar datos
    samples = ['SRR33190466', 'SRR33436961']
    pipelines = ['pipecov', 'viralrecon', 'vpipe']
    
    # Diccionario para almacenar conteos
    data = defaultdict(list)
    sequences_info = {}
    
    print("Analizando archivos FASTA...")
    print("-" * 50)
    
    # Leer archivos FASTA
    for sample in samples:
        for pipeline in pipelines:
            fasta_file = f"{sample}_{pipeline}_consensus.fasta"  # Ajusta según tu naming
            sequence = read_fasta(fasta_file)
            
            if sequence:
                n_count = count_n_bases(sequence)
                total_length = len(sequence)
                percentage = (n_count / total_length * 100) if total_length > 0 else 0
                
                data[pipeline].append(n_count)
                sequences_info[f"{sample}_{pipeline}"] = {
                    'n_count': n_count,
                    'total_length': total_length,
                    'percentage': percentage
                }
                
                print(f"{fasta_file}:")
                print(f"  - Longitud total: {total_length:,} bp")
                print(f"  - Bases N: {n_count:,} ({percentage:.2f}%)")
            else:
                data[pipeline].append(0)
    
    # Crear figura con subplots
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))
    
    # === GRÁFICO 1: Barras agrupadas (conteo absoluto) ===
    x = np.arange(len(samples))
    width = 0.25
    
    colors = ['#2E86AB', '#A23B72', '#F18F01']
    
    bars1 = ax1.bar(x - width, data['pipecov'], width, label='pipecov', 
                    color=colors[0], alpha=0.8)
    bars2 = ax1.bar(x, data['viralrecon'], width, label='viralrecon', 
                    color=colors[1], alpha=0.8)
    bars3 = ax1.bar(x + width, data['vpipe'], width, label='vpipe', 
                    color=colors[2], alpha=0.8)
    
    ax1.set_xlabel('Muestras')
    ax1.set_ylabel('Número de Bases N')
    ax1.set_title('Bases Indeterminadas por Pipeline\n(Conteo Absoluto)')
    ax1.set_xticks(x)
    ax1.set_xticklabels(samples)
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    
    # Añadir valores en las barras
    for bars in [bars1, bars2, bars3]:
        for bar in bars:
            height = bar.get_height()
            if height > 0:
                ax1.annotate(f'{int(height):,}',
                           xy=(bar.get_x() + bar.get_width() / 2, height),
                           xytext=(0, 3),
                           textcoords="offset points",
                           ha='center', va='bottom', fontsize=9)
    
    # === GRÁFICO 2: Heatmap (porcentajes) ===
    # Preparar datos para heatmap
    heatmap_data = []
    for sample in samples:
        row = []
        for pipeline in pipelines:
            key = f"{sample}_{pipeline}"
            if key in sequences_info:
                row.append(sequences_info[key]['percentage'])
            else:
                row.append(0)
        heatmap_data.append(row)
    
    heatmap_data = np.array(heatmap_data)
    
    # Crear heatmap
    im = ax2.imshow(heatmap_data, cmap='Reds', aspect='auto')
    
    # Configurar heatmap
    ax2.set_xticks(np.arange(len(pipelines)))
    ax2.set_yticks(np.arange(len(samples)))
    ax2.set_xticklabels(pipelines)
    ax2.set_yticklabels(samples)
    ax2.set_xlabel('Pipelines')
    ax2.set_ylabel('Muestras')
    ax2.set_title('Porcentaje de Bases Indeterminadas\n(Heatmap)')
    
    # Añadir valores en el heatmap
    for i in range(len(samples)):
        for j in range(len(pipelines)):
            text = ax2.text(j, i, f'{heatmap_data[i, j]:.2f}%',
                           ha="center", va="center", color="black", fontweight='bold')
    
    # Añadir colorbar
    cbar = plt.colorbar(im, ax=ax2)
    cbar.set_label('Porcentaje de Bases N (%)')
    
    plt.tight_layout()
    
    # Guardar gráficos
    plt.savefig('comparacion_bases_N.png', dpi=300, bbox_inches='tight')
    plt.savefig('comparacion_bases_N.pdf', bbox_inches='tight')
    print(f"\nGráfico guardado como 'comparacion_bases_N.png' y '.pdf'")
    
    plt.show()
    
    # Mostrar resumen
    print("\n" + "="*60)
    print("RESUMEN POR PIPELINE:")
    print("="*60)
    for pipeline in pipelines:
        total_n = sum(data[pipeline])
        print(f"{pipeline.upper()}: {total_n:,} bases N totales")
    
    print("\nDETALLE POR MUESTRA:")
    print("-"*60)
    for sample in samples:
        print(f"\n{sample}:")
        for pipeline in pipelines:
            key = f"{sample}_{pipeline}"
            if key in sequences_info:
                info = sequences_info[key]
                print(f"  {pipeline}: {info['n_count']:,} N ({info['percentage']:.2f}%)")

if __name__ == "__main__":
    plot_n_comparison()