% This code implements Monte-Carlo modeling to generate any given numbers
% of compositions based on the measured EPMA compositions.
% The code reads the database file Nak_pyroxene.xlsx in the parent folder,
% and export 14 PDF files and 14 excel files named "Output_EPMA_xxx". 
% Written by Zilong Wang (Dragon Prince) on 9th December 2024.

clear;clc;

currentFolder = pwd;
parentFolder = fullfile(currentFolder, '..');
filePath = fullfile(parentFolder, 'Nak_pyroxene.xlsx');

% Step 1: Read data from columns B to P on sheet "Cec"
% 'ReadVariableNames', true attempts to read column headers from the first row.
sheets = sheetnames(filePath);
numValidSamples = 1000; % Change as your requirements

for i=1:size(sheets,1)
    T = readtable(filePath, 'Sheet', sheets(i), 'Range', 'B:P', 'ReadVariableNames', true);
    fileout=sheets(i);

    % Step 2: Identify rows where the last column (originally column P) is "Core"
    % The last column of T is T{:, end}, which returns all rows from the last column 
    % as a cell array or string array.
    idx = strcmp(T{:, end}, 'Core');

    % Step 3: Extract columns B to K based on these indices
    X = table2array(T(idx, 1:10));
    generate_random(X,numValidSamples,fileout);
    disp(fileout)
end

%% This function is adapted from Lunar-Mineral-EPMA-data-Generator
% https://github.com/oldkingzlwang/Lunar-Mineral-EPMA-data-Generator
% Please refer to the aforementioned website for details.

function generate_random(X,numValidSamples,fileout)

mu = mean(X);
Sigma = cov(X, 'omitrows');

% Initialize variables
xValidGenerated = [];
numAttempts = 0;

% Generate random data using the 
% mvnrnd function based on the mean and std values of test_data
while size(xValidGenerated, 1) < numValidSamples
    num_samples = numValidSamples * (numAttempts+1);  % Adjust factor as needed
    samples = mvnrnd(mu, Sigma, num_samples);

    % Delete the data that do not satisfy the EPMA standards
    % Condition 1: Non-negative values in all dimensions
    nonNegativeSamples = all(samples >= 0, 2);

    % Condition 2: Sum within [98.5, 101.5]
    rowSums = sum(samples, 2, 'omitnan');
    sumWithinRange = (rowSums >= 98.5) & (rowSums <= 101.5);

    % Combine both conditions
    validSamples = nonNegativeSamples & sumWithinRange;
    xValidGenerated = samples(validSamples, :);
    numAttempts = numAttempts + 1;

    % Optionally, prevent infinite loop
    if numAttempts > 1000  % Adjust as needed
        error('Could not generate enough valid samples after multiple attempts.');
    end
end

% Select the required number of samples
if size(xValidGenerated, 1) >= numValidSamples
    Xstar = xValidGenerated(1:numValidSamples, :);
else
    error('Not enough valid samples generated. Try increasing numNewSamples or numAttempts.');
end

combined_data = [Xstar; X];
group_labels = [ones(size(Xstar, 1), 1); 2 * ones(size(X, 1), 1)];
colors = 'rb';  markers = '.';
figure;
[h, ax, ~] = gplotmatrix(combined_data, [], group_labels, colors, markers, [], 'on', '', '');
axgd=["SiO2","TiO2","Al2O3","Cr2O3","FeO","MnO","MgO","CaO","Na2O","K2O"];
numVars = size(combined_data, 2);
for i = 1:numVars
   xlabel(ax(numVars, i), sprintf(axgd(i)));
   ylabel(ax(i, 1), sprintf(axgd(i)));
end
legend([h(1,1,1), h(1,1,2)], {'Generated data', 'Original data'}, 'Location', 'northeast');

set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
set(gcf, 'PaperPositionMode', 'auto');
exportgraphics(gcf,strcat('Output_EPMA_',fileout,'.pdf'), 'ContentType', 'vector');

rowSums = sum(Xstar, 2, 'omitnan');
results=array2table(round([Xstar,rowSums],3),'VariableNames',...
        {'SiO2_Cpx','TiO2_Cpx','Al2O3_Cpx','Cr2O3_Cpx','FeOt_Cpx',...
        'MnO_Cpx','MgO_Cpx','CaO_Cpx','Na2O_Cpx','K2O_Cpx','Total'});
writetable(results,strcat('Output_EPMA_',fileout,'.xlsx'));

close all
end