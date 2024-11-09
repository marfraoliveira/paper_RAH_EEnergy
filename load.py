import numpy as np
import keras.models
from keras.models import model_from_json
import tensorflow as tf


def init(): 
    json_file = open('modeloCNN.json','r')
    loaded_model_json = json_file.read()
    json_file.close()
    loaded_model = model_from_json(loaded_model_json)
    # load weights into new model
    loaded_model.load_weights('modeloCNN.h5')
    print("Modelo carregado com Sucesso!")

    # compile and evaluate loaded model
    loaded_model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])

    return loaded_model
