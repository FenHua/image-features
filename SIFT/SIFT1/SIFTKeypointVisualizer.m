function image = SIFTKeypointVisualizer(Image, KeyPoints)
    % 此函数用于将sift特征可视化，输入的原始图片须为灰度图片
    image=Image;
    for i=1:length(KeyPoints)
        [x, y] = KeyPoints{i}.coordinates();
        circle = [y,x,5];
        % 关键点出画圈
        image = insertShape(image,'circle',circle,'LineWidth',1,'color',[255,0,0],'SmoothEdges',false);
    end
    for i=1:length(KeyPoints)
        [x, y] = KeyPoints{i}.coordinates();
        dir = KeyPoints{i}.direction();
        line = [y,x,y+10*sind(dir),x+10*cosd(dir)];
        % 关键点出画线
        image = insertShape(image,'line',line,'LineWidth',1,'color',[0,0,255]);
    end
    for i=1:6:length(KeyPoints)
        [x, y] = KeyPoints{i}.coordinates();
        % 用绿色的点区别关键点
        image(x,y,:) = [0,255,0];
    end
end