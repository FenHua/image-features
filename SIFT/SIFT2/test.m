clear
tic
img1 = imread('scene.pgm');
img2 = imread('book.pgm');
[des1,loc1] = getFeatures(img1);
[des2,loc2] = getFeatures(img2);
matched = match(des1,des2);
drawFeatures(img1,loc1);
drawFeatures(img2,loc2);
drawMatched(matched,img1,img2,loc1,loc2);
toc