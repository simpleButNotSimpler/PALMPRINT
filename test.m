%% get the image
[name, path] = uigetfile('D:\imlab\*.*');
im = imread(fullfile(path, name));

[row, col] = size(im);
siz = [row, col];

%% get the endpoint lists
threshold = 6;
endpoints = endpoints_list(im, threshold);


%% display im and endpoints
points = [endpoints(:, 1:2); endpoints(:, 3:4)];
figure, imshow(im); hold on
plot(points(:, 2), points(:, 1), '*')

%% connect line truncks
len = size(endpoints, 1);
im_cl = im;

for t=1:len
    y1 = endpoints(t, 1);
    x1 = endpoints(t, 2);
    y2 = endpoints(t, 3);
    x2 = endpoints(t, 4);
    [x, y] = bline(x1, y1, x2, y2);
    
    idx = sub2ind(siz, y, x); % [x, y] to linear indices
    
    im_cl(idx) = 1;
end

%% display fixed image
figure, imshow(im_cl); hold on

%% get the endpoint lists
threshold = 6;
endpoints = endpoints_list(im_cl, threshold);

%% display im and endpoints
points = [endpoints(:, 1:2); endpoints(:, 3:4)];
figure, imshow(im_cl); hold on
plot(points(:, 2), points(:, 1), '*')

%% remove the noises
thresh = 40;
im_cl = remove_trunck(im_cl, points, thresh);

%% display cleaned image
figure, imshow(im_cl); hold on

