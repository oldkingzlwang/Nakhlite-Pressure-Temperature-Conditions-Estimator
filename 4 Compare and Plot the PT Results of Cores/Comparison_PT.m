% This code reads Nak_pyroxene.xlsx in the parent directory, and
% Output_PT_xxx.xlsx in "3 PT Calculations for Cores" folder,
% which were used to implement intra-sample comparison of P-T Results.
% This code will export two PDF figures (Output_P_summary.pdf and 
% Output_T_summary.pdf). Open the files to check details.
% Written by Zilong Wang (Dragon Prince) on 8th December 2024.

clear;clc;

currentFolder = pwd;
parentFolder = fullfile(currentFolder, '..');
filePath = fullfile(parentFolder, 'Nak_pyroxene.xlsx');
ptFolder = fullfile(parentFolder, '3 PT Calculations for Cores');

sheets = sheetnames(filePath);

%% Implement pressure distribution calculations
for i=1:size(sheets,1)
    T = readtable(filePath, 'Sheet', sheets(i), 'Range', 'P:AM',...
        'ReadVariableNames', true, 'VariableNamingRule','preserve');
    fileout=sheets(i);

    idx = strcmp(T{:, 1}, 'Core');
    Original_data = table2array(T(idx, 23));
    P_original = Original_data(~isnan(Original_data));
    
    ptFileName = strcat('Output_PT_', sheets(i), '.xlsx');
    ptFilePath = fullfile(ptFolder, ptFileName);

    Generated_data = readmatrix(ptFilePath,'Range','B:B');
    Generated_data(1,:) = [];
    P_generated = Generated_data(~isnan(Generated_data));

    calc_p_dist(P_generated,P_original,fileout);
end

close all

%% Implement temperature distribution calculations
for i=1:size(sheets,1)
    T = readtable(filePath, 'Sheet', sheets(i), 'Range', 'P:AM',...
        'ReadVariableNames', true, 'VariableNamingRule','preserve');
    fileout=sheets(i);

    % Step 2: Identify rows where the last column (originally column P) is "Core"
    % The last column of T is T{:, end}, which returns all rows from the last column 
    % as a cell array or string array.
    idx = strcmp(T{:, 1}, 'Core');

    % Step 3: Extract columns B to K based on these indices
    Original_data = table2array(T(idx, 24));
    T_original = Original_data(~isnan(Original_data))-273.15;

    ptFileName = strcat('Output_PT_', sheets(i), '.xlsx');
    ptFilePath = fullfile(ptFolder, ptFileName);

    Generated_data = readmatrix(ptFilePath,'Range','C:C');
    Generated_data(1,:) = [];
    T_generated = Generated_data(~isnan(Generated_data))-273.15;

    calc_t_dist(T_generated,T_original,fileout);
end

close all

%% Function to calculate the frequency distribution figure of pressure
function calc_p_dist(P_generated,P_original,fileout)

nexttile;hold on
p1=histogram(P_generated,20);
p2=histogram(P_original,20);
hold off
title(strcat("Pressure distribution of ",fileout));
xlabel('Pressures (kbar)');
ylabel('Frequency');
hold off
set(gca, 'Box', 'on',... 
         'LineWidth', .75, 'FontName', 'Calibri', 'FontSize', 12,...  
         'XGrid', 'off', 'YGrid', 'off', ...  
         'TickDir', 'out', 'TickLength', [.01 .01])
% xlim([-3 3])

if fileout=="QM"
    hLegend = legend([p1,p2],'Generated EPMA data', 'Original EPMA data');
    hLegend.Layout.Tile = 15;
    set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
    set(gcf, 'PaperPositionMode', 'auto');
    exportgraphics(gcf,strcat('Output_P_summary.pdf'), 'ContentType', 'vector');
end
% pause(2)

fprintf('---------------------\n')
fprintf('Mann-Whitney U Test of %s:\n',fileout);
[p_med, ~] = ranksum(P_generated, P_original);
if p_med < 0.05
    disp('The generated dataset and original dataset differ significantly.')
else
    disp('No significant difference between generated dataset and original dataset.')
end

% Conduct a two-sample t-test
fprintf('Two-sample t-test of %s:\n',fileout);
[~, p_mean] = ttest2(P_generated, P_original);
if p_mean < 0.05
    disp('Means of the two datasets differ significantly.')
else
    disp('No significant difference in means of the two datasets.')
end

% Conduct an F-test to compare variances
[~, p_var] = vartest2(P_generated, P_original);
if p_var < 0.05
    disp('The standard deviations of the two datasets differ significantly.')
else
    disp('No significant difference in the standard deviations of the two datasets.')
end

end

%% Function to calculate the frequency distribution figure of temperature
function calc_t_dist(T_generated,T_original,fileout)

nexttile;hold on
p1=histogram(T_generated,20);
p2=histogram(T_original,20);
hold off
title(strcat("Temperature distribution of ",fileout));
xlabel('Temperature (°C)');
ylabel('Frequency');
hold off
set(gca, 'Box', 'on',... 
         'LineWidth', .75, 'FontName', 'Calibri', 'FontSize', 12,...  
         'XGrid', 'off', 'YGrid', 'off', ...  
         'TickDir', 'out', 'TickLength', [.01 .01])
% xlim([-3 3])

if fileout=="QM"
    hLegend = legend([p1,p2],'Generated EPMA data', 'Original EPMA data');
    hLegend.Layout.Tile = 15;
    set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
    set(gcf, 'PaperPositionMode', 'auto');
    exportgraphics(gcf,strcat('Output_T_summary.pdf'), 'ContentType', 'vector');
end
% pause(2)

fprintf('---------------------\n')
fprintf('Mann-Whitney U Test of %s:\n',fileout);
[p_med, ~] = ranksum(T_generated, T_original);
if p_med < 0.05
    disp('The generated dataset and original dataset differ significantly.')
else
    disp('No significant difference between generated dataset and original dataset.')
end

% Conduct a two-sample t-test
fprintf('Two-sample t-test of %s:\n',fileout);
[~, p_mean] = ttest2(T_generated, T_original);
if p_mean < 0.05
    disp('Means of the two datasets differ significantly.')
else
    disp('No significant difference in means of the two datasets.')
end

% Conduct an F-test to compare variances
[~, p_var] = vartest2(T_generated, T_original);
if p_var < 0.05
    disp('The standard deviations of the two datasets differ significantly.')
else
    disp('No significant difference in the standard deviations of the two datasets.')
end

end