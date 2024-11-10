#%% Média Móvel 
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

def transformar_valor(valor):
    return valor / 1000  # Exemplo de transformação para os valores

def plot_media_movel(file_path, window_size=200):  
    # Ler o arquivo CSV
    df = pd.read_csv(file_path, delimiter=';')

    # Aplicar a transformação aos valores no eixo "Valor"
    df['value_transformed'] = df['value'].apply(transformar_valor)

    # Converter a coluna 'timestamp' para o tipo datetime
    df['timestamp'] = pd.to_datetime(df['timestamp'], unit='s')

    # Calcular o eixo de tempo em minutos, iniciando em 0
    df['tempo'] = (df['timestamp'] - df['timestamp'].min()).dt.total_seconds() / 60000

    # Configuração do estilo do Seaborn
    sns.set(style="whitegrid")
    plt.figure(figsize=(12, 6))

    # Plotar a linha da média móvel usando Seaborn
    plt.plot(df['tempo'].values, df['value_transformed'].rolling(window=window_size).mean().values, label=f'Média Móvel (janela={window_size})', linestyle='--', color='red')

    # Plotar os dados originais transformados em azul
    plt.plot(df['tempo'].values, df['value_transformed'].values, label='Dados Originais Transformados', linestyle='-', color='blue', alpha=0.5)

    # Adicionar rótulos e título
    plt.xlabel('Tempo (minutos)')  # Rótulo do eixo x
    plt.ylabel('Valor (em potência consumida mW)')  # Rótulo do eixo y
    plt.title('Média Móvel')

    # Adicionar legenda
    plt.legend()

    # Exibir o gráfico
    plt.show()

# Chame a função plot_media_movel com o caminho para o arquivo CSV
plot_media_movel('./1experimento.csv')

#%% Média móvel WF

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

def transformar_valor(valor):
    return valor / 1000  # Exemplo de transformação para os valores

def plot_media_movel(file_path, window_size=250):  
    # Ler o arquivo CSV
    df = pd.read_csv(file_path, delimiter=';')

    # Aplicar a transformação aos valores no eixo "Valor"
    df['value_transformed'] = df['value'].apply(transformar_valor)

    # Converter a coluna 'timestamp' para o tipo datetime
    df['timestamp'] = pd.to_datetime(df['timestamp'], unit='s')

    # Calcular o eixo de tempo em minutos, iniciando em 0
    df['tempo'] = (df['timestamp'] - df['timestamp'].min()).dt.total_seconds() / 60000

    # Configuração do estilo do Seaborn
    sns.set(style="whitegrid")
    plt.figure(figsize=(12, 6))

    # Plotar a linha da média móvel usando Seaborn
    plt.plot(df['tempo'].values, df['value_transformed'].rolling(window=window_size).mean().values, label=f'Média Móvel (janela={window_size})', linestyle='--', color='red')

    # Plotar os dados originais transformados em azul
    plt.plot(df['tempo'].values, df['value_transformed'].values, label='Dados Originais Transformados', linestyle='-', color='blue', alpha=0.5)

    # Adicionar rótulos e título
    plt.xlabel('Tempo (minutos)')  # Rótulo do eixo x
    plt.ylabel('Valor (em potência consumida mW)')  # Rótulo do eixo y
    plt.title('Média Móvel - Comunicação WF')

    # Adicionar legenda
    plt.legend()

    # Exibir o gráfico
    plt.show()

# Chame a função plot_media_movel com o caminho para o arquivo CSV

plot_media_movel('1hjogging.csv')

#%%

import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

def transformar_valor(valor):
    return valor / 1000  # Exemplo de transformação para os valores

def plot_media_movel(file_path, window_size=350):  
    # Ler o arquivo CSV
    df = pd.read_csv(file_path, delimiter=';')

    # Aplicar a transformação aos valores no eixo "Valor"
    df['value_transformed'] = df['value'].apply(transformar_valor)

    # Converter a coluna 'timestamp' para o tipo datetime
    df['timestamp'] = pd.to_datetime(df['timestamp'], unit='s')

    # Calcular o eixo de tempo em minutos, iniciando em 0
    df['tempo'] = (df['timestamp'] - df['timestamp'].min()).dt.total_seconds() / 60000

    # Configuração do estilo do Seaborn
    sns.set(style="whitegrid")
    plt.figure(figsize=(12, 6))

    # Plotar apenas a linha da média móvel usando Seaborn
    plt.plot(df['tempo'].values, df['value_transformed'].rolling(window=window_size).mean().values, label=f'Média Móvel (janela={window_size})', linestyle='--', color='red')

    # Adicionar rótulos e título
    plt.xlabel('Tempo (minutos)')  # Rótulo do eixo x
    plt.ylabel('Valor (em potência consumida mW)')  # Rótulo do eixo y
    plt.title('Média Móvel - Comunicação wIfI')

    # Adicionar legenda
    plt.legend()

    # Exibir o gráfico
    plt.show()

# Chame a função plot_media_movel com o caminho para o arquivo CSV
plot_media_movel('./1hsentadoDinamico1.csv')

