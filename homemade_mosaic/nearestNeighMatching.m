function ind = nearestNeighMatching(descra, descrb, topn, method, thresh)

% ind = nearestNeighMatching(descra, descrb, topn, method, thresh);
% 
% Function giving the index of the corresponding matched features
% 
% descra, descrb        keypoints descriptors of the two images a and b
% topn                  numbers of keypoints
% method                'loweRatio' for eliminating matches with too close
%                       second neighbor match
% thresh                threshold under which we eliminate the match point

%Compute min distance
for i=1:topn
    for j=1:topn
        dist(j,i)=sqrt(sum((descra(:,i) - descrb(:,j)).^2));
    end
end

%Get nearest neighbor with euclidean distance
[M, ind] = min(dist,[],1);

if(strcmp(method,'loweRatio'))
    %Get second nearest neighbot by removing the previous one from the list
    dist2=dist;
    for i=1:topn
        dist2(ind(i),i)=inf;
    end
    [M,ind2] = min(dist2,[],1);

    %Compute the D.Lowe ratio and apply a threshold
    for i=1:topn
        if((dist(ind(i),i)/dist(ind2(i),i))>thresh)
            ind(1,i)=0;
        end
    end
end