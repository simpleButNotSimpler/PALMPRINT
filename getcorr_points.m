function [im1_points, im2_points] = getcorr_points(im1, im2)
% Detect SURF features.
points1 = detectSURFFeatures(im1);
points2 = detectSURFFeatures(im2);

% points1 = detectBRISKFeatures(im1);
% points2 = detectBRISKFeatures(im2);

% Extract features.
[f1, vpts1] = extractFeatures(im1, points1);
[f2, vpts2] = extractFeatures(im2, points2);

% Match features.
indexPairs = matchFeatures(f1, f2);
matchedPoints1 = vpts1(indexPairs(:, 1));
matchedPoints2 = vpts2(indexPairs(:, 2));

im1_points = matchedPoints1.Location;
im2_points = matchedPoints2.Location;

end