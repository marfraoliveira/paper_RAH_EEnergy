import pandas as pd
import locale
import scipy.stats as stats
file_path = ('./1hestatico.csv')

def calcular_metricas(file_path):
    # Definir a localidade para usar ponto como separador de milhares
    locale.setlocale(locale.LC_NUMERIC, 'en_US.UTF-8')

    # Carregando os dados do arquivo CSV
    df = pd.read_csv(file_path, delimiter=';')

    # Selecionando apenas a coluna 'value'
    values = df['value']

    # Média
    media = round(values.mean(), 4)

    # Intervalo de Confiança para a Média (95%)
    confianca = 0.95
    tamanho_amostra = len(values)
    desvio_padrao_amostra = values.std()

    intervalo_confianca = stats.t.interval(confianca, tamanho_amostra - 1, loc=media, scale=desvio_padrao_amostra / (tamanho_amostra**0.5))

    # Mediana
    mediana = round(values.median(), 4)

    # Desvio Padrão
    desvio_padrao = round(values.std(), 4)

    # Variância
    variancia = round(values.var(), 4)

    # Mínimo
    valor_minimo = round(values.min(), 4)

    # Máximo
    valor_maximo = max(values)  # Usando max() para obter o valor máximo original
    valor_maximo_formatado = '{:,.0f}'.format(valor_maximo)  # Formatação específica

    # Imprimir as métricas com formatação personalizada
    print(f'Média de consumo em potência: {media:,.0f} (Intervalo de Confiança 95%: {intervalo_confianca[0]:,.0f} - {intervalo_confianca[1]:,.0f})')
    print(f'Mediana: {mediana:,.0f}')
    print(f'Desvio Padrão: {desvio_padrao:,.0f}')
    print(f'Variância: {variancia:,.0f}')
    print(f'Mínimo de potência consumida: {valor_minimo:,.0f}')
    print(f'Máximo de potência consumida: {valor_maximo_formatado}')

# Exemplo de uso
calcular_metricas('./2experimento.csv')

#%%
import pandas as pd
import locale

def calcular_metricas(file_path):
    # Definir a localidade para usar ponto como separador de milhares
    locale.setlocale(locale.LC_NUMERIC, 'en_US.UTF-8')

    # Carregando os dados do arquivo CSV
    df = pd.read_csv(file_path, delimiter=';')

    # Selecionando apenas as colunas 'value' (potência) e 'timestamp' (tempo)
    values = df['value']
    timestamps = df['timestamp']

    # Calcular o tempo total em segundos
    tempo_total_segundos = (timestamps.max() - timestamps.min()).total_seconds()

    # Média
    media = round(values.mean(), 4)

    # Mediana
    mediana = round(values.median(), 4)

    # Desvio Padrão
    desvio_padrao = round(values.std(), 4)

    # Variância
    variancia = round(values.var(), 4)

    # Mínimo
    valor_minimo = round(values.min(), 4)

    # Máximo
    valor_maximo = max(values)  # Usando max() para obter o valor máximo original
    valor_maximo_formatado = '{:,.0f}'.format(valor_maximo)  # Formatação específica

    # Calcular a energia total em Joules
    energia_total_joules = (values * (timestamps - timestamps.shift()).dt.total_seconds()).sum()

    # Imprimir as métricas com formatação personalizada
    print(f'Média: {media:,.4f}')
    print(f'Mediana: {mediana:,.4f}')
    print(f'Desvio Padrão: {desvio_padrao:,.4f}')
    print(f'Variância: {variancia:,.4f}')
    print(f'Valor Mínimo: {valor_minimo:,.4f}')
    print(f'Valor Máximo: {valor_maximo_formatado}')
    print(f'Energia Total (Joules): {energia_total_joules:,.2f}')

# Exemplo de uso

calcular_metricas('./resultados4G0511.csv')



#%%
import pandas as pd
import locale

def calcular_metricas(file_path):
    # Definir a localidade para usar ponto como separador de milhares
    locale.setlocale(locale.LC_NUMERIC, 'en_US.UTF-8')

    # Carregando os dados do arquivo CSV e convertendo a coluna 'timestamp' para datetime
    df = pd.read_csv(file_path, delimiter=';', parse_dates=['timestamp'], dayfirst=True)

    # Ordenando o DataFrame pelo timestamp, caso não esteja ordenado
    df = df.sort_values(by='timestamp')

    # Selecionando apenas as colunas 'value' (potência) e 'timestamp' (tempo)
    values = df['value']
    timestamps = df['timestamp']

    # Convertendo a coluna 'timestamp' para um tipo de dados numérico em segundos
    timestamps_numeric = (timestamps - timestamps.min()).dt.total_seconds()

    # Calcular o tempo total em segundos
    tempo_total_segundos = timestamps_numeric.max() - timestamps_numeric.min()

    # Média
    media = round(values.mean(), 4)

    # Mediana
    mediana = round(values.median(), 4)

    # Desvio Padrão
    desvio_padrao = round(values.std(), 4)

    # Variância
    variancia = round(values.var(), 4)

    # Mínimo
    valor_minimo = round(values.min(), 4)

    # Máximo
    valor_maximo = max(values)  # Usando max() para obter o valor máximo original
    valor_maximo_formatado = '{:,.0f}'.format(valor_maximo)  # Formatação específica

    # Calcular a energia total em Joules
    energia_total_joules = (values * (timestamps_numeric - timestamps_numeric.shift(1))).sum()

    # Imprimir as métricas com formatação personalizada
    print(f'Média: {media:,.4f}')
    print(f'Mediana: {mediana:,.4f}')
    print(f'Desvio Padrão: {desvio_padrao:,.4f}')
    print(f'Variância: {variancia:,.4f}')
    print(f'Valor Mínimo: {valor_minimo:,.4f}')
    print(f'Valor Máximo: {valor_maximo_formatado}')
    print(f'Energia Total (Joules): {energia_total_joules:,.2f}')
    print(f'Tempo Total (Segundos): {tempo_total_segundos:,.2f}')

# Exemplo de uso

# Exemplo de uso
calcular_metricas('resultados_4G_1510.csv')
#%%

# Exemplo de uso
calcular_metricas('resultados_4G_1510.csv')
#%%
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

def calcular_metricas_e_plotar_grafico(file_path):
    # Carregando os dados do arquivo CSV
    df = pd.read_csv(file_path, delimiter=';')

    # Selecionando apenas a coluna 'value'
    values = df['value']

    # Média
    media = values.mean()

    # Mediana
    mediana = values.median()

    # Desvio Padrão
    desvio_padrao = values.std()

    # Variância
    variancia = values.var()

    # Mínimo
    valor_minimo = values.min()

    # Máximo
    valor_maximo = values.max()

    # Imprimir as métricas
    print(f'Média: {media:.2f}')
    print(f'Mediana: {mediana:.2f}')
    print(f'Desvio Padrão: {desvio_padrao:.2f}')
    print(f'Variância: {variancia:.2f}')
    print(f'Valor Mínimo: {valor_minimo:.2f}')
    print(f'Valor Máximo: {valor_maximo:.2f}')

    # Plotar um gráfico de linha
    plt.figure(figsize=(10, 6))
    timestamp = df['timestamp'].values
    value = values.values
    plt.plot(timestamp, value, label='Value', marker='o', linestyle='-')
    plt.xlabel('Timestamp')
    plt.ylabel('Value')
    plt.title('Gráfico de Valor em Função do Timestamp')
    plt.legend()
    plt.grid()
    plt.show()

# Substitua 'seuarquivo.csv' pelo caminho real do seu arquivo CSV
calcular_metricas_e_plotar_grafico('resultados_WF_1510.csv')
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

def calcular_ema_e_plotar_grafico(file_path, alpha=0.2):
    # Carregando os dados do arquivo CSV
    df = pd.read_csv(file_path, delimiter=';')

    # Selecionando a coluna 'value' e 'timestamp' como listas
    values = df['value'].tolist()
    timestamp = df['timestamp'].tolist()

    # Calculando a Média Móvel Exponencial (EMA)
    ema = [values[0]]
    for i in range(1, len(values)):
        ema.append(alpha * values[i] + (1 - alpha) * ema[i - 1])

    # Plotar um gráfico de linha
    plt.figure(figsize=(10, 6))
    plt.plot(timestamp, values, label='Value', marker='o', linestyle='-', alpha=0.5)
    plt.plot(timestamp, ema, label=f'EMA ({alpha})', linestyle='-', color='red')
    plt.xlabel('Timestamp')
    plt.ylabel('Value')
    plt.title('Gráfico de Valor com Média Móvel Exponencial')
    plt.legend()
    plt.grid()
    plt.show()

# Substitua 'seuarquivo.csv' pelo caminho real do seu arquivo CSV
# O parâmetro 'alpha' controla o peso dado aos dados mais recentes na EMA (0 < alpha < 1)
calcular_ema_e_plotar_grafico('resultados_4G_1510.csv', alpha=0.2)








import pandas as pd
from sklearn.preprocessing import MinMaxScaler

def calcular_metricas(file_path):
    # Carregando os dados do arquivo CSV
    df = pd.read_csv(file_path, delimiter=';')

    # Selecionando apenas a coluna 'value'
    values = df['value']

    # Calculando as métricas
    media = values.mean()
    mediana = values.median()
    desvio_padrao = values.std()
    variancia = values.var()
    valor_minimo = values.min()
    valor_maximo = values.max()

    # Armazenando as métricas em um DataFrame
    metrics_df = pd.DataFrame({
        'Média': [media],
        'Mediana': [mediana],
        'Desvio Padrão': [desvio_padrao],
        'Variância': [variancia],
        'Valor Mínimo': [valor_minimo],
        'Valor Máximo': [valor_maximo]
    })

    # Normalizando as métricas entre 0 e 1
    scaler = MinMaxScaler()
    metrics_normalized = pd.DataFrame(scaler.fit_transform(metrics_df), columns=metrics_df.columns)

    # Imprimir as métricas normalizadas
    print("Métricas normalizadas:")
    print(metrics_normalized)

# Substitua 'seuarquivo.csv' pelo caminho real do seu arquivo CSV
calcular_metricas('resultados_4G_1510.csv')
