%% get the image
[path, name] = uigetfile('D:\person1\p1final*.bmp', 'FIXED dataset');
if ~name
    return
end
fixed_im = imread(fullfile(name, path));

[path, name] = uigetfile('D:\person2\p2final*.bmp', 'MOVING dataset');
if ~name
    return
end
moving_im = imread(fullfile(name, path));


[row, col] = size(moving_im);
siz = [row, col];

%% datasets
[y, x] = find(fixed_im);
fixed = [x, y];

[y, x] = find(moving_im);
moving = [x, y];

[R, T, regset, angle, er] = icp(moving, fixed, 40, 0.001, 1);

% scatter(regset(:, 2), regset(:, 1)); hold on
% scatter(fixed(:, 2), fixed(:, 1), 'filled');


im_out = zeros(row, col);

regset = uint16(round(regset));
regset(regset > row) = row;
regset(regset < 1) = 1;

idx = sub2ind(siz, regset(:, 2), regset(:, 1));
im_out(idx) = 1;

subplot(1, 3, 1), imshow(fixed_im), title('Person 1');
subplot(1, 3, 2), imshow(moving_im), title('Person 2');
subplot(1, 3, 3), imshowpair(fixed_im, im_out), title('Alignment');






