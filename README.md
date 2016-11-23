These are few scripts used in Kaggle competition - https://www.kaggle.com/c/malware-classification

* Approach 1: 
Create features from 500GB of malware data by running generateFeatures.R
Run findNgram.cpp to generate N-gram features out of last output.
Run xgboostTrain.R
python make_submission_malware.py

* Approach 2: Generate Image files corresponding to malware binary using createImages.py for train and test
Generate img list

python gen_img_list.py train /home/sampleSubmission.csv trainImages/ train.lst
python gen_img_list.py test /home/sampleSubmission.csv data/test/ test.lst

* Generate binary image file
First build im2bin at ```../../tools```, then run
```
../../tools/im2bin train.lst ./ train.bin
../../tools/im2bin test.lst ./ test.bin
```

* Run CXXNET
```
mkdir models
../../bin/cxxnet bowl.conf

* Run Prediction
```
../../bin/cxxnet pred.conf
```
It will write softmax result in test.txt

* Make a submission file

python make_submission_malware.py

* Change parameters of training, form an ensemble to get better results.
	      
