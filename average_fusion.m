function [ R ] = average_fusion( img,n )
%PCA_FUSION Summary of this function goes here
%   Detailed explanation goes here
no_bands=size(img,3);
for i=1:n
R(:,:,i)= mean(img(:,:,1+floor(no_bands/n)*(i-1):floor(no_bands/n)*i),3);
% if (floor(no_bands/n)*i~=no_bands)&(i==n)%µ±²»¹»µÈ·ÖÊ±£¬Ê£ÏÂµÄËã×÷Ò»Àà¡£¡£
if (i==(n-1))
    R(:,:,i+1)=mean(img(:,:,1+floor(no_bands/n)*i:no_bands),3);
end    
end
