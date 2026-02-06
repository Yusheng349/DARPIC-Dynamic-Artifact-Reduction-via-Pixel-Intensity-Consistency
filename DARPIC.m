% Author: Zeyu Ma
% Date: February 2026
% Article: Multi-frame pixel intensity consistency based artifact reduction for photoacoustic computed tomography
% License: MIT License
% 
% Copyright (c) 2026 Zeyu Ma
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.

clc; clear;

%% Load data
% Load RF data
load('data\cplcphantom_RF_part1.mat');
load('data\cplcphantom_RF_part2.mat');
sensor_data = cat(3, sensor_data_part1, sensor_data_part2);

% Element position configuration
Nx = 300; 
Ny = 300;
dx = 0.1e-3; % [m]
dy = 0.1e-3;
R = 40e-3; % [mm]
num_sensors = 256;
mask = makeCartCircle(R, num_sensors);
% Calculate row coordinates with top-left corner as origin (1,1)
X = round(mask(1, :) ./ dx) + ceil(Nx/2) + 1; 
Y = round(mask(2, :) ./ dy) + ceil(Ny/2) + 1;
ElementPos = [(X'-(ceil(Nx/2) + 1)).*dx, (Y'-(ceil(Ny/2) + 1)).*dy, zeros(size(X))'];

%% Multi-frame Reconstruction
PicParam = struct('Nx', 300, 'Ny', 300, 'dx', 0.1e-3, 'dy', 0.1e-3);
RFParam = struct('sound_speed', 1501, 'fs', 25e6, 'time_offset', 0);
das_pics = recons_DAS(sensor_data, ElementPos, PicParam, RFParam); 

clear 'RF_PACT_600frames' 'half_time_step' 'RFParam' 'PicParam'

%% Frangi Filter
mask_all = 0;
positive_das_pics = max(0, das_pics);

% Frangi filter configuration
options = struct(...
      'FrangiScaleRange', [1.5, 3],...
      'FrangiScaleRatio', 0.5,...
      'FrangiBetaOne', 1,...
      'FrangiBetaTwo', 1500,...
      'verbose', false,...
      'BlackWhite', false,...
      'Mask', mask_all);

% Vessel filtration using Frangi filter
[filtered_pics] = filtrate_vessels(positive_das_pics, options);
clear 'options' 'positive_das_pics'

%% Registration
% Normalize filtered images to 0-255 grayscale and set pixels <5 to 0
normalized_pic = rescale(filtered_pics, 0, 255);
filtered_pics = uint8(normalized_pic);
filtered_pics(filtered_pics<=5) = 0;

% Register filtered images
[~, tform, dpm_fld] = regist_filtered_pics(filtered_pics, mask_all);
masked_das_pics = das_pics;
% Apply registration field to DAS images
[registed_pics] = apply_regist_fld(masked_das_pics, tform, dpm_fld);
clear 'masked_das_pics'

%% ASM Calculation
[ASM, ~, ~] = calcu_ASM(registed_pics, 'Polarized', false, 'Plot', true, ...
    'Implement', false, 'PlotComparison', false);

% ASM non-linear transformation
a = 1e5;
nonlinear_trans_ASM = a .^ ASM;
figure; imshow(rescale(nonlinear_trans_ASM));
ASM = rescale(nonlinear_trans_ASM);

%% ASM Deformation
[dynamic_ASM] = inverse_ASM_registration(ASM, dpm_fld, tform);

%% dB colorbar imshow (324th frame)
% Load ground truth for 324th frame (.mat file)
load('data/phantom_multiframes.mat')
GT = phantom_multiframes(:,:,324); 

% Remove artifacts using dynamic ASM
positive_das_pics = max(das_pics,0);
a = positive_das_pics(:,:,324);
arti_rmv_a = a .* dynamic_ASM(:,:,324);

% Visualize original image (324th frame)
das_pic_dB = dB_colorbar(rescale(a));

% Visualize artifact-removed image (324th frame)
artirmv_pic_dB = dB_colorbar(rescale(arti_rmv_a));

% Visualize ground truth (324th frame)
GT_dB = dB_colorbar(rescale(GT));