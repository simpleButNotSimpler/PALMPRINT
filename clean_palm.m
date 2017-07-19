function im = clean_palm(im, dist_threshold, error_threshold, area_threshold)
% relevant info
[row, col] = size(im);
im([1:3, row-3:row],:) = 0;

% clean the image
im = clean_canny(im, dist_threshold, error_threshold, area_threshold);

% get the forkpoints lists and remove the forkpoints
[list, ~] = forkpoints(im);

temp_list = list;
while ~isempty(temp_list)
    idx = sub2ind([row, col], list(:, 1), list(:, 2));
    im(idx) = 0; %remove the forkpoints
    
    [temp_list, ~] = forkpoints(im);
    list = [list; temp_list];
end

% clean the image again
im = clean_canny(im, dist_threshold, error_threshold, area_threshold);
im = remove_trunck(im, [], area_threshold);

end

function im = clean_canny(im, dist_threshold, error_threshold, area_threshold)
% remove isolated pics
im = bwmorph(im,'clean');

% get valid endpoints
valid_endpoints = endpoints_list(im, dist_threshold);

% one to one correspondence
valid_endpoints = get_corr_endpoint_list(im, valid_endpoints, error_threshold);

if ~isempty(valid_endpoints)
    % remove the noises
    points = [cat(1, valid_endpoints.head); cat(1, valid_endpoints.corr)];
    im = remove_trunck(im, points, area_threshold);

    % connect the endpoints
    endpoints = [cat(1, valid_endpoints.head), cat(1, valid_endpoints.corr)];
    im = connect_endpoints(im, endpoints); 
end

end

function [list, endfork_list]  = forkpoints(im)
%return the fork points (list) and their corresponding forkends
    [row, col] = find(im == 1);
    
    len = size(row, 1);
    list = [];
    endfork_list = [];
    counter = 1;
    for t=1:len
        [temp_list, isfork] = forkends(im, row(t), col(t));
        
        if isfork
           list = [list; [row(t), col(t)]];
           endfork_list(counter).corr = temp_list;
           counter = counter + 1;
        end
    end
end

%get the forkends
function [list, isfork] = forkends(im, row, col)
    points = [row-1 col-1];
    points = [points; [row-1 col]];
    points = [points; [row-1 col+1]];
    
    points = [points; [row, col+1]];
    points = [points; [row+1, col+1]];
    
    points = [points; [row+1, col]];
    points = [points; [row+1, col-1]];
    
    points = [points; [row, col-1]];
    
    points = [points(end, :); points];
    
    isfork = 0;
    list = [];
    counter = 0;
    for t=2:9
        x = points(t, 1);
        y = points(t, 2);
        
        if im(x, y) && ~im(points(t-1, 1), points(t-1, 2))
            area = im(x-1:x+1, y-1:y+1);
            area = sum(area(:));
            if area > 2
                list = [list; [x, y]];
            end
            
            counter = counter+1;
        end
    end
    
    if counter >= 3
        isfork = 1;
    end
end

function list = endpoints_list(im, threshold)
%list = [row, col, row, col], Nx4 array
%get im size
[siz(1), siz(2)] = size(im);

%get endpoints
endpoints = bwmorph(im, 'endpoints');
[x, y] = find(endpoints == 1);
points = [x, y];

%closest points
list = closestPoints(points, threshold);

%filter the list array
%remove the sibling pixels
label_im = bwlabel(im);
len = numel(list);

tobedeleted = [];
for t=1:len
    head = list(t).head;
    corr = list(t).corr;
    
    head = sub2ind(siz, head(1), head(2));
    corr_idx = sub2ind(siz, corr(:, 1), corr(:, 2));
    
    idx = (label_im(head) ~= label_im(corr_idx));
    
    if any(idx)
        corr = corr(idx, :);
        list(t).corr = corr;
    else
        tobedeleted = [tobedeleted; t];
    end
end

list(tobedeleted) = []; %remove non valid endpoints
end

%function to compute the corresponding endpoints
function list = closestPoints(points, threshold)
    row = size(points, 1);

    list = [];
    counter = 1;
    for t=1:row
        dist = points - points(t, :);
        dist = sqrt(sum(dist.^2, 2));
        
        idx = ((dist < threshold) & (dist ~= 0));
        
        if any(idx)
           list(counter).head = points(t, :);
           list(counter).corr = points(idx, :);
           counter = counter + 1;
        end
    end
end

function valid_endpoints = get_corr_endpoint_list(im, valid_endpoints, error_thresh)
    len = numel(valid_endpoints);
    
    tobedeleted = [];
    for t=1:len
       [corr, error] = get_corr_endpoint(im, valid_endpoints(t).head, valid_endpoints(t).corr, error_thresh);
       
       if ~isempty(corr)
           valid_endpoints(t).corr = corr;
           valid_endpoints(t).error = error;
       else
           tobedeleted = [tobedeleted; t];
       end
    end
    
    valid_endpoints(tobedeleted) = [];
    
    %one to one correspondance
    valid_endpoints = onetoone(valid_endpoints);
end

function valid_endpoints = onetoone(valid_endpoints)
if isempty(valid_endpoints)
   return 
end

points = [cat(1, valid_endpoints.head), cat(1, valid_endpoints.corr)];

tobedeleted = [];
len = size(points, 1);
witness = (1:len)';
real_error = cat(1, valid_endpoints.error);
dummy_error = ones(len, 1)*inf;

for t=1:len
    if isnan(points(t, 1))
        continue
    end
    
    idx = ismember(points(:, 3:4), points(t, 1:2), 'rows');
    if ~any(idx)
        continue
    end
    
    dummy_error = dummy_error*inf;
    
    idx = witness(idx);
    idx = [idx; t];
    dummy_error(idx) = real_error(idx);
    [~, minidx] = min(dummy_error);
    idx = idx(idx ~= minidx);
    
    points(idx, :) = repmat([NaN NaN NaN NaN], numel(idx), 1);
    tobedeleted = [tobedeleted; idx];
end

valid_endpoints(tobedeleted) = [];
end

function [corr_point, error] = get_corr_endpoint(im, head, corresp, error_thresh)
    len = size(corresp, 1);
    head_pixlist = bwtraceboundary(im, head, 'W');
    
    try
        head_pixlist = head_pixlist(1:5, :);
    catch
    end
    
    err = [];    
    for t=1:len
       %get corresp_pixlist
       corresp_pixlist = bwtraceboundary(im, corresp(t,:), 'E');
       
       try
            corresp_pixlist = corresp_pixlist(1:5, :);
       catch
       end
       
       %line points
       pixlist = [head_pixlist; corresp_pixlist];
       
       %linear regression and error
        [~, s1, ~] = polyfit(pixlist(:, 2), pixlist(:, 1), 1);
        [~, s2, ~] = polyfit(pixlist(:, 1), pixlist(:, 2), 1);
        
        %reverse the axis if line is vertical
%         if isnan(s.normr)
%             
%         end

%        delta = s.normr/sqrt(size(pixlist, 1));
       
       err = [err; min(s1.normr, s2.normr)];       
    end
    
    [val, idx] = min(err);
    if val < error_thresh
        corr_point = corresp(idx, :);
        error = val;
    else
        corr_point = [];
        error = inf;
    end
end

function im = remove_trunck(im, endpoints, threshold)
    %connected components
    cc = bwconncomp(im);
    
  
    [row, col] = size(im);
    siz = [row, col];
    
    len = size(cc.PixelIdxList, 2);
    
    %remove the components
    for t=1:len
        [row, col] = ind2sub(siz, cc.PixelIdxList{t});
        cc_points = [row, col];
       if ~contains_endpoint(cc_points, endpoints) && numel(row) < threshold
            im(cc.PixelIdxList{t}) = 0;
       end
    end    
end

function resp = contains_endpoint(pixel_list, endpoints)
    if isempty(endpoints)
        resp = 0;
        return
    end
    [idx, ~] = ismember(pixel_list, endpoints, 'rows');
    resp = sum(idx);
end

function im = connect_endpoints(im, endpoints)
    len = size(endpoints, 1);
    siz = size(im);

    for t=1:len
        y1 = endpoints(t, 1);
        x1 = endpoints(t, 2);
        y2 = endpoints(t, 3);
        x2 = endpoints(t, 4);
        [x, y] = bline(x1, y1, x2, y2);

        idx = sub2ind(siz, y, x); % [x, y] to linear indices

        im(idx) = 1;
    end
end

function [x, y] = bline(x1, y1, x2, y2)

%Matlab optmized version of Bresenham line algorithm. No loops.
%Format:
%               [x y]=bham(x1,y1,x2,y2)
%
%Input:
%               (x1,y1): Start position
%               (x2,y2): End position
%
%Output:
%               x y: the line coordinates from (x1,y1) to (x2,y2)
%
%Usage example:
%               [x y]=bham(1,1, 10,-5);
%               plot(x,y,'or');
x1=round(x1); x2=round(x2);
y1=round(y1); y2=round(y2);
dx = abs(x2-x1);
dy = abs(y2-y1);
steep = abs(dy)>abs(dx);
if steep 
    t = dx; 
    dx = dy;
    dy = t; 
end

%The main algorithm goes here.
if dy==0 
    q = zeros(dx+1,1);
else
    q = [0; diff(mod((floor(dx/2):-dy:-dy*dx+floor(dx/2))', dx)) >= 0];
end

%and ends here.

if steep
    if y1<=y2 
        y=(y1:y2)'; 
    else
        y=(y1:-1:y2)'; 
    end
    
    if x1<=x2 
        x = x1+cumsum(q); 
    else
        x = x1-cumsum(q); 
    end
else
    if x1<=x2 
        x = (x1:x2)'; 
    else
        x = (x1:-1:x2)'; 
    end
    
    if y1<=y2 
        y=y1+cumsum(q);
    else
        y=y1-cumsum(q); 
    end
end

end
