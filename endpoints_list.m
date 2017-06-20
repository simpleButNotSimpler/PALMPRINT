function list = endpoints_list(im, threshold)
%get im size
[siz(1), siz(2)] = size(im);

%get endpoints
endpoints = bwmorph(im, 'endpoints');
[x, y] = find(endpoints == 1);
points = [x, y];

%closest points
idx = closestPoints(points, threshold);

%eliminate points which are connected to each other


%filter the idx array
%remove the nan rows
[row, ~] = find(~isnan(idx(:, 2)));
idx = idx(row, :);

%remove the sibling pixels
label_im = bwlabel(im);
index1 = idx(:, 1);
p1 = sub2ind(siz, points(index1, 1), points(index1, 2));
index2 = idx(:, 2);
p2 = sub2ind(siz, points(index2, 1), points(index2, 2));

index = (label_im(p1) ~= label_im(p2));
idx = idx(index ~= 0, :);

%final list
list = [points(idx(:, 1), :), points(idx(:, 2), :)];

%function to compute the corresponding endpoints
function idx = closestPoints(points, threshold)
    row = size(points, 1);
    
    idx = zeros(row, 1);
    for t=1:row
        dist = points - points(t, :);
        dist = sqrt(sum(dist.^2, 2));
        dist(dist == 0) = NaN;
        [val, index] = min(dist);
        
        if val < threshold
            idx(t) = index(1);
        else
            idx(t) = NaN;
        end
    end
    
    k = 1:row;
    idx = [k', idx];
