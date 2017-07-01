%% get the images
[path, name] = uigetfile('data\processed_testimages\edge_response\*.bmp', 'edge image');
if ~name
    return
end
im1 = imread(fullfile(name, path));

[path, name] = uigetfile('data\processed_database\edge_response\*.bmp', 'edge image');
if ~name
    return
end
im2 = imread(fullfile(name, path));

%% get the corresponding points using surf
[moving, fixed] = getcorr_points(im1, im2);

%% perform icp
[R, T, regset, angle, er] = icp(moving, fixed, 40, 0.001, 0);

%apply the transformation
[row, col] = find(im1 ~= inf);
points = [col, row];
