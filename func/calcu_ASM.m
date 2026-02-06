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

function [ASM, arti_rmv, comparison] = calcu_ASM(variable_3D, varargin)
    %   [ASM, ~, ~] = calu_ASM(registed_das_pics, 'Polarized', false, ...
    % 'Plot', true, 'Implement', false, 'PlotComparison', false);
    p = inputParser;
    addRequired(p, 'variable_3D', @isnumeric);
    addParameter(p, 'Polarized', false, @islogical);
    addParameter(p, 'Plot', false, @islogical);
    addParameter(p, 'Implement', false, @islogical);
    addParameter(p, 'PlotComparison', false, @islogical);

    parse(p, variable_3D, varargin{:});
    polarized = p.Results.Polarized;
    plot = p.Results.Plot;
    implement = p.Results.Implement;
    plot_comparison = p.Results.PlotComparison;

    numerator_ASM = mean(variable_3D, 3).^2;
    denominator_ASM = mean(variable_3D.^2, 3);
    denominator_ASM = max(1e-16, denominator_ASM);
    ASM = numerator_ASM ./ denominator_ASM;

    if polarized
        v_min = min(ASM(:));
        v_max = max(ASM(:));
        mu = (v_max + v_min)/2;
        sigma = (v_max - v_min)/6;
        N_points = 1000;
        v_vec = linspace(v_min, v_max, N_points);
        Phi_vec = normcdf(v_vec, mu, sigma);
        CumPhi = cumtrapz(v_vec, Phi_vec);
        
        d_values = min(ASM, v_max);
        I_matrix = interp1(v_vec, CumPhi, d_values, 'linear', 0);
        I_matrix(ASM  > v_max) = CumPhi(end); 
        
        P = ASM .* I_matrix;
        P_norm = (P - min(P(:))) / (max(P(:)) - min(P(:)));
        ASM = P_norm;
    end
    
    if plot
        figure('Name', 'ASM amplitude');
        imshow(ASM);
    end

    if implement
        variable_3D_contra_enhance = variable_3D; % .^ 0.4
        arti_rmv = variable_3D_contra_enhance .*ASM;
    else
        arti_rmv = [];
    end

    if plot_comparison
        comparison = cat(2, variable_3D_contra_enhance, arti_rmv);
    else
        comparison = [];
    end
end

