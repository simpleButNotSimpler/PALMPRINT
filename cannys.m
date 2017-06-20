function [image, E] = cannys(im, tl, th)
    %blur the image
%     imblur = imgaussfilt(im);
    
    %apply sobel on x and y direction
    [imx, imy] = imgradientxy(im);
%     [immag, ~] = imgradient(imx, imy);
    
%     % Normalize for threshold selection
%     magmax = max(immag(:));
%     if magmax > 0
%         immag = immag / magmax;
%     end

    % Normalize for threshold selection
    immax = max(im(:));
    if immax > 0
        im = im / immax;
    end
    
%     immag = imcomplement(immag);
       
    %non-maximum supression
    [image, E] = thinAndThreshold(imx, imy, im, tl, th);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Local Function : thinAndThreshold
%
function [H, E] = thinAndThreshold(dx, dy, magGrad, lowThresh, highThresh)
% Perform Non-Maximum Suppression Thining and Hysteresis Thresholding of
% Edge Strength
    
% We will accrue indices which specify ON pixels in strong edgemap
% The array e will become the weak edge map.

E = cannyFindLocalMaxima(dx,dy,magGrad,lowThresh);

if ~isempty(E)
    [rstrong, cstrong] = find(magGrad>highThresh & E);
    
    if ~isempty(rstrong) % result is all zeros if idxStrong is empty
        H = bwselect(E, cstrong, rstrong, 8);
    else
        H = false(size(E));
    end
else
    H = false(size(E));
end
end