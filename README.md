# K-SVD_TSNE_DBSCAN
  The code aims to implement the algorithm proposed in "A Blind Clustering Algorithm for Unknown Radiation Sources with Small Sample Size Based on Sparse Coding of Time-Frequency Spectrum Features Using K-SVD."。

  Due to the tight schedule, the current code is a mix of MATLAB and Python. The next step is to consolidate it into a unified Python code。

I. File Description.

  1. 《Simulation Data Generation Code》
   
  Function: This folder contains six files, namely "BFSK.m", "BPSK.m", "CP.m", "LFM.m", "QFSK.m", and 
            "QPSK.m". These files can generate different simulation signals based on  the set carrier 
            frequency, bandwidth, and signal-to-noise ratio. The signal type corresponds to the file name.
  The platform for running the code：Matlab.

  2. 《Generation_of_Time_frequency_spectrum .m》
   Function: This file implements the filtering and time-frequency analysis of the input signal, and 
             outputs the refined time-frequency map to a specified location after detailed feature 
             processing.
   The platform for running the code：Matlab
  
  3. 《K-SVD_TSNE_DBSCAN .py》
  Function: This file implements the construction of a dictionary using the K-SVD algorithm, calculates the 
            sparse feature vectors of the time-frequency map based on the dictionary, reduces the dimension 
            of the sparse feature vectors using the T-SNE algorithm, and finally performs clustering using 
            the DBSCAN algorithm。
  The platform for running the code：Python
   


II、The execution flow of the code is as follows：

1：If you need to generate simulation data, you can open the code files within the "Simulation Data 
   Generation Code" folder to generate training and testing samples of simulation signals. 
   If you do not need to generate simulation data, you can proceed directly to Step 2.。

2：Open "Generation_of_Time_frequency_spectrum .m", enter the storage path for the input signal samples and 
   the output path for the time-frequency maps.The code first performs adaptive singular value 
   decomposition (SVD) filtering on the input simulation signals and derives the time-frequency maps of the 
   signals using the synchrosqueezed wavelet transform (SSWT).
     
   Then, the code performs detailed processing on the derived time-frequency map features, including: 
   converting the image to grayscale, cropping the image, applying median filtering to the image, and 
   normalizing the aspect ratio of the image.

   Finally, the time-frequency map is output to the specified location.。

3：Open "K-SVD_TSNE_DBSCAN.py", and enter the storage paths for the training and testing samples of the 
   time-frequency maps, as well as the output location for the sparse coding vectors of the time-frequency 
   map features.The code first reads the time-frequency maps from the specified locations, constructs a 
   dictionary using the training data through the K-SVD algorithm, and calculates the sparse feature 
   vectors of the testing data based on the dictionary using the OMP algorithm. These sparse feature  
   vectors are then stored in the designated location.

   Next, the code reads the sparse coding vectors from the specified location and applies the T-SNE 
   algorithm to reduce them to two-dimensional vectors.

   Finally, the code applies the DBSCAN algorithm to the dimension-reduced sparse coding vectors, obtaining 
   the final clustering results。



