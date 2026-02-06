# DARPIC-Dynamic-Artifact-Reduction-via-Pixel-Intensity-Consistency

## Overview
This repository provides the implementation of the artifact reduction algorithm for photoacoustic computed tomography (PACT) described in the paper **"Multi-frame pixel intensity consistency based artifact reduction for photoacoustic computed tomography"**. The algorithm leverages multi-frame pixel intensity consistency to suppress artifacts in PACT images, improving the quality of structural visualization.

## Prerequisites
To run the code successfully, the following software and toolboxes must be installed:

### 1. MATLAB
A compatible version of MATLAB (R2024a or later) is required.

### 2. MATLAB Toolboxes
- **Image Processing Toolbox**: Essential for image filtering, normalization, and visualization functions.
- **Parallel Computing Toolbox**: Optional but recommended for optimizing computational performance in large-scale simulations.

### 3. Third-Party Libraries
- **k-Wave Toolbox**: An open-source acoustics toolbox for time-domain simulation of acoustic wave fields (required for PACT forward modeling and reconstruction).  
  Download from: [http://www.k-wave.org](http://www.k-wave.org)
- **Hessian based Frangi Vesselness Filter**: Used for vessel-like structure enhancement in reconstructed images.  
  Download from MATLAB Central File Exchange: [https://ww2.mathworks.cn/matlabcentral/fileexchange/24409-hessian-based-frangi-vesselness-filter](https://ww2.mathworks.cn/matlabcentral/fileexchange/24409-hessian-based-frangi-vesselness-filter)  

## Installation Steps
1. Install the required MATLAB toolboxes (Image Processing Toolbox and Parallel Computing Toolbox) via the MATLAB Add-On Explorer.
2. Download and install the k-Wave Toolbox following the instructions on the official website.
3. Download the Hessian based Frangi Vesselness Filter from MATLAB Central File Exchange and add it to your MATLAB path.
4. Clone or download this repository to your local machine.

## Usage
1. Ensure all prerequisites are correctly installed and added to the MATLAB path.
2. Navigate to the repository directory in MATLAB.
3. Run the main script: `DARPIC.m` (the script will automatically handle data loading, reconstruction, artifact reduction, and result visualization).

## Theory and Reference
For detailed information about the algorithm's theoretical background, mathematical formulation, and experimental validation, please refer to the original paper:  
**"Multi-frame pixel intensity consistency based artifact reduction for photoacoustic computed tomography"**

## License
This project is licensed under the MIT License.

## Contact
For questions or issues related to the code, please contact the author: Zeyu Ma (969447949@qq.com).
