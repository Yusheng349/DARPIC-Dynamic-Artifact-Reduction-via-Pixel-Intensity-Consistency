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

function [registed_pics, tform, dpm_fld] = regist_filtered_pics(pics, mask)
frame_num = size(pics, 3);
if mask ~= 0
    pics = pics .* mask;
end

fixed = pics(:,:,1);
fixedRefObj = imref2d(size(fixed));
fprintf('Starting parallel computation of rigid transformation, a total of %d image frames need to be registered...\n', frame_num-1);
if isempty(gcp('nocreate'))
    parpool(12);
end
registed_rigid_pics = zeros(size(pics));
tform = cell(1, frame_num);
parfor i = 2:frame_num
    moving = pics(:,:,i);
    movingRefObj = imref2d(size(moving));

    % Intensity-based registration
    [optimizer, metric] = imregconfig('multimodal');
    metric.NumberOfSpatialSamples = 500;
    metric.NumberOfHistogramBins = 25;
    metric.UseAllPixels = true;
    optimizer.GrowthFactor = 1.050000;
    optimizer.Epsilon = 1.50000e-06;
    optimizer.InitialRadius = 6.25000e-03;
    optimizer.MaximumIterations = 50;

    % Apply Gaussian blur
    fixedInit = imgaussfilt(fixed,1.000000);
    movingInit = imgaussfilt(moving,1.000000);

    % Apply transformation
    tform_cur = imregtform(movingInit, movingRefObj, fixedInit ,fixedRefObj, 'rigid', optimizer, metric, 'PyramidLevels', 3);
    registeredImage = imwarp(moving, movingRefObj, tform_cur, 'OutputView', fixedRefObj, 'SmoothEdges', true);

    registed_rigid_pics(:,:,i) = registeredImage;
    tform{i} = tform_cur;

    fprintf('Rigid transformation: Image frame %d/%d processed successfully\n', i-1, frame_num-1);
end
registed_rigid_pics(:,:,1) = fixed;

registed_pics = zeros(size(pics));
dpm_fld = zeros([size(pics),2]);
dpm_fld = permute(dpm_fld, [1, 2, 4, 3]);
fprintf('Starting parallel computation of non-rigid transformation, a total of %d image frames need to be registered...\n', frame_num-1);
parfor i = 2:frame_num
    moving = registed_rigid_pics(:,:,i); % registed_rigid_pics

    [DisplacementField, RegisteredImage] = imregdemons( ...
        moving, fixed, 150, ...
        'AccumulatedFieldSmoothing',3.0, ...
        'PyramidLevels',3, ...
        'DisplayWaitbar',false);

    registed_pics(:,:,i) = RegisteredImage;
    dpm_fld(:,:,:,i) = DisplacementField;

    fprintf('Non-rigid transformation: Image frame %d/%d processed successfully\n', i-1, frame_num-1);
end
registed_pics(:,:,1) = fixed;

end

