%% get the original and the canny image
orig_im = imread('orig1.bmp');
canny_im = imread('canny1.bmp');

%% dilate the image
se = [0 1 0; 1 1 1; 0 1 0];
canny_im = imdilate(canny_im, se);

%%  get the list of pixels containing the palmlines (whitelist) 
[sizr, sizc] = size(orig_im);
[row, col] = find(canny_im == 0);
whitelist = [row, col];

whitelist = whitelist(whitelist(:,1) > 4, :);
whitelist = whitelist(whitelist(:,1) < sizr-4, :);

whitelist = whitelist(whitelist(:,2) > 4, :);
whitelist = whitelist(whitelist(:,2) < sizc-4, :);

whitelist = sub2ind([sizr, sizc], whitelist(:,1), whitelist(:,2));

%f_ij
f_ij = orig_im;
idx = find(f_ij(canny_im == 0));
f_ij(idx) = 2*f_ij(idx); %%cchage it heeeeeeeeeeeeeeeeeeeeeeeeeeeeere

%w_if
w_ij = ones(sizr, sizc);
idx = find(w_ij(canny_im == 0));
w_ij(idx) = 2;

%% clean the image
disp('cleaning the image ...')
tic
cleaned_im = clean_image(whitelist, orig_im, f_ij, w_ij);
toc
disp('cleaning done')

%% display the image
imshowpair(orig_im, cleaned_im, 'montage')