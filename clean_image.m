%assign a computed average intensity value to 
%any pixel that is not in the palmline region
function im_out = clean_image(whitelist, im_in, f_ij, w_ij)
  %get the list of pixel containing the palmlines (whitelist)
  im_out = im_in;
  w_row = size(whitelist, 1);
  
  %set se element
  disk = strel('disk',3,0);
  disk = disk.Neighborhood;
  [row, col] = size(disk);

  %set border
  m = floor(row/2);
  n = floor(col/2);
  
  for t=1:w_row
      idx = whitelist(t);
      [x, y] = ind2sub(size(im_in), idx);
     
      im_out(idx) = getAVI(im_out, f_ij, w_ij, disk, m, n, x, y);
  end
end

%average intensity
function i_bar = getAVI(im, f_ij, w_ij, disk, m, n, x, y)
   roi_list = R(im, disk, m, n, x, y);
   
   % sum_xy
   sum_xy = sum(f_ij(roi_list));
   sum_w_ij = sum(w_ij(roi_list));
   
   %average intensity
   i_bar = sum_xy / sum_w_ij;
end

%region of interest
function idx = R(im, disk, m, n, x, y)
    row_min = x - m;
    row_max = x + m;
    col_min = y - n;
    col_max = y + n;
    
    %dummy image
    dummy_im = im*0;
    dummy_im(row_min:row_max, col_min:col_max) = disk;
    
    %get element whitin the border
    idx = find(dummy_im == 1);
end

