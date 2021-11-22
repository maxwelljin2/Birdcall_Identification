import json
import os
import math
import librosa

DATASET_PATH = "/Users/gene/Desktop/Train_copy"
JSON_PATH = "/Users/gene/Desktop/data_10.json"
SAMPLE_RATE = 44100
TRACK_DURATION = 20 # measured in seconds
SAMPLES_PER_TRACK = SAMPLE_RATE * TRACK_DURATION


def save_mfcc(dataset_path, json_path, num_mfcc=13, n_fft=1024, hop_length=512, num_segments=5):
    # mapping, labels, and MFCCs in the dictionary
    data = {
        "mapping": [],
        "labels": [],
        "mfcc": []
    }
    
    samples_per_segment = int(SAMPLES_PER_TRACK / num_segments)
    num_mfcc_vectors_per_segment = math.ceil(samples_per_segment / hop_length)

    for i, (dirpath, dirnames, filenames) in enumerate(os.walk(dataset_path)):
        # ensure we're processing a genre sub-folder level
        if dirpath is not dataset_path:
            
            # mapping the labels to the bird species
            semantic_label = dirpath.split("/")[-1]
            data["mapping"].append(semantic_label)
            print("\nProcessing: {}".format(semantic_label))
	
            for f in filenames:
		# load audio file
                file_path = os.path.join(dirpath, f)
                signal, sample_rate = librosa.load(file_path, sr=SAMPLE_RATE)

                # process all segments of audio file
                for index in range(num_segments):

                    # split the index from the start to the end (as the following formulas)
                    start = samples_per_segment * index
                    finish = start + samples_per_segment

                    # extract mfcc features
                    mfcc = librosa.feature.mfcc(signal[start:finish], sample_rate, n_mfcc=num_mfcc, n_fft=n_fft, hop_length=hop_length)
                    mfcc = mfcc.T

                    if len(mfcc) == num_mfcc_vectors_per_segment:
                        data["mfcc"].append(mfcc.tolist())
                        data["labels"].append(i-1)
			#Storing into json files
                        print("{}, segment:{}".format(file_path, d+1))
			

    # save features in the json file
    with open(json_path, "w") as fp:
        json.dump(data, fp, indent=4)
        
        
if __name__ == "__main__":
    save_mfcc(DATASET_PATH, JSON_PATH, num_segments=10)
