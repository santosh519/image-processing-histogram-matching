%% 
% Histogram Matching to Remove Stripes from Landsat Images
% Author: Santosh Adhikari
% ------------------------------------------------------------------------------
clearvars; close all; clc;

%% 1. User Input: Select the Landsat ETM+ Band Image
validBands = [1,2,3,4,5,7];

% Build comma-separated list "1,2,3,4,5,7"
bandList = sprintf('%d,', validBands);
bandList(end) = [];    % strip trailing comma

prompt = sprintf('Select ETM+ band image to process (%s): ', bandList);

% Initialize to something invalid
band = NaN;

% Loop until the user picks a valid band
while ~ismember(band, validBands)
    band = input(prompt);
    if ~ismember(band, validBands)
        fprintf(2, '  → Invalid selection "%s".  Valid options are: %s\n\n', ...
                num2str(band), bandList);
    end
end

fprintf('  → OK! Processing Band %d\n\n', band);

%% 2. Read Geo-referenced Image
baseDir  = fullfile(pwd, 'Images');
fileName = sprintf('ETM_B%d.tif', band);
filePath = fullfile(baseDir, fileName);

try
    image = readgeoraster(filePath);
catch ME
    error('Could not read "%s":\n%s', filePath, ME.message);
end

%% 3. Histogram of Original Image
figure('Name','Original Histogram','Position',[100 100 1200 800]);
[countsOrig, binsOrig] = imhist(image);
bar(binsOrig, countsOrig, 'FaceColor',[.3 .6 .9]);
title( sprintf('Histogram of Original Image (Band %d)', band), ...
       'FontSize',16 );
xlabel('Digital Number (DN)', 'FontSize',14, 'FontWeight','bold');
ylabel('Frequency',         'FontSize',14, 'FontWeight','bold');
set(gca,'FontSize',14,'FontWeight','bold');

%% 4. Detector-Level Stats (Before Correction)
nDetectors = 16;
histBefore  = cell(1,nDetectors);
meanVals    = zeros(1,nDetectors);
stdDevs     = zeros(1,nDetectors);

for d = 1:nDetectors
    % Extract every 16th row starting at d → detector “d”
    detectorBlock = image(d:16:end, :);
    
    % Mask-out zeros
    mask          = detectorBlock ~= 0;
    validPixels   = detectorBlock(mask);
    
    % Compute histogram, mean & std dev
    [h, b]        = imhist(detectorBlock);
    histBefore{d} = h;
    meanVals(d)   = mean(double(validPixels));
    stdDevs(d)    = std(double(validPixels));
    
    fprintf('Detector %2d → rows: %4d,  mean=%.2f, std=%.2f\n', ...
            d, size(detectorBlock,1), meanVals(d), stdDevs(d));
end

%% 5. Plot All Detectors (Pre-correction)
colors = lines(nDetectors);  % professional colormap
figure('Name','Pre-Correction Histograms','Position',[100 100 1200 800]);
hold on;
for d = 1:nDetectors
    bar(b, histBefore{d}, 'FaceColor', colors(d,:), 'EdgeColor','none');
end
hold off;
title( sprintf('Pre-corrected Histograms of Band %d Detectors', band), ...
       'FontSize',16 );
xlabel('Digital Number (DN)', 'FontSize',14, 'FontWeight','bold');
ylabel('Frequency',         'FontSize',14, 'FontWeight','bold');
legend(arrayfun(@(x)sprintf('Det.%d',x), 1:nDetectors, 'UniformOutput',false), ...
       'Location','northeastoutside','FontSize',12);
set(gca,'FontSize',14,'FontWeight','bold');

%% 6. Compute Global Gain & Bias
refMean = mean(meanVals);
refStd  = mean(stdDevs);
gains   = refStd ./ stdDevs;
biases  = refMean - gains .* meanVals;

%% 7. Apply Correction & Rebuild Image
corrected = zeros(size(image),'double');
for d = 1:nDetectors
    rows = d:16:size(image,1);
    corrected(rows,:) = double(image(rows,:)) * gains(d) + biases(d);
end
corrected(image==0) = 0;         % enforce mask
corrected = uint8(corrected);    % back to 8-bit

%% 8. Detector-Level Stats (After Correction)
histAfter = cell(1,nDetectors);
for d = 1:nDetectors
    block = corrected(d:16:end, :);
    histAfter{d} = imhist(block);
    fprintf('Detector %2d after correction → rows: %4d\n', ...
            d, size(block,1));
end

%% 9. Plot All Detectors (Post-correction)
figure('Name','Post-Correction Histograms','Position',[100 100 1200 800]);
hold on;
for d = 1:nDetectors
    bar(b, histAfter{d}, 'FaceColor', colors(d,:), 'EdgeColor','none');
end
hold off;
title( sprintf('Corrected Histograms of Band %d Detectors', band), ...
       'FontSize',16 );
xlabel('Digital Number (DN)', 'FontSize',14, 'FontWeight','bold');
ylabel('Frequency',         'FontSize',14, 'FontWeight','bold');
legend(arrayfun(@(x)sprintf('Det.%d',x), 1:nDetectors, 'UniformOutput',false), ...
       'Location','northeastoutside','FontSize',12);
set(gca,'FontSize',14,'FontWeight','bold');

%% 10. Display Original vs. Corrected Images
figure('Name','Original Image','Position',[100 100 1200 800]);
imagesc(image); axis image off; colormap(gray);
title( sprintf('Original ETM+ Band %d', band), 'FontSize',16 );

figure('Name','Corrected Image','Position',[100 100 1200 800]);
imagesc(corrected); axis image off; colormap(gray);
title( sprintf('Corrected ETM+ Band %d', band), 'FontSize',16 );

%% 11. Final Histogram Comparison
figure('Name','Final Corrected Histogram','Position',[100 100 1200 800]);
[countsCorr, binsCorr] = imhist(corrected);
bar(binsCorr, countsCorr, 'FaceColor',[.8 .2 .2]);
title( sprintf('Histogram of Corrected Image (Band %d)', band), ...
       'FontSize',16 );
xlabel('Digital Number (DN)', 'FontSize',14, 'FontWeight','bold');
ylabel('Frequency',         'FontSize',14, 'FontWeight','bold');
set(gca,'FontSize',14,'FontWeight','bold');

%% 12. (Optional) Save Results Table
resultsTable = table((1:nDetectors)', meanVals', stdDevs', gains', biases', ...
    'VariableNames', {'Detector','Mean','StdDev','Gain','Bias'});
disp(resultsTable);
% writetable(resultsTable, sprintf('Band%d_detector_stats.csv',band));

% End of script
