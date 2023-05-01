function [images, labels] = loadAndPreprocessImages(folder, classFolders)
    images = [];
    labels = [];
    for i = 1:numel(classFolders)
        class = classFolders{i};
        classPath = fullfile(folder, class);
        imageFiles = dir(fullfile(classPath, '*.png'));
        for j = 1:numel(imageFiles)
            image = imread(fullfile(classPath, imageFiles(j).name));
            image = im2gray(image);
            image = imbinarize(image);
            if isempty(images)
                images = image;
                images = reshape(images, [size(image, 1), size(image, 2), 1, 1]);
            else
                images = cat(4, images, image);
            end
            labels = cat(1, labels, i);
        end
    end
end
