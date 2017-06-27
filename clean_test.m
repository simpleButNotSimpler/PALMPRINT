%% get the image
[path, name] = uigetfile('D:\person1\*.bmp', 'canny image');
if ~name
    return
end
im = imread(fullfile(name, path));

[row, col] = size(im);
siz = [row, col];

%% datasets
dist_threshold = 6;
error_threshold = 2;
area_threshold = 40;

im = clean_palm(im, dist_threshold, error_threshold, area_threshold);

imwrite(im, 'D:/temp2.bmp');








