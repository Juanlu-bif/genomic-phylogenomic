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
        return sequence
    except FileNotFoundError:
        print(f"Archivo no encontrado: {fasta_file}")
        return ""

def plot_length_comparison():
    # Configurar datos
    samples = ['SRR33190466', 'SRR33436961']
    pipelines = ['pipecov', 'viralrecon', 'vpipe']
    
    # Diccionario para almacenar longitudes
    data = defaultdict(list)
    length_info = {}
    
    print("Analizando longitudes de genoma...")
    print("-" * 50)
    
    # Leer genoma de referencia
    ref_file = "SARS_CoV2_GenRef_NC_045512.2.fasta"
    ref_sequence = read_fasta(ref_file)
    
    if ref_sequence:
        reference_length = len(ref_sequence)
        print(f"Genoma de referencia: {reference_length:,} bp")
    else:
        reference_length = 29903  # Valor por defecto SARS-CoV-2
        print(f"Usando longitud por defecto: {reference_length:,} bp")
    
    print("-" * 50)
    
    # Leer archivos FASTA de consensus
    for sample in samples:
        for pipeline in pipelines:
            fasta_file = f"{sample}_{pipeline}_consensus.fasta"
            sequence = read_fasta(fasta_file)
            
            if sequence:
                length = len(sequence)
                diff = length - reference_length
                percentage = (length / reference_length * 100) if reference_length > 0 else 0
                
                data[pipeline].append(length)
                length_info[f"{sample}_{pipeline}"] = {
                    'length': length,
                    'difference': diff,
                    'percentage': percentage
                }
                
                print(f"{fasta_file}:")
                print(f"  - Longitud: {length:,} bp")
                print(f"  - Diferencia: {diff:+,} bp ({percentage:.2f}% de la ref.)")
            else:
                data[pipeline].append(0)
    
    # Crear figura con 2 subplots
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(18, 8))
    
    # === GRÁFICO 1: Barras Horizontales Agrupadas por Muestra ===
    
    # Configuración de colores y posiciones
    colors = ['#2E86AB', '#A23B72', '#F18F01']
    color_map = {'pipecov': colors[0], 'viralrecon': colors[1], 'vpipe': colors[2]}
    
    # Configurar posiciones para barras agrupadas
    n_samples = len(samples)
    n_pipelines = len(pipelines)
    bar_height = 0.25
    
    # Crear posiciones y para cada grupo de muestras
    sample_positions = np.arange(n_samples) * (n_pipelines * bar_height + 0.5)
    
    # Crear las barras agrupadas
    for i, pipeline in enumerate(pipelines):
        pipeline_lengths = []
        y_positions = []
        
        for j, sample in enumerate(samples):
            key = f"{sample}_{pipeline}"
            if key in length_info:
                pipeline_lengths.append(length_info[key]['length'])
            else:
                pipeline_lengths.append(0)
            
            # Calcular posición y para esta barra específica
            y_pos = sample_positions[j] + i * bar_height
            y_positions.append(y_pos)
        
        # Crear barras horizontales para este pipeline
        bars = ax1.barh(y_positions, pipeline_lengths, bar_height, 
                       label=pipeline.capitalize(), color=color_map[pipeline], 
                       alpha=0.8, edgecolor='white', linewidth=0.5)
        
        # Añadir valores en las barras
        for bar, length in zip(bars, pipeline_lengths):
            if length > 0:
                ax1.text(length + reference_length * 0.002, 
                        bar.get_y() + bar.get_height()/2,
                        f'{length:,}', ha='left', va='center', 
                        fontsize=8, fontweight='bold')
    
    # Línea de referencia vertical
    ax1.axvline(x=reference_length, color='red', linestyle='--', linewidth=2, 
                label=f'Referencia ({reference_length:,} bp)', alpha=0.8)
    
    # Configurar etiquetas del eje y
    sample_centers = sample_positions + (n_pipelines - 1) * bar_height / 2
    ax1.set_yticks(sample_centers)
    ax1.set_yticklabels(samples, fontsize=11, fontweight='bold')
    
    # Configuración del gráfico
    ax1.set_xlabel('Longitud del Genoma (bp)', fontsize=12)
    ax1.set_ylabel('Muestras', fontsize=12)
    ax1.set_title('Comparación de Longitudes de Genoma por Muestra y Pipeline', 
                  fontsize=14, fontweight='bold')
    ax1.legend(loc='lower right', frameon=True, fancybox=True, shadow=True)
    ax1.grid(True, alpha=0.3, axis='x')
    
    # Añadir separadores entre grupos de muestras
    for i in range(1, len(samples)):
        separator_y = (sample_positions[i-1] + sample_positions[i]) / 2
        ax1.axhline(y=separator_y, color='gray', linestyle='-', alpha=0.3, linewidth=0.5)
    
    # === GRÁFICO 2: Heatmap de porcentajes (sin cambios) ===
    heatmap_data = []
    for sample in samples:
        row = []
        for pipeline in pipelines:
            key = f"{sample}_{pipeline}"
            if key in length_info:
                row.append(length_info[key]['percentage'])
            else:
                row.append(0)
        heatmap_data.append(row)
    
    heatmap_data = np.array(heatmap_data)
    
    im = ax2.imshow(heatmap_data, cmap='RdBu_r', aspect='auto', vmin=95, vmax=105)
    ax2.set_xticks(np.arange(len(pipelines)))
    ax2.set_yticks(np.arange(len(samples)))
    ax2.set_xticklabels([p.capitalize() for p in pipelines], fontsize=11)
    ax2.set_yticklabels(samples, fontsize=11, fontweight='bold')
    ax2.set_xlabel('Pipelines', fontsize=12)
    ax2.set_ylabel('Muestras', fontsize=12)
    ax2.set_title('Porcentaje vs Referencia (%)', fontsize=14, fontweight='bold')
    
    # Añadir valores en el heatmap
    for i in range(len(samples)):
        for j in range(len(pipelines)):
            if heatmap_data[i, j] > 0:
                color = 'white' if abs(heatmap_data[i, j] - 100) > 2 else 'black'
                ax2.text(j, i, f'{heatmap_data[i, j]:.1f}%',
                        ha="center", va="center", color=color, fontweight='bold')
    
    plt.colorbar(im, ax=ax2, label='Porcentaje de la referencia (%)')
    
    plt.tight_layout()
    
    # Guardar gráficos
    plt.savefig('comparacion_longitudes_genoma_agrupado.png', dpi=300, bbox_inches='tight')
    plt.savefig('comparacion_longitudes_genoma_agrupado.pdf', bbox_inches='tight')
    print(f"\nGráfico guardado como 'comparacion_longitudes_genoma_agrupado.png' y '.pdf'")
    
    plt.show()
    
    # Mostrar resumen mejorado
    print("\n" + "="*80)
    print("RESUMEN DE LONGITUDES:")
    print("="*80)
    print(f"Genoma de referencia: {reference_length:,} bp")
    print("-"*80)
    
    # Resumen por pipeline
    for pipeline in pipelines:
        lengths = data[pipeline]
        if lengths and any(l > 0 for l in lengths):
            valid_lengths = [l for l in lengths if l > 0]
            avg_length = sum(valid_lengths) / len(valid_lengths)
            min_length = min(valid_lengths)
            max_length = max(valid_lengths)
            
            print(f"{pipeline.upper()}:")
            print(f"  - Longitud promedio: {avg_length:,.0f} bp")
            print(f"  - Rango: {min_length:,} - {max_length:,} bp")
            print(f"  - Diferencia promedio vs ref: {avg_length - reference_length:+,.0f} bp")
    
    print(f"\nDETALLE POR MUESTRA Y PIPELINE:")
    print("-"*80)
    for sample in samples:
        print(f"\n📊 {sample}:")
        for pipeline in pipelines:
            key = f"{sample}_{pipeline}"
            if key in length_info:
                info = length_info[key]
                status = "✅" if abs(info['percentage'] - 100) < 5 else "⚠️"
                print(f"  {status} {pipeline.ljust(12)}: {info['length']:,} bp "
                      f"({info['percentage']:.2f}%, {info['difference']:+,} bp)")
            else:
                print(f"  ❌ {pipeline.ljust(12)}: No disponible")

if __name__ == "__main__":
    plot_length_comparison()