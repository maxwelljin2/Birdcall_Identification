import numpy as np
import json
import tensorflow.keras as keras
import tensorflow as tf
from sklearn.model_selection import train_test_split
dataset = "data.json"
mapping = {0:"aldfly",1:"ameavo",2:"amebit"}
#Load the dataset
def load_data(dataset_path): #dataset_path is a json file
    with open(dataset_path, "r") as hd:
        feature_data = json.load(hd)
    inputs = np.array(feature_data["mfcc"])
    target = np.array(feature_data["labels"])
    return inputs, target

#Split the data
def data_split(test_size, val_size):
    x, y = load_data(dataset)
    #Split the train examples
    x_train, x_test, y_train, y_test = train_test_split(x,y,test_size = test_size)
    
    #Split the validation samples
    x_train, x_val, y_train, y_val = train_test_split(x_train,y_train, test_size = val_size)

    
    return x_train, x_val, x_test, y_train, y_val, y_test

def build(shape):
    #Build CNN
    model = keras.Sequential()

    model.add(keras.layers.LSTM(128, input_shape= shape, return_sequences=True))
    model.add(keras.layers.LSTM(128))

    # dense layer
    model.add(keras.layers.Dense(32, activation='relu'))
    model.add(keras.layers.Dropout(0.2))

    # output layer
    model.add(keras.layers.Dense(3, activation='softmax'))
    
    return model

def predict(x, y, model):
    
    x = x[np.newaxis, ...] #Make the sample number = 1

    #prediction
    prediction = model.predict(x)
    predicted_pos = np.argmax(prediction, axis=1)
    print("Target: {}, Predicted label: {}".format(mapping[y], mapping[predicted_pos[0]]))
    
if __name__ == "__main__":
    x_train, x_val, x_test, y_train, y_val, y_test = data_split(0.2,0.2)
    
    #Build the CNN
    shape = (x_train.shape[1], x_train.shape[2])
    model = build(shape)
    
    optimizer = keras.optimizers.Adam(learning_rate = 0.0001)
    model.compile(optimizer,loss = "sparse_categorical_crossentropy", metrics = ["accuracy"])
    model.summary()
    
    model.fit(x_train,y_train,validation_data = (x_val,y_val),epochs = 50, batch_size = 50)
    x_predict = x_test[5]
    y_predict = y_test[5]
    actual = predict(x_predict,y_predict,model)
    model.save("birdcall_CNN.h5")
