clear
clc
close all

addpath(genpath('.\colorspace'));

load('Salinas_corrected.mat')%%      To run this demo, please download the data Salinas_corrected.mat at related website first,
img=salinas_corrected;          %% since the upload file cannot be larger than 20 Megabytes.
img = average_fusion( img,9);
%%
img=Normalization(img);
%%
im1=img(:,:,1:3);
result1=decolor_fusion(im1);%change methods
%%
im2=img(:,:,4:6);
% im2=img(:,:,[2,5,8]);
result2=decolor_fusion(im2);
%%
im3=img(:,:,7:9);
result3=decolor_fusion(im3);
toc;
result(:,:,1)=result1;
result(:,:,2)=result2;
result(:,:,3)=result3;
figure;imshow(result,[])