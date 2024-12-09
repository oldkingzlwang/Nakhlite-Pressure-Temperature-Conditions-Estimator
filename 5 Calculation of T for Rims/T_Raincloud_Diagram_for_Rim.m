% This code reads Output_T_Rim_xxx.xlsx in "5 Calculation of T for Rims" folder,
% which were generated using Cpx_only_t_calculator_rim.py.
% This code will export one raincloud figures (Output_T_Raincloud_Rim.pdf
% and one csv files (Output_T_Raincloud_Rim.csv, which save the T 
% calculation results from cpx rims of nakhlites.
% Written by Zilong Wang (Dragon Prince) on 9th December 2024.

clear;clc;

%% Step 1: Import the rim-T data

T_Cec=rim_t_calc('Output_T_Rim_Cec.xlsx');
T_GV=rim_t_calc('Output_T_Rim_GV.xlsx');
T_Laf=rim_t_calc('Output_T_Rim_Laf.xlsx');
T_MIL=rim_t_calc('Output_T_Rim_MIL.xlsx');
T_Nak=rim_t_calc('Output_T_Rim_Nak.xlsx');
T_10645=rim_t_calc('Output_T_Rim_10645.xlsx');
T_10720=rim_t_calc('Output_T_Rim_10720.xlsx');
T_11013=rim_t_calc('Output_T_Rim_11013.xlsx');
T_13669=rim_t_calc('Output_T_Rim_13669.xlsx');
T_5790=rim_t_calc('Output_T_Rim_5790.xlsx');
T_817=rim_t_calc('Output_T_Rim_817.xlsx');
T_998=rim_t_calc('Output_T_Rim_998.xlsx');
T_Ys=rim_t_calc('Output_T_Rim_Ys.xlsx');
T_QM=rim_t_calc('Output_T_Rim_QM.xlsx');

dataCell={T_Cec,T_GV,T_Laf,T_MIL,T_Nak,...
    T_10645,T_10720,T_11013,T_13669,T_5790,...
    T_817,T_998,T_Ys,T_QM};
dataName={'Cec 022','GV','Laf','MILs','Nakhla','N10645','N10720','N11013',...
    'N13669','N5790','N817','N998','Ys','QM005'};

colorList=[0.450980392156863	0.223529411764706	0.341176470588235
           0.505882352941176	0.231372549019608	0.243137254901961
           0.568627450980392	0.298039215686275	0.184313725490196
           0.647058823529412	0.419607843137255	0.176470588235294
           0.733333333333333	0.580392156862745	0.247058823529412
           0.815686274509804	0.752941176470588	0.419607843137255
           0.831372549019608	0.866666666666667	0.619607843137255
           0.737254901960784	0.878431372549020	0.756862745098039
           0.572549019607843	0.811764705882353	0.807843137254902
           0.403921568627451	0.690196078431373	0.792156862745098
           0.313725490196078	0.545098039215686	0.733333333333333
           0.325490196078431	0.400000000000000	0.623529411764706
           0.388235294117647	0.282352941176471	0.478431372549020
           0.447058823529412	0.223529411764706	0.349019607843137];

%% Step 2: Plot the temperature data
% This raincloud code is modified from Slandarer
% Please see https://mp.weixin.qq.com/s/na78cit9pXVnSF23R2EesA for details

classNum=length(dataCell);

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

rate=5;

results_T = table('Size', [classNum, 4], ...
                'VariableTypes', {'string', 'double', 'double', 'double'}, ...
                'VariableNames', {'Name', 'Lower quartile', 'Median', 'Upper quartile'});

for i=1:classNum
    tX=dataCell{i};tX=tX(:);
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

% Save the data to Output_T_Raincloud_Rim.csv
writetable(results_T, 'Output_T_Raincloud_Rim.csv');
disp('Results exported to Output_T_Raincloud_Rim.csv');

set(gca, 'Box', 'on', 'TickDir', 'out', 'TickLength', [.01 .01], ...
    'XMinorTick', 'off', 'YMinorTick', 'off', 'YGrid', 'off', ...
    'XColor', [.0 .0 .0], 'YColor', [.0 .0 .0],'LineWidth', .75,...
    'FontName', 'Calibri', 'FontSize', 13)
ylabel('Temperature (°C)')

hold off

% Save the figure to Output_T_Raincloud_Rim.pdf
set(gcf, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);
set(gcf, 'PaperPositionMode', 'auto');
exportgraphics(gcf,strcat('Output_T_Raincloud_Rim.pdf'), 'ContentType', 'vector');

%% Function to import and preprocess the data generated from thermometers
function data = rim_t_calc(filename)
A24 = readtable(filename, 'Sheet', 'A24');
A24.Temperature_C(strcmp(A24.warning, 'Input out of bound')) = NaN;

W21 = readtable(filename, 'Sheet', 'W21');
W21(1,:) = [];
W21.Var2(isnan(W21.Var2)) = NaN;
W21.Var2 = W21.Var2-273.15;

assert(height(A24) == height(W21), 'A24 and W21 must have the same number of rows.');

data = nan(height(A24), 1); % 1000x1 matrix initialized with NaN

for i = 1:height(A24)
    temp_A24 = A24.Temperature_C(i);
    temp_W21 = W21.Var2(i);
    if isnan(temp_A24) || isnan(temp_W21)
        % If either value is NaN, the result is NaN
        data(i) = NaN;
    else
        % Otherwise, compute the average
        data(i) = mean([temp_A24, temp_W21]);
    end
end
end