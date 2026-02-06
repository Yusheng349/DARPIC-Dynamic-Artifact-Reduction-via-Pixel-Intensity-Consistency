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

function [registed_nonrigid_pics] = apply_regist_fld(pics, tform, registed_nonrigid_dpm_fld)
frame_num = size(pics, 3);
fixed = pics(:,:,1);
fixedRefObj = imref2d(size(fixed));

fprintf('Starting parallel computation of rigid transformation, a total of %d image frames need to be registered...\n', frame_num-1);
if isempty(gcp('nocreate'))
    parpool(12);
end
registed_rigid_pics = zeros(size(pics));
parfor i = 2:frame_num
    moving = pics(:,:,i);
    movingRefObj = imref2d(size(moving));
    cur_tform = tform{i};

    registeredImage = imwarp(moving, movingRefObj, cur_tform, 'OutputView', fixedRefObj, 'SmoothEdges', true);

    registed_rigid_pics(:,:,i) = registeredImage;

    fprintf('Rigid transformation: Image frame %d/%d processed successfully\n', i-1, frame_num-1);
end
registed_rigid_pics(:,:,1) = fixed;

registed_nonrigid_pics = zeros(size(pics));
fprintf('Starting parallel computation of non-rigid transformation, a total of %d image frames need to be registered...\n', frame_num-1);
parfor i = 2:frame_num
    cur_D = registed_nonrigid_dpm_fld(:,:,:,i);
    moving = registed_rigid_pics(:,:,i);
    registeredImg = imwarp(moving, cur_D);

    registed_nonrigid_pics(:,:,i) = registeredImg;

    fprintf('Non-rigid transformation: Image frame %d/%d processed successfully\n', i-1, frame_num-1);
end
registed_nonrigid_pics(:,:,1) = fixed;
end

