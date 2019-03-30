%{
Copyright (c) 2015, Tom Mertens
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%}

%
% Implementation of Exposure Fusion
%
% written by Tom Mertens, Hasselt University, August 2007
% e-mail: tom.mertens@gmail.com
%
% This work is described in
%   "Exposure Fusion"
%   Tom Mertens, Jan Kautz and Frank Van Reeth
%   In Proceedings of Pacific Graphics 2007
%
%
% Usage:
%   result = exposure_fusion(I,m);
%   Arguments:
%     'I': represents a stack of N color images (at double
%       precision). Dimensions are (height x width x 3 x N).
%     'm': 3-tuple that controls the per-pixel measures. The elements 
%     control contrast, saturation and well-exposedness, respectively.
%
% Example:
%   'figure; imshow(exposure_fusion(I, [0 0 1]);'
%   This displays the fusion of the images in 'I' using only the well-exposedness
%   measure
%

function R = decolor(I,m)

r = size(I,1);
c = size(I,2);
N = size(I,3);

W = ones(r,c,N);

%compute the measures and combines them into a weight map
contrast_parm = m(1);
sat_parm = m(2);
wexp_parm = m(3);

if (contrast_parm > 0)
    W = W.*saliencyWeightmap(I).^contrast_parm;
end
% W = W./repmat(sum(W,3),[1 1 N]);
if (sat_parm > 0)
    W = W.*saturation(I).^sat_parm;
end
% W = W./repmat(sum(W,3),[1 1 N]);
if (wexp_parm > 0)
    W = W.*well_exposedness(I).^wexp_parm;
end
% W = W./repmat(sum(W,3),[1 1 N]);
%normalize weights: make sure that weights sum to one for each pixel
W = W + 1e-12; %avoids division by zero
W = W./repmat(sum(W,3),[1 1 N]);

% create empty pyramid
pyr = gaussian_pyramid(zeros(r,c));
nlev = length(pyr);

% multiresolution blending
for i = 1:N
    % construct pyramid from each input image
	pyrW = gaussian_pyramid(W(:,:,i));
	pyrI = laplacian_pyramid(I(:,:,i));
    
    % blend
    for l = 1:nlev
%         w = repmat(pyrW{l},[1 1 3]);
        w = repmat(pyrW{l},[1 1,1]);
        pyr{l} = pyr{l} + w.*pyrI{l};
    end
end

% reconstruct
R = reconstruct_laplacian_pyramid(pyr);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ result ] = saliencyWeightmap( im )

im = im2double(im);

% if(size(im,3) > 1)
%     imGray = rgb2gray(im);
% else
%     imGray = im;
% end
N=size(im,3);
for i=1:N
imGray=im(:,:,i);
kernel_1D = (1/16) * [1, 4, 6, 4, 1];
kernel_2D = kron(kernel_1D, kernel_1D');

I_mean = mean(imGray(:));

I_Whc(:,:,i) = conv2(im(:,:,i), kernel_2D, 'same');

% result(:,:,i) = abs(I_Whc(:,:,i) - I_mean);
result(:,:,i) = sqrt((I_Whc(:,:,i) - I_mean).^2);
end

% saturation measure
function C = saturation(I)
N = size(I,3);
C = zeros(size(I,1),size(I,2),N);
for i = 1:N
    % saturation is computed as the standard deviation of the color channels
    R = I(:,:,1);
    G = I(:,:,2);
    B = I(:,:,3);
    mu = (R + G + B)/3;
    s = sqrt(((R - mu).^2 + (G - mu).^2 + (B - mu).^2)/3);
    C(:,:,i)=sqrt((I(:,:,i)-s).^2);
end

% well-exposedness measure
function C = well_exposedness(I)
sig = .2;
N = size(I,3);
C = zeros(size(I,1),size(I,2),N);
for i = 1:N
    C(:,:,i) = exp(-.5*(I(:,:,i) - .5).^2/sig.^2);
end


