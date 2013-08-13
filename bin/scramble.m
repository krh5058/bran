
scrambleSizes = [2 4 8 16 32]; % Pixel sizes of scramble square sub-section

for i = 1:12
    [A,MAP,ALPHA] = imread([int2str(i) '.png']);
    
    y = size(A,1); % Rows (y)
    x = size(A,2); % Columns (x)
    
    A1 = A(:,:,1);
    A2 = A(:,:,2);
    A3 = A(:,:,3);
    
    for s = 1:length(scrambleSizes)
        
%         index = reshape(Shuffle(1:x*y),x,y);
        
        mody = mod(y,scrambleSizes(s)); % Add rows
        modx = mod(x,scrambleSizes(s)); % Add columns
        
        y2 = y + (scrambleSizes(s) - mody);
        x2 = x + (scrambleSizes(s) - modx);
        
        B = intmax('uint8')*ones([y2 x2 3],'uint8'); % 'White' 3D uint8 matrix
        B2 = B; % Pre-allocate for scrambled image
        
%         B1 = A1(index);
%         B2 = A2(index);
%         B3 = A3(index);
        
        B(1:y,1:x,1) = A1;
        B(1:y,1:x,2) = A2;
        B(1:y,1:x,3) = A3;
        
        imshow(B)
        
        rowindex = 1:scrambleSizes(s):y2;
        colindex = 1:scrambleSizes(s):x2;
        
        coord_array = zeros([length(rowindex) length(colindex) 2]);
        
        hold on
        for r = 1:length(rowindex)
            plot(colindex,rowindex(r),'g');
            for c = 1:length(colindex)
                coord_array(r,c,:) = [rowindex(r) colindex(c)];
            end
        end
        hold off
        
        print(gcf,[int2str(i) '_' int2str(scrambleSizes(s)) 'sq_grid.png'],'-dpng');
        
        close(gcf);
        
        reshape_array = reshape(coord_array,length(rowindex)*length(colindex),2,1);
        shuffle_array = reshape_array(Shuffle(1:length(reshape_array)),:);
        
        for repind = 1:length(shuffle_array)
            B2(reshape_array(repind,1):reshape_array(repind,1)+scrambleSizes(s)-1,reshape_array(repind,2):reshape_array(repind,2)+scrambleSizes(s)-1,:) = B(shuffle_array(repind,1):shuffle_array(repind,1)+scrambleSizes(s)-1,shuffle_array(repind,2):shuffle_array(repind,2)+scrambleSizes(s)-1,:);
        end
        
%         imshow(B2);
        
        imwrite(B2,[int2str(i) '_' int2str(scrambleSizes(s)) 'sq.png'],'PNG');
        
        close(gcf);
    end
    
end