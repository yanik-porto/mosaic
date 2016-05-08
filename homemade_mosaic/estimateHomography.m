function H = estimateHomography(X,x)

% H = estimateHomography(X,x);
% 
% Return the homography from given corresponding points
% 
% X         homogeneous coordinates of the points we want to transform
% x         homogeneous coordinates of the reference points

j=1;
for i=1:size(x,2)
    A(j:j+1,:) = [-X(:,i)' zeros(1,3) x(1,i).*X(:,i)';
        zeros(1,3) -X(:,i)' x(2,i).*X(:,i)'];
    j=j+2;
end
[U,S,V] = svd(A);
P = V(:,end);
H = reshape(P,3,3)';