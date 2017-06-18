%assign a computed average intensity value to 
%any pixel that is not in the palmline region
function im_out = clean_image(whitelist, im_in, f_ij, w_ij)
  %get the list of pixel containing the palmlines (whitelist)
%   im_out = double(im_in);
  im_out = im_in;
  w_row = size(whitelist, 1);
  
  %set se element
%   disk = strel('disk',3,0);
%   disk = disk.Neighborhood;
  disk = [1 1 1; 1 1 1; 1 1 1];
  [row, col] = size(disk);

  %set border
  m = round(row/2);
  n = round(col/2);
  
  for t=1:w_row
      idx = whitelist(t);
      [x, y] = ind2sub(size(im_in), idx);
     
      roi_list = R(disk, m, n, x, y);
      roi_list = sub2ind(size(im_in), roi_list(:,1), roi_list(:,2));
      
      im_out(idx) = getAVI(f_ij, w_ij, roi_list);
  end
end

%average intensity
function i_bar = getAVI(f_ij, w_ij, roi_list)
   % sum_xy
   sum_xy = sum(f_ij(roi_list));
   sum_w_ij = sum(w_ij(roi_list));
   
   %average intensity
   i_bar = sum_xy / sum_w_ij;
end

%region of interest
function idx = R(disk, m, n, x, y)
    [row, col] = find(disk == 1);
    pos = [row, col];
    pos = pos - [m, n];
    
    idx = pos + [x, y];
end

