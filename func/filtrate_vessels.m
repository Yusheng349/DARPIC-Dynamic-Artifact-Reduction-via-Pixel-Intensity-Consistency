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

function [filtered_pics] = filtrate_vessels(pics, options)
    %   pics
    %   options = struct(...
    %   'FrangiScaleRange', [1, 3],...
    %   'FrangiScaleRatio', 0.5,...
    %   'FrangiBetaOne', 1,...
    %   'FrangiBetaTwo', 3000,...
    %   'verbose', false,...
    %   'BlackWhite', false,...
    %   'Mask', ~);
    Nx = size(pics, 1);
    Ny = size(pics, 2);
    frame_num = size(pics, 3);

    fprintf('Starting parallel computation, total %d image frames...\n', frame_num);
    if isempty(gcp('nocreate'))
        parpool(12);
    end

    filtered_pics = zeros(Nx, Ny, frame_num);
    parfor frame = 1:frame_num
        cur_frm = pics(:, :, frame);
        [img_out, ~, ~] = FrangiFilter2D(cur_frm, options);

        if options.Mask ~= 0
            img_out = AGC(img_out, options.Mask(:,:,frame));
        end
        
        filtered_pics(:,:,frame) = img_out;
    
        fprintf('Image frame %d/%d processed successfully\n', frame, frame_num);
    end
end