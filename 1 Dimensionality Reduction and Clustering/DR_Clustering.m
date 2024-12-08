clear;clc;

currentFolder = pwd;
parentFolder = fullfile(currentFolder, '..');
filePath = fullfile(parentFolder, 'Nak_pyroxene.xlsx');

sheets = sheetnames(filePath);
k_matrix = [3,2,3,3,2,3,3,3,3,2,2,2,3,2];

for i=1:size(k_matrix,2)
    data=readmatrix(filePath,'Sheet',sheets(i));
    X=data(:,2:14);
    k = k_matrix(i);
    fileout=sheets(i);
    pca_kmeans_calculator(X,k,fileout);
    disp(sheets(i))
end

function pca_kmeans_calculator(X,k,fileout)
% % Identify and remove outliers using Mahalanobis distance, optional
% d = mahal(X, X);  % Compute Mahalanobis distance for each point
% threshold = chi2inv(0.975, 13);  % 95% confidence interval
% outliers = d > threshold;
% 
% % Remove outliers
% X = X(~outliers, :);

% Define range for k
kValues = 1:10;
WCSS = zeros(length(kValues),1);

for i = 1:length(kValues)
    [~, ~, sumd] = kmeans(X, kValues(i), 'Replicates', 50);
    WCSS(i) = sum(sumd);
end

tiledlayout(1,3,"TileSpacing","compact","Padding","compact")

% Plot the Elbow Curve
nexttile;
plot(kValues, WCSS, 'bo-', 'LineWidth', 2);
xlabel('Number of Clusters k');
ylabel('Within-Cluster Sum of Squares (WCSS)');
title('Elbow Method for Determining Optimal k');
set(gca, 'Box', 'on', ... 
         'LineWidth', .75, 'FontName', 'Calibri', 'FontSize', 12,...  
         'XGrid', 'off', 'YGrid', 'off', ...  
         'TickDir', 'out', 'TickLength', [.01 .01])


% Perform K-Means on reduced data
opts = statset('Display','final');
[idx, C] = kmeans(X, k, 'Distance','sqeuclidean','Replicates', 100, 'Options', opts);

% Compute silhouette values
% silhouetteValues = silhouette(X, idx);

% Plot Silhouette
nexttile;
silhouette(X, idx);
title('Silhouette Plot for K-Means Clustering');
xlabel('Silhouette Value');
ylabel('Cluster');
set(gca, 'Box', 'on',... 
         'LineWidth', .75, 'FontName', 'Calibri', 'FontSize', 12,...  
         'XGrid', 'off', 'YGrid', 'off', ...  
         'TickDir', 'out', 'TickLength', [.01 .01])

% Split the data into two subsets based on cluster indices
subset1 = X(idx == 1, :);
subset2 = X(idx == 2, :);
subset3 = X(idx == 3, :);

% Display the number of samples in each subset
fprintf('Subset1 size: %d x %d\n', size(subset1, 1), size(subset1, 2));
fprintf('Subset2 size: %d x %d\n', size(subset2, 1), size(subset2, 2));
fprintf('Subset3 size: %d x %d\n', size(subset3, 1), size(subset3, 2));

% Perform PCA to reduce data to 2 dimensions for visualization
[~, score, ~] = pca(X);

% Plot the clusters using the first two principal components
nexttile;
gscatter(score(:,1), score(:,2), idx, 'rbk', 'o^s');
hold on

% Plot the cluster centroids
% plot(coeff(:,1)*C_pca(:,1)', coeff(:,2)*C_pca(:,1)', 'kx', 'MarkerSize', 15, 'LineWidth', 3);

% Add legend and labels
if k==2
    legend('Cluster 1', 'Cluster 2', 'Location', 'best');
elseif k==3
    legend('Cluster 1', 'Cluster 2', 'Cluster 3', 'Location', 'best');
end
title('K-Means Clustering with k = 3 (PCA Projection)');
xlabel('Principal Component 1');
ylabel('Principal Component 2');
hold off

set(gca, 'Box', 'on',... 
         'LineWidth', .75, 'FontName', 'Calibri', 'FontSize', 12,...  
         'XGrid', 'off', 'YGrid', 'off', ...  
         'TickDir', 'out', 'TickLength', [.01 .01])

figWidth = 1200; figHeight = 400;
set(gcf, 'Position', [100, 100, figWidth, figHeight]);
set(gcf, 'PaperPositionMode', 'auto');
exportgraphics(gcf,strcat('ClusterResult_',fileout,'.pdf'), 'ContentType', 'vector');
close all
end