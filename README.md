
# Birdcall_Identification
Using sounds to predict the bird species with LSTM-RNN network. An iOS app is also avaliable.

![IMG_5C0FB8EBDDC0-1-w40](https://user-images.githubusercontent.com/58836434/124629011-95e11300-deb3-11eb-9eb3-641ca1323bfe.jpeg)
<img src = "https://user-images.githubusercontent.com/58836434/124629011-95e11300-deb3-11eb-9eb3-641ca1323bfe.jpeg" width = "50px" align = center>

Input: Sound of the birds.
Output: Prediction of the bird species with specific probability.

The Preprocess algorithm will automatically extract 13 dimensional MFCC feature from the sound. Then, those features will be used in the AI model. With LSTM-RNN network, the accuracy of the algorithm is achieve 90% on the test set.
