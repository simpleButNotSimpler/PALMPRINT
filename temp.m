x = -3:0.1:3;
 y = randn(1e4,1);
 NumElements = histc(y,x);
 SumElements = cumsum(NumElements);
 bar(x,SumElements,'BarWidth',1);
 title('Cumulative Histogram');
 figure;
 bar(x,(SumElements./length(y))*100,'BarWidth',1);
 title('Cumulative Percentage Histogram');