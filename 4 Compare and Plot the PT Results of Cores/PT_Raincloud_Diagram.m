% This code reads Output_PT_xxx.xlsx in "3 PT Calculations for Cores" folder,
% which were generated using Cpx_only_pt_calculator.py.
% This code will export two raincloud figures (Output_P_Raincloud.pdf and 
% Output_P_Raincloud.pdf) and two csv files (Output_P_Raincloud.csv and 
% Output_P_Raincloud.csv), which save the P-T calculation results from cpx
% cores of nakhlites.
% Written by Zilong Wang (Dragon Prince) on 8th December 2024.

clear;clc;

%% Step 1: Import the P-T data
currentFolder = pwd;
parentFolder = fullfile(currentFolder, '..');
ptFolder = fullfile(parentFolder, '3 PT Calculations for Cores');

PT_Cec=readmatrix(fullfile(ptFolder, "Output_PT_Cec.xlsx"),"Range","B:C"); 
PT_Cec=PT_Cec(2:end,:);
PT_GV=readmatrix(fullfile(ptFolder, "Output_PT_GV.xlsx"),"Range","B:C"); 
PT_GV=PT_GV(2:end,:);
PT_Laf=readmatrix(fullfile(ptFolder, "Output_PT_Laf.xlsx"),"Range","B:C"); 
PT_Laf=PT_Laf(2:end,:);
PT_MIL=readmatrix(fullfile(ptFolder, "Output_PT_MIL.xlsx"),"Range","B:C"); 
PT_MIL=PT_MIL(2:end,:);
PT_Nak=readmatrix(fullfile(ptFolder, "Output_PT_Nak.xlsx"),"Range","B:C"); 
PT_Nak=PT_Nak(2:end,:);
PT_10645=readmatrix(fullfile(ptFolder, "Output_PT_10645.xlsx"),"Range","B:C"); 
PT_10645=PT_10645(2:end,:);
PT_10720=readmatrix(fullfile(ptFolder, "Output_PT_10720.xlsx"),"Range","B:C"); 
PT_10720=PT_10720(2:end,:);
PT_11013=readmatrix(fullfile(ptFolder, "Output_PT_11013.xlsx"),"Range","B:C"); 
PT_11013=PT_11013(2:end,:);
PT_13669=readmatrix(fullfile(ptFolder, "Output_PT_13669.xlsx"),"Range","B:C"); 
PT_13669=PT_13669(2:end,:);
PT_5790=readmatrix(fullfile(ptFolder, "Output_PT_5790.xlsx"),"Range","B:C"); 
PT_5790=PT_5790(2:end,:);
PT_817=readmatrix(fullfile(ptFolder, "Output_PT_817.xlsx"),"Range","B:C"); 
PT_817=PT_817(2:end,:);
PT_998=readmatrix(fullfile(ptFolder, "Output_PT_998.xlsx"),"Range","B:C"); 
PT_998=PT_998(2:end,:);
PT_Ys=readmatrix(fullfile(ptFolder, "Output_PT_Ys.xlsx"),"Range","B:C"); 
PT_Ys=PT_Ys(2:end,:);
PT_QM=readmatrix(fullfile(ptFolder, "Output_PT_QM.xlsx"),"Range","B:C"); 
PT_QM=PT_QM(2:end,:);

dataCell1={PT_Cec(:,1),PT_GV(:,1),PT_Laf(:,1),PT_MIL(:,1),PT_Nak(:,1),...
    PT_10645(:,1),PT_10720(:,1),PT_11013(:,1),PT_13669(:,1),PT_5790(:,1),...
    PT_817(:,1),PT_998(:,1),PT_Ys(:,1),PT_QM(:,1)};
dataName={'Cec 022','GV','Laf','MILs','Nakhla','N10645','N10720','N11013',...
    'N13669','N5790','N817','N998','Ys','QM005'};

colorList=TheColor('sci',808,'map',size(dataName,2));

%% Step 2: Plot the pressure data
% This raincloud code is modified from Slandarer
% Please see https://mp.weixin.qq.com/s/na78cit9pXVnSF23R2EesA for details

classNum=length(dataCell1);

if size(colorList,1)==0
    colorList=repmat([130,170,172]./255,[classNum,1]);
else
    colorList=repmat(colorList,[ceil(classNum/size(colorList,1)),1]);
end
if isempty(dataName)
    for i=1:classNum
        dataName{i}=['class',num2str(i)];
    end
end

hold on
ax=gca;
ax.XLim=[1/2,classNum+2/3];
ax.XTick=1:classNum;
ax.LineWidth=1;
ax.XTickLabels=dataName(end:-1:1);

rate=0.5;

results_P = table('Size', [classNum, 4], ...
                'VariableTypes', {'string', 'double', 'double', 'double'}, ...
                'VariableNames', {'Name', 'Lower quartile', 'Median', 'Upper quartile'});

for i=1:classNum
    tX=dataCell1{i};tX=tX(:);
    [F,Xi]=ksdensity(tX);

    % Plot a mountain-ridge map
    patchCell(i) = fill(0.2 + [0, F, 0] .* rate + (classNum + 1 - i) .* ones(1, length(F) + 2), ...
        [Xi(1), Xi, Xi(end)], colorList(i, :), 'EdgeColor', [0, 0, 0], ...
        'FaceAlpha', 0.9, 'LineWidth', 1.2);

    % Other data acquisition
    qt25=quantile(tX(~isnan(tX)),0.25); % Lower quartile
    qt75=quantile(tX(~isnan(tX)),0.75); % Upper quartile 
    med=median(tX(~isnan(tX)));         % Median
    outliBool=isoutlier(tX(~isnan(tX)),'quartiles');  % Outlier point
    nX=tX(~outliBool);                    % Numbers within 95% confidence level

    % Save the results into table
    results_P.Name(i) = dataName{i};
    results_P.("Lower quartile")(i) = qt25; 
    results_P.Median(i) = med; 
    results_P.("Upper quartile")(i) = qt75; 

    % Plot scatter points 
    tY=(rand(length(tX),1)-0.5).*0.24+ones(length(tX),1).*(classNum+1-i);
    scatter(tY,tX,15,'CData',colorList(i,:),'MarkerEdgeAlpha',0.02,...
        'MarkerFaceColor',colorList(i,:),'MarkerFaceAlpha',0.5)

    % Plot a box-line diagram
    plot([(classNum+1-i),(classNum+1-i)],[min(nX),max(nX)],'k','lineWidth',1.2);
    fill((classNum+1-i)+[-1 1 1 -1].*0.12,[qt25,qt25,qt75,qt75],colorList(i,:),'EdgeColor',[0 0 0]);
    plot([(classNum+1-i)-0.12,(classNum+1-i)+0.12],[med,med],'Color',[0,0,0],'LineWidth',2.5)
end
% % Plot legends
% lgd=legend(patchCell,dataName);
% lgd.Location='best';
% lgd.NumColumns=2;

% Save the data to Output_P_Raincloud.csv
writetable(results_P, 'Output_P_Raincloud.csv');
disp('Results exported to Output_P_Raincloud.csv');

set(gca, 'Box', 'on', 'TickDir', 'out', 'TickLength', [.01 .01], ...
    'XMinorTick', 'off', 'YMinorTick', 'off', 'YGrid', 'off', ...
    'XColor', [.0 .0 .0], 'YColor', [.0 .0 .0],'LineWidth', .75,...
    'FontName', 'Calibri', 'FontSize', 13)
ylabel('Pressure (kbar)')

hold off

% Save the figure to Output_P_Raincloud.pdf
set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
set(gcf, 'PaperPositionMode', 'auto');
exportgraphics(gcf,strcat('Output_P_Raincloud.pdf'), 'ContentType', 'vector');

close all

%% Step 3: Plot the temperature data
% This raincloud code is modified from Slandarer
% Please see https://mp.weixin.qq.com/s/na78cit9pXVnSF23R2EesA for details

figure;

dataCell2={PT_Cec(:,2)-273.15,PT_GV(:,2)-273.15,PT_Laf(:,2)-273.15,...
    PT_MIL(:,2)-273.15,PT_Nak(:,2)-273.15,PT_10645(:,2)-273.15,...
    PT_10720(:,2)-273.15,PT_11013(:,2)-273.15,PT_13669(:,2)-273.15,...
    PT_5790(:,2)-273.15,PT_817(:,2)-273.15,PT_998(:,2)-273.15,...
    PT_Ys(:,2)-273.15,PT_QM(:,2)-273.15};

hold on
ax=gca;
ax.XLim=[1/2,classNum+2/3];
ax.XTick=1:classNum;
ax.LineWidth=1;
ax.XTickLabels=dataName(end:-1:1);

rate=7;

results_T = table('Size', [classNum, 4], ...
                'VariableTypes', {'string', 'double', 'double', 'double'}, ...
                'VariableNames', {'Name', 'Lower quartile', 'Median', 'Upper quartile'});

for i=1:classNum
    tX=dataCell2{i};tX=tX(:);
    [F,Xi]=ksdensity(tX);

    % Plot a mountain-ridge map
    patchCell(i) = fill(0.2 + [0, F, 0] .* rate + (classNum + 1 - i) .* ones(1, length(F) + 2), ...
        [Xi(1), Xi, Xi(end)], colorList(i, :), 'EdgeColor', [0, 0, 0], ...
        'FaceAlpha', 0.9, 'LineWidth', 1.2);

    % Other data acquisition
    qt25=quantile(tX(~isnan(tX)),0.25); % Lower quartile
    qt75=quantile(tX(~isnan(tX)),0.75); % Upper quartile 
    med=median(tX(~isnan(tX)));         % Median
    outliBool=isoutlier(tX(~isnan(tX)),'quartiles');  % Outlier point
    nX=tX(~outliBool);                    % Numbers within 95% confidence level

    % Save the results into table
    results_T.Name(i) = dataName{i};
    results_T.("Lower quartile")(i) = qt25; 
    results_T.Median(i) = med; 
    results_T.("Upper quartile")(i) = qt75; 

    % Plot scatter points 
    tY=(rand(length(tX),1)-0.5).*0.24+ones(length(tX),1).*(classNum+1-i);
    scatter(tY,tX,15,'CData',colorList(i,:),'MarkerEdgeAlpha',0.02,...
        'MarkerFaceColor',colorList(i,:),'MarkerFaceAlpha',0.5)

    % Plot a box-line diagram
    plot([(classNum+1-i),(classNum+1-i)],[min(nX),max(nX)],'k','lineWidth',1.2);
    fill((classNum+1-i)+[-1 1 1 -1].*0.12,[qt25,qt25,qt75,qt75],colorList(i,:),'EdgeColor',[0 0 0]);
    plot([(classNum+1-i)-0.12,(classNum+1-i)+0.12],[med,med],'Color',[0,0,0],'LineWidth',2.5)
end
% % Plot legends
% lgd=legend(patchCell,dataName);
% lgd.Location='best';
% lgd.NumColumns=2;

% Save the data to Output_T_Raincloud.csv
writetable(results_T, 'Output_T_Raincloud.csv');
disp('Results exported to Output_T_Raincloud.csv');

set(gca, 'Box', 'on', 'TickDir', 'out', 'TickLength', [.01 .01], ...
    'XMinorTick', 'off', 'YMinorTick', 'off', 'YGrid', 'off', ...
    'XColor', [.0 .0 .0], 'YColor', [.0 .0 .0],'LineWidth', .75,...
    'FontName', 'Calibri', 'FontSize', 13)
ylabel('Temperature (°C)')

hold off

% Save the figure to Output_T_Raincloud.pdf
set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
set(gcf, 'PaperPositionMode', 'auto');
exportgraphics(gcf,strcat('Output_T_Raincloud.pdf'), 'ContentType', 'vector');

close all