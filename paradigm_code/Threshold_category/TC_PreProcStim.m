mkdir stimdata
for c = 1:4
    for ex = 1:5
        exemplar = [param.categories{c}, num2str(ex)];
        pic_dir = [param.stimDir, exemplar, '.jpg'];
        imdata = imresize(imread(pic_dir), param.imsize);
        if (size(imdata, 3)) > 1, imdata = rgb2gray( imdata ); end
        imdata = reshape(zscore(double(imdata(:))), 300, 300);
        imdata = mat2gray((imdata)) * 2 - 1; 
        imdata = imgaussfilt(imdata, 1.5);
        save(['stimdata/', exemplar], 'imdata')
    end
end
