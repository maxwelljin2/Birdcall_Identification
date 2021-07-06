import requests
import json
import os
import wget
from pydub import AudioSegment

bird_species =["Dendrocopos major","Alcedo atthis","Picus canus","Cinclus pallasii","Dendrocopos canicapillus","Upupa epops"]
actual_name = ["Great-spotted_woodpecker","kingfisher","Grey-headed_woodpecker","Brown Dipper","Japanese_Pygmy_Woodpecker","Eurasian hoopoe"]


total_num = 0
for z in range(len(bird_species)):
    progress = z/len(bird_species)
    progress *= 100
    print(str(actual_name[z]) + " species begin download now:")
    print(str(progress) + "%")
    query = bird_species[z]
    response = requests.get("https://www.xeno-canto.org/api/2/recordings?query="+query)
    data = response.json()["recordings"]
    data = list(data)
    flexible_len = 50
    if len(data) < 50:
        print("This segment is only 30")
        flexible_len = 30
    if len(data) < 30:
        print(bird_species[z] + " is not downloadable")
        continue
    temp = list(data[0:flexible_len])
    total_num += 1
    print("-----------------------------")
    for i in range(len(temp)):
        print("download: " + str(i) + "/" + str(flexible_len))
        p = temp[i]
        part_url = p["file"]
        a = "https:"
        final_url = a + part_url
        new_r = requests.get(final_url)
        file_name = actual_name[z] + "_" + str(i+1)
        path = "/Users/gene/Documents/"+file_name + ".mp3"
        path_1 = path + "_partA"
        part_2 = path + "_partB"
        with open(path,"wb") as f:
            f.write(new_r.content)
    
    
print(total_num)
