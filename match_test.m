%% get the image
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

%% Detect SURF features.
points1 = detectSURFFeatures(im1);
points2 = detectSURFFeatures(im2);

% points1 = detectBRISKFeatures(im1);
% points2 = detectBRISKFeatures(im2);

%% Extract features.
[f1, vpts1] = extractFeatures(im1, points1);
[f2, vpts2] = extractFeatures(im2, points2);

%% Match features.
indexPairs = matchFeatures(f1, f2);
matchedPoints1 = vpts1(indexPairs(:, 1));
matchedPoints2 = vpts2(indexPairs(:, 2));

%% Visualize candidate matches.
% figure; ax = axes;
% showMatchedFeatures(im1,im2,matchedPoints1,matchedPoints2,'Parent',ax);
% title(ax, 'Putative point matches');
% legend(ax,'Matched points 1','Matched points 2');

%% Visualize candidate matches.
figure; ax = axes;
showMatchedFeatures(im1,im2,matchedPoints1,matchedPoints2,'montage','Parent',ax);
title(ax, 'Candidate point matches');
legend(ax, 'Matched points 1','Matched points 2');