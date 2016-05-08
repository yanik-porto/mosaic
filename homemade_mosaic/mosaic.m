
% YOU HAVE TO FILL THE GAPS !!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; close all; clc;


% Read images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
imargb = double(imread('keble_a.jpg'))/255;
imbrgb = double(imread('keble_b.jpg'))/255;
imcrgb = double(imread('keble_c.jpg'))/255;

% create grayscale version of each image 
% used for detecting and describing local features
ima = rgb2gray(imargb);
imb = rgb2gray(imbrgb);
imc = rgb2gray(imcrgb);

% show images
figure(1); clf;
subplot(1,3,1); imagesc(imargb); axis image; axis off; title('Image a');
subplot(1,3,2); imagesc(imbrgb); axis image; axis off; title('Image b');
subplot(1,3,3); imagesc(imcrgb); axis image; axis off; title('Image c');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Detect Harris points 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
topn = 200; % how many Harris corners points?
[xa,ya,strengtha] = harris(ima,topn);
[xb,yb,strengthb] = harris(imb,topn);
[xc,yc,strengthc] = harris(imc,topn);

% show detected points
figure(2); clf; 
subplot(131),
imagesc(imargb); axis image; axis off; title('Image a');
hold on; plot(xa,ya,'+y');

% show all points
subplot(132),
imagesc(imbrgb); axis image; axis off; title('Image b');
hold on; plot(xb,yb,'+y');

% show all points
subplot(133),
imagesc(imcrgb); axis image; axis off; title('Image c');
hold on; plot(xc,yc,'+y');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract descriptors (heavily blurred 21x21 patches)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
descra = gaussDescriptor(ima, xa, ya, 21, 3);
descrb = gaussDescriptor(imb, xb, yb, 21, 3);
descrc = gaussDescriptor(imc, xc, yc, 21, 3);


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute tentative matches between image 1 (a) and 2 (b) 
% by matching local features
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ind = nearestNeighMatching(descra, descrb, topn, 'loweRatio', 0.8);

%Concatenate the images to display the result
ra = size(ima,1); ca = size(ima,2);
rb = size(imb,1); cb = size(imb,2);
matchImg = cat(2,ima,imb);
figure(3); imshow(matchImg);
hold on;
for i=1:topn
    if(ind(1,i)~=0)
        plot([xa(i) xb(ind(1,i))+ca],[ya(i) yb(ind(1,i))],'x-r');
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Robustly fit homography
%%%%%%%%%%%%%%%%%%%%%%%%%%%
[bestH, maxIn] = ransacHomo(xa,ya,xb,yb,ind,100,2,50);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Warp and composite images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bbox = [-400 1200 -200 700];

Z = vgg_warp_H(imbrgb, eye(3), 'linear', bbox);

% warp image 1 (a) and image 2 (b)
% use function vgg_warp_H.m
newI = vgg_warp_H(imargb, bestH, 'linear', bbox);
figure;
subplot(131),imshow(newI), title('transformed left image');
subplot(132),imshow(Z), title('transformed middle image');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Estimate homography between images 3 and 2.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Based on the code above, write code to:
% 1. Compute tentative matches between images 2 and 3 
% 2. Robustly fit homography Hcb
% 3. Re-estimate homography from inliers

ind2 = nearestNeighMatching(descrc, descrb, topn, 'loweRatio', 0.8);
[bestH2, maxIn2] = ransacHomo(xc,yc,xb,yb,ind2,100,2,50);
newI2 = vgg_warp_H(imcrgb, bestH2, 'linear', bbox);
subplot(133),imshow(newI2), title('transformed right image');


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Final warping and compositing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
finalMosaicLeft = max(newI,Z);
finalMosaic = max(newI2, finalMosaicLeft);
figure;
imagesc(finalMosaic);

