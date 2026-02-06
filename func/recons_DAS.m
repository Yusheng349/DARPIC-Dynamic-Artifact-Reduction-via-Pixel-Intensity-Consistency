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

function [das_pics] = recons_DAS(RF_data, ElementPos, PicParam, RFParam)
    %   RF_data
    %   ElementsPos
    %   PicParam = struct('Nx', , 'Ny', , 'dx', , 'dy', );
    %   RFParam = struct('sound_speed', , 'fs', , 'time_offset', );
    
    if nargin ~= 4
        error('Missing argument(s): The function requires 4 input arguments, but %d were provided.', nargin);
    end
    requiredFields = {'Nx', 'Ny', 'dx', 'dy'};
    for i = 1:length(requiredFields)
        if ~isfield(PicParam, requiredFields{i})
            error('Required field missing in struct parameter: %s', requiredFields{i});
        end
    end
    Nx = PicParam.Nx;
    Ny = PicParam.Ny;
    dx = PicParam.dx;
    dy = PicParam.dy;
    requiredFields = {'sound_speed', 'fs', 'time_offset'};
    for i = 1:length(requiredFields)
        if ~isfield(RFParam, requiredFields{i})
            error('Required field missing in struct parameter: %s', requiredFields{i});
        end
    end
    sound_speed = RFParam.sound_speed;
    fs = RFParam.fs;
    time_offset = RFParam.time_offset;

    % Calculation of required parameters
    frame_num = size(RF_data, 3);
    dt = 1/fs;
    Nt = size(RF_data, 1);
    sensor_num = size(RF_data, 2);
   
    % DAS
    fprintf('Starting parallel computation, total %d image frames...\n', frame_num);
    if isempty(gcp('nocreate'))
        parpool(12);
    end
    das_pics = zeros(Nx, Ny, frame_num);
    parfor frame = 1:frame_num
        RF_cur_frm = RF_data(:, :, frame)';
        das_pic = zeros(Nx, Ny);
        for xx = 1:Nx
            x = -floor(Nx/2) * dx + (xx-1) * dx;
            for yy = 1:Ny
                y = -floor(Ny/2) * dy + (yy-1) * dy;
                for i = 1:sensor_num
                    sensor_x = ElementPos(i, 1);
                    sensor_y = ElementPos(i, 2);
                    sensor_pos = [sensor_x, sensor_y];
        
                    dist = norm([x, y] - sensor_pos);
        
                    instant_full = round(dist / sound_speed / dt) + 1 + time_offset;
                    if instant_full <= 0 || instant_full > Nt
                        continue
                    end
                    das_pic(xx, yy) = das_pic(xx, yy) + RF_cur_frm(i, instant_full);
                end
            end
        end
        das_pics(:,:,frame) = das_pic;
        fprintf('Image frame %d/%d processed successfully\n', frame, frame_num);
    end

end