%% get the original and the canny image
[path, name] = uigetfile('D:\imlab\*.bmp');
if ~name
    return
end
orig_im = imread(fullfile(name, path));

[path, name] = uigetfile('D:\imlab\*.bmp');
if ~name
    return
end
canny_im = imread(fullfile(name, path));

%% dilate the image
se = [0 1 0; 1 1 1; 0 1 0];
canny_im = imdilate(canny_im, se);

%%  get the list of pixels containing the palmlines (whitelist) 
[sizr, sizc] = size(orig_im);
[row, col] = find(canny_im == 0);
whitelist = [row, col];

whitelist = whitelist(whitelist(:,1) > 3, :);
whitelist = whitelist(whitelist(:,1) < sizr-3, :);

whitelist = whitelist(whitelist(:,2) > 3, :);
whitelist = whitelist(whitelist(:,2) < sizc-3, :);

whitelist = sub2ind([sizr, sizc], whitelist(:,1), whitelist(:,2));


%w_if
w_ij = uint8(ones(sizr, sizc));
w_ij(canny_im == 0) = 2;

%f_ij
f_ij = uint16(orig_im);
f_ij = f_ij .* uint16(w_ij);

%% clean the image
disp('cleaning the image ...')
tic
cleaned_im = clean_image(whitelist, orig_im, f_ij, w_ij);
toc
disp('cleaning done')

%% display the image
imshowpair(orig_im, cleaned_im, 'montage')