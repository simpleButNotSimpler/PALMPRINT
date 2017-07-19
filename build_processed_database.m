% %% get the image
% [path, name] = uigetfile('data\raw_database\*.bmp');
% if ~name
%     return
% end
% im1 = imread(fullfile(name, path));
% 
% %% process the image
% if ndims(im1) == 3
%     im1 = rgb2gray(im1);
% end
% 
% imb = im2double(im1);
% 
% %%
% %edge response
% imfirstedge = edgeresponse(imb);
% imsecondedge = edgeresponse(imcomplement(imfirstedge));
% % imsecondedge = edgeresponse(imcomplement(imsecondedge), 'max');
% 
% %canny
% %first edge response
% % tlow = percentile(imfirstedge, 80);
% % thigh = percentile(imfirstedge, 75);
% len = size(imsecondedge, 1);
% X = reshape(imsecondedge, 1, len*len);
% threshold = prctile(X, [90, 60]);
% thigh = threshold(1);
% tlow = threshold(2);
% [imfirstcanny, ~] = cannys(imfirstedge, tlow, thigh);
% 
% %second edge response
% % tlow = percentile(imsecondedge, 95);
% % thigh = percentile(imsecondedge, 35);
% len = size(imsecondedge, 1);
% X = reshape(imsecondedge, 1, len*len);
% threshold = prctile(X, [90, 75]);
% thigh = threshold(1);
% tlow = threshold(2);
% [imsecondcanny, template] = cannys(imsecondedge, tlow, thigh);
% 
% figure;
% % set(gcf, 'PaperOrientation', 'portrait');
% subplot(2, 3, 1), imshow(imb), title('original'); hold on;
% subplot(2, 3, 2), imshow(imfirstedge), title('1st edge response');
% subplot(2, 3, 3), imshow(imsecondedge), title('2ndedge response');
% subplot(2, 3, 4), imshow(template), title('template');
% subplot(2, 3, 5), imshow(imfirstcanny), title('1st e-resp canny');
% subplot(2, 3, 6), imshow(imsecondcanny), title('2nd e-resp canny'); hold off;

%% alternative
files = dir('data\database\raw_database\*.bmp');
len = length(files);
dist_threshold = 6;
error_threshold = 2;
area_threshold = 40;
croc = ['|', '/', '-', '\'];

for t=1:len
    clc, disp(strcat('speed: [', croc(mod(t,3) + 1), ']'))
    im1 = imread(fullfile(files(t).folder, files(t).name));
    
    % process the image
    if ndims(im1) == 3
        im1 = rgb2gray(im1);
    end

    imb = im2double(im1);

    %edge response
    imfirstedge = edgeresponse(imb);
    imsecondedge = edgeresponse(imcomplement(imfirstedge));
    % imsecondedge = edgeresponse(imcomplement(imsecondedge), 'max');

    %canny
    %first edge response
    % tlow = percentile(imfirstedge, 80);
    % thigh = percentile(imfirstedge, 75);
    len = size(imfirstedge, 1);
    X = reshape(imfirstedge, 1, len*len);
    threshold = prctile(X, [80,75]);
    thigh = threshold(1);
    tlow = threshold(2);
    [imfirstcanny, ~] = cannys(imfirstedge, tlow, thigh);

    %second edge response
    % tlow = percentile(imsecondedge, 95);
    % thigh = percentile(imsecondedge, 35);
    len = size(imsecondedge, 1);
    X = reshape(imsecondedge, 1, len*len);
    threshold = prctile(X, [90, 75]);
    thigh = threshold(1);
    tlow = threshold(2);
    [imsecondcanny, ~] = cannys(imsecondedge, tlow, thigh);
    
    %clean the image
    im_cleaned = clean_palm(imsecondcanny, dist_threshold, error_threshold, area_threshold);
    
    %save the files
    imwrite(imsecondedge, fullfile('data\database\edge_response', files(t).name));
    imwrite(imsecondcanny, fullfile('data\database\canny', files(t).name));
    imwrite(im_cleaned, fullfile('data\database\cleaned_stage1', files(t).name));
end
