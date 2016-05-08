function [bestH, maxIn] = ransacHomo(xa,ya,xb,yb,ind,N,t,T)

% [bestH, maxIn] = ransacHomo(xa,ya,xb,yb,ind,N,t,T);
% 
% Gives the best homography and the max number of inliers estimated with RANSAC method
% 
% xa,ya,xb,yb       Coordinates of the keypoints in both images a and b
% ind               Index of matched keypoints
% N                 max number of iterations
% t                 max distance from an inlier to its corresponding point
% T                 max number of inlier under which we stop the loop

%% Initialize parameters
k=0; topn = size(xa,1);
maxIn = 0; prevIn = 0; bestH = zeros(3);

%% Run Ransac
while(k<N)
    k=k+1;
    
    %Select 4 random points and their corresponding points
    corr(1:4) = zeros(1,4);
    for i=1:4
        while(corr(i)==0)
            r = randi(topn);
            corr(i) = ind(r);
        end
        Xah(:,i) = [xa(r); ya(r);1];
        Xbh(:,i) = [xb(corr(i)); yb(corr(i));1];
    end

    %Compute a Homography for these points
    H = estimateHomography(Xah, Xbh);

    %Transform the first points with the homography 
    allPtsA = [xa'; ya'; ones(1,topn)];
    allPtsB = [xb'; yb'; ones(1,topn)];
    transA = H*allPtsA;
    
    transA(1,:) = transA(1,:)./transA(3,:);
    transA(2,:) = transA(2,:)./transA(3,:);
    transA(3,:) = [];

    %Compute the distance from the transform points to the goal points
    for i=1:topn
        if(ind(i)~=0)
            dist(i) = sqrt(sum((transA(:,i) - allPtsB(1:2,ind(i))).^2));
        else 
            dist(i) = -1;
        end
    end
    
    %Check the number of inliers
    inlier = (dist<t & dist~=-1);
    nIn = sum(inlier);
    
    %If the consensus is higher than before, update
    if(nIn>prevIn)
        maxIn = nIn;
        bestH = H;
        %If it is above the threshold, output this homography
        if(nIn>=T)
            break;
        end
    end    
    prevIn = nIn;
    
end