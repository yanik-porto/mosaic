function descr = gaussDescriptor(im, x, y, sz_patch, sigma)

% descr = gaussDescriptor(im, x, y, sz_patch, sigma);
% 
% Return the gaussian descriptor of keypoints
% 
% im            corresponding image
% x,y           location of the keypoints
% sz_patch      size of the filter patch
% sigma         standard deviation of the gaussian noise

%Initialize parameters
topn = size(x,1); 
rad = (sz_patch-1)/2;

%Build the filter
gaussFilt = fspecial('gaussian',sigma*2,sigma);

%Apply on images
imG = imfilter(im,gaussFilt);

%Output the descriptors in columns
for i=1:topn
       descr(:,i) =  reshape(imG(y(i)-rad:y(i)+rad,x(i)-rad:x(i)+rad)',sz_patch*sz_patch,1); 
end