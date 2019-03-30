function [ result ] = HK( im )
% H ? K Chromatic Adapted Lightness
im= colorspace(['LCH','<-RGB'],im);
a=2.5-0.025.*im(:,:,1);
b=0.0116.*abs(sin((im(:,:,3)-90)./2))+0.085;
result=im(:,:,1)+a.*b.*im(:,:,2);

end

