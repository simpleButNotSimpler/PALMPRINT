function th = percentile(im, perc)
    [counts, xi] = imhist(im);
    percent = counts/sum(counts) * 100;
    th = 256;
    temp = 0;
    while temp < perc && th >= 1
       temp = temp + percent(th);
       th = th - 1;
    end
    
    if th == 0
        th = 1;
    else
        th = xi(th);
    end
end