function [ R ] = decolor_fusion( img )
% im=double(im);
hk= HK( img );
img(:,:,4)=hk;
img=Normalization(img);
R=decolor(img,[1 1 1]);


end

