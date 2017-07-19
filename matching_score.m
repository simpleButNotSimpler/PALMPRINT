function score = matching_score(test, db)
    [row, col] = find(test);
    score = 0;
    
    len = numel(row);
    for t=1:len
        x = row(t);
        y = col(t);
        score = score + (db(x,y) | db(x+1,y) | db(x-1,y) | db(x,y+1) | db(y,x+1));
    end
    
    score = score/len;
end