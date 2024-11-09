import asyncio
import websockets
import json
import numpy as np
import pandas as pd
import tensorflow as tf
from load import * 
from statistics import mode
import websockets
from statistics import mode
from keras.models import load_model
from sklearn.preprocessing import StandardScaler, LabelEncoder


# Carregar o modelo treinado
model = load_model('modelCNN100Hz.h5')


#model = init()
def converter_para_formato_especifico(dados):
    # Converte os dados para uma string JSON formatada
    dados_formatados = json.dumps({"data": dados}, indent=4)

    # Retorna a string formatada
    return dados_formatados

class WebSocketServer:
    def __init__(self):
        self.connected_clients = set()

    async def receber_dados(self, websocket, path):
        try:
            async for message in websocket:
                data = json.loads(message)

                # ... Lógica da logica de processamento de dados ...
                global classificacoes_list  # Indica que a variável está no escopo global
                if "data" in data:
                # Excluindo o último registro se estiver mal formado
                    if not all(key in data["data"][-1] for key in ["x", "y", "z", "timestamp"]):
                        del data["data"][-1]
		        # Recompondo o JSON
                recomposed_json = json.dumps(data, indent=4)
		        # Convertendo a string JSON para uma lista Python
                lista_python = converter_para_formato_especifico(json.loads(recomposed_json)['data'])
                #print(lista_python)    
# =============================================================================
# 				pré-processamento
# =============================================================================
                parsed_data = json.loads(lista_python)
                data = np.array([[item["x"], item["y"], item["z"]] for item in parsed_data["data"]])
                columns = ['x', 'y', 'z']
                df = pd.DataFrame(data,columns=columns)
                df['x'] = df['x'].astype('float')
                df['y'] = df['y'].astype('float')
                df['z'] = df['z'].astype('float')
                #print(df)
# =============================================================================
                data = df.to_numpy()
                #print(data)
                print(data)
                #scaler = StandardScaler()
                #X = scaler.fit_transform(data)
                #scaled_X = pd.DataFrame(data = X, columns = ['x', 'y', 'z'])
                #scaled_X['label'] = y.values
                #data = scaled_X
                # Convertendo o DataFrame em uma matriz numpy
                #data = data.values
                ## Fim Standardized data
# =============================================================================               
                print(data)
                # Redimensionar os dados para ter a forma correta
                data = data.reshape(data.shape[0], -1)  # Redimensionar para (None, 1500)
                
                # Prever a atividade para cada janela deslizante
                categorias_preditas = []
                tamanho_janela = 80
                for i in range(0, len(data) - tamanho_janela + 1):
                    janela = data[i:i + tamanho_janela]
                    previsao = model.predict(janela[np.newaxis, ...])
                    categoria_predita = np.argmax(previsao)
                    categorias_preditas.append(categoria_predita)
                
                # Mapear as categorias preditas para as atividades
                category_mapping = {
                    0: 'Em pe',
                    1: 'Sentado',
                    2: 'Descer Escadas',
                    3: 'Subir Escadas'
                    
                }
                atividades_preditas = [category_mapping[categoria] for categoria in categorias_preditas]
                

                classificacoes = mode(atividades_preditas)
                resposta = {'Resultado da predicao: ':str(classificacoes)}
                #resposta = {'status': 'success', 'message': 'Dados recebidos com sucesso!', 'Resultado da predicao: ':str(classificacoes)}
                await websocket.send(json.dumps(resposta))
        except websockets.exceptions.ConnectionClosedOK:
            pass
        finally:
            # Remove o cliente da lista de clientes conectados quando a conexão é encerrada
            self.connected_clients.remove(websocket)

    async def handler(self, websocket, path):
        # Adiciona o cliente à lista de clientes conectados
        self.connected_clients.add(websocket)

        # Chama a função específica para tratar os dados
        await self.receber_dados(websocket, path)

    async def main(self):
        # Criação do servidor WebSocket
        server = await websockets.serve(
            self.handler,
            "127.0.0.1",
            8080,
            ping_timeout=120  # Ajuste o tempo limite de ping conforme necessário (em segundos)
 
        )

        print("Servidor WebSocket iniciado")

        # Mantém o loop de eventos rodando indefinidamente
        try:
            while True:
                await asyncio.sleep(3)  # Pausa 
        except asyncio.CancelledError:
            pass
        finally:
            server.close()
            await server.wait_closed()

if __name__ == "__main__":
    ws_server = WebSocketServer()
    asyncio.run(ws_server.main())

