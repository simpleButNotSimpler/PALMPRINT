%% get the original and the canny image
orig_im = imread('orig1.bmp');
canny_im = imread('canny1.bmp');

%% dilate the image
se = [0 1 0; 1 1 1; 0 1 0];
canny_im = imdilate(canny_im, se);

%%  get the list of pixels containing the palmlines (whitelist) 
whitelist = find(canny_im == 0);
siz = size(orig_im);
left_border = sub2ind(siz, 4, 4);
right_border = sub2ind(siz, siz(1)-4, siz(2)-4);

whitelist = whitelist(whitelist >= left_border & whitelist <= right_border);


%f_ij
f_ij = orig_im;
idx = find(f_ij(canny_im == 0));
f_ij(idx) = 2*f_ij(idx);

%w_if
w_ij = ones(size(orig_im));
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