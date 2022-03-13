import face_recognition
import imutils
import pickle
import time
import cv2
import os

import webcolors

import socket , sys

         
user_name = 'hajar'
ShowFraud = False
Fraud = False
colour = (0, 0, 255)


HOST = 'localhost'
PORT = 9013


mySocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)


try:
    mySocket.bind(('', PORT))
except socket.error:
  print ("La liaison du socket à l'adresse choisie a échoué.")
  sys.exit()
  
 # 3) Attente de la requête de connexion d'un client :
print ("Serveur prêt, en attente de clients ...")
mySocket.listen(5)

 # 4) Etablissement de la connexion :
client, address = mySocket.accept()
print ("connected to ", address )  

import speech_recognition as sr
recognizer = sr.Recognizer()

recognizer.energy_threshold = 300

#import library
import speech_recognition as sr

# Initialize recognizer class (for recognizing the speech)
recognizer = sr.Recognizer()


list_qcm_word = ['question' , 'variable' , 'number', 'science', 'python'] 
# Reading Microphone as source
# listening the speech and store in audio_text variable


#find path of xml file containing haarcascade file 

cascPathface = os.path.dirname(
 cv2.__file__) + "/data/haarcascade_frontalface_alt2.xml"
# load the harcaascade in the cascade classifier

faceCascade = cv2.CascadeClassifier(cascPathface)
# load the known faces and embeddings saved in last file

data = pickle.loads(open('face_enc', "rb").read())

 
print("Streaming started")
video_capture = cv2.VideoCapture(0)
with sr.Microphone() as source :
    print("Start Talking")
# loop over frames from the video file stream
    while True :
        
        reponse = client.recv(1024)
        reponse = reponse.decode()
        if  "Fraud" in reponse  :
            Fraud = True 
        if not reponse :
              print("Le client est deconnecté : cas de faude ")
              Fraud = True
              break
        
        audio_text = recognizer.listen(source)
        print("Text: "+recognizer.recognize_google(audio_text))
        word= recognizer.recognize_google(audio_text)
         
        # reconnaissance vocale 
        if (word in list_qcm_word) :
                    print( word + " is a word not allowed to say during the exam, CHEATING DETECTED" )
                    ShowFraud == True

           

         
        # grab the frame from the threaded video stream
        ret, frame = video_capture.read()
        
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        faces = faceCascade.detectMultiScale(gray,
                                             scaleFactor=1.1,
                                             minNeighbors=5,
                                             minSize=(60, 60),
                                             flags=cv2.CASCADE_SCALE_IMAGE)
     
        # convert the input frame from BGR to RGB 
        rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        # the facial embeddings for face in input
        encodings = face_recognition.face_encodings(rgb)
        names = []
        # loop over the facial embeddings incase
        # we have multiple embeddings for multiple fcaes
        for encoding in encodings:
           #Compare encodings with encodings in data["encodings"]
           #Matches contain array with boolean values and True for the embeddings it matches closely
           #and False for rest
            matches = face_recognition.compare_faces(data["encodings"],
             encoding)
            #set name =inknown if no encoding matches
            name = "Unknown"
            # check to see if we have found a match
            if True in matches:
                #Find positions at which we get True and store them
                matchedIdxs = [i for (i, b) in enumerate(matches) if b]
                counts = {}
                # loop over the matched indexes and maintain a count for
                # each recognized face face
                for i in matchedIdxs:
                    #Check the names at respective indexes we stored in matchedIdxs
                    name = data["names"][i]
                    #increase count for the name we got
                    counts[name] = counts.get(name, 0) + 1
                #set name which has highest count
                name = max(counts, key=counts.get)
     
            names.append(name)
            if (len(names) == 1) and (name == user_name) :
                print('OK')
            else :
                ShowFraud = True
            # update the list of names
            names.append(name)
            
            # loop over the recognized faces
            for ((x, y, w, h), name) in zip(faces, names):
                
                if ShowFraud == True :
                    cv2.rectangle(frame, (x, y), (x + w, y + h), colour, 2 )
                    cv2.putText(frame, name, (x, y), cv2.FONT_HERSHEY_SIMPLEX,
                     0.75, colour, 2)
                    cv2.imwrite('Fraude.jpg', frame)
                    time.sleep(5)
                    #Fraud = True       
                    
                else:
                    # rescale the face coordinates
                    # draw the predicted face name on the image
                    cv2.rectangle(frame, (x, y), (x + w, y + h), (0,255,0), 2)
                    cv2.putText(frame, name, (x, y), cv2.FONT_HERSHEY_SIMPLEX,
                     0.75, (0, 255, 0), 2)
        cv2.imshow("Frame", frame)
        
        if ((cv2.waitKey(1) & 0xFF == ord('q')) or Fraud == True ):
            print("Cas de fraude détecté ")
            break  
        
    #time.sleep(5)    
    video_capture.release()
    cv2.destroyAllWindows()
    cv2.waitKey(1)
    cv2.waitKey(1)
    cv2.waitKey(1)
    cv2.waitKey(1)