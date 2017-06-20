function image = edgeresponse(im)
        %cmfrat filters 0, 20, 40, 60, 80, 100, 120, 140, 160
        f0 = cmfrat(11, 11, 0);
        f20 = cmfrat(11, 11, 20);
        f40 = cmfrat(11, 11, 40);
        f60 = cmfrat(11, 11, 60);
        f80 = cmfrat(11, 11, 80);
        f100 = cmfrat(11, 11, 100);
        f120 = cmfrat(11, 11, 120);
        f140 = cmfrat(11, 11, 140);
        f160 = cmfrat(11, 11, 160);

        im0 = imfilter(im, f0);
        im20 = imfilter(im, f20);
        im40 = imfilter(im, f40);
        im60 = imfilter(im, f60);
        im80 = imfilter(im, f80);
        im100 = imfilter(im, f100);
        im120 = imfilter(im, f120);
        im140 = imfilter(im, f140);
        im160 = imfilter(im, f160);

        %combied image
        image = maxresponse(im0, im20, im40, im60, im80, im100, im120, im140, im160);

function mat = cmfrat(row, col, angle)
    row = row + 4;
    col = col + 4;
    mat = zeros(row, col);
    
    m = -tand(angle);
    a = round(col / 2);
    b = round(row / 2);
    
    if (angle >= 0 && angle <= 45) || (angle > 135 && angle <= 180)
        for x=col - 2:-1:3
            y = round(m*(x - a) + b);
            mat([y-1, y, y+1], x) = -4/14;
            mat([y-3, y-2, y+2, y+3], x) = 3/14;
        end
        
    elseif angle > 45 && angle <= 135
        for y=row - 2:-1:3
            x = round((y - b)/m + a);
            mat(y, [x-1, x, x+1]) = -4/14;
            mat(y, [x-3, x-2, x+2, x+3]) = 3/14;
        end
    end
    
function image = maxresponse(im0, im20, im40, im60, im80, im100, im120, im140, im160)
[row, col] = size(im0);
image = zeros(row, col);

for t=1:row
   for k=1:col
        image(t, k) = max([im0(t, k), im20(t, k), im40(t, k), im60(t, k), im80(t, k), im100(t, k), im120(t, k), im140(t, k), im160(t, k)]);  
   end
end
