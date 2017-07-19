%% get the image
[path, name] = uigetfile('data\testimages\cleaned_stage1\*.bmp', 'test');
if ~name
    return
end
test_im = imread(fullfile(name, path));

[path, name] = uigetfile('data\database\cleaned_stage1\*.bmp', 'database');
if ~name
    return
end
dbase_im = imread(fullfile(name, path));

[row, col] = size(dbase_im);
siz = [row, col];

%% get the score of the images
s_ab = matching_score(test_im, dbase_im)
s_ba = matching_score(dbase_im, test_im)

final_score = max(s_ab, s_ba)

