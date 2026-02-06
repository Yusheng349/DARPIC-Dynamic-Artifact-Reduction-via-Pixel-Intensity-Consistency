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

function [inverse_ASM_pics_final] = inverse_ASM_registration(ASM, dpm_fld, tform)
frame_num = size(tform,2);
if ndims(ASM) == 2
    ASM = repmat(ASM, 1, 1, frame_num);
end
% non-rigid registration
fprintf('Starting parallel computation of non-rigid transformation, a total of %d image frames need to be registered...\n', frame_num-1);
if isempty(gcp('nocreate'))
    parpool(12);
end
inverse_ASM_pics = zeros(horzcat(size(ASM, [1, 2]), frame_num));

parfor i = 2:frame_num
    moving = ASM(:,:,i);
    cur_D = dpm_fld(:,:,:,i);
    registeredImg = imwarp(moving, -cur_D);

    inverse_ASM_pics(:,:,i) = registeredImg;

    fprintf('Non-rigid transformation: Image frame %d/%d processed successfully\n', i-1, frame_num-1);
end
inverse_ASM_pics(:,:,1) = ASM(:,:,1);

% rigid registration
fprintf('Starting parallel computation of rigid transformation, a total of %d image frames need to be registered...\n', frame_num-1);
inverse_ASM_pics_final = zeros(horzcat(size(ASM, [1, 2]), frame_num));
imageSize = size(inverse_ASM_pics(:,:,1));
parfor i = 2:frame_num
    cur_tform = tform{i};
    inverseTform = invert(cur_tform);
    fixedImg = inverse_ASM_pics(:,:,i);
    inverseRegistered = imwarp(fixedImg, inverseTform, 'OutputView', imref2d(imageSize));

    inverse_ASM_pics_final(:,:,i) = inverseRegistered;

    fprintf('Rigid transformation: Image frame %d/%d processed successfully\n', i-1, frame_num-1);
end
inverse_ASM_pics_final(:,:,1) = inverse_ASM_pics(:,:,1);
end

