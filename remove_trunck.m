function im = remove_trunck(im, endpoints, threshold)
    %connected components
    cc = bwconncomp(im);
    
  
    [row, col] = size(im);
    siz = [row, col];
    
    len = size(cc.PixelIdxList, 2);
    
    %remove the components
    for t=1:len
        [row, col] = ind2sub(siz, cc.PixelIdxList{t});
        cc_points = [row, col];
       if ~contains_endpoint(cc_points, endpoints) && numel(row) < threshold
            im(cc.PixelIdxList{t}) = 0;
       end
    end    
end

function resp = contains_endpoint(pixel_list, endpoints)
    [idx, ~] = ismember(pixel_list, endpoints, 'rows');
    resp = sum(idx);
end