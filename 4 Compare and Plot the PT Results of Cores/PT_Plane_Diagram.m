% This code reads Output_P_Raincloud.csv and Output_P_Raincloud.csv, which
% were generated using PT_Raincloud_Diagram.m
% This code will export a plane diagram (PT_Plane_Diagram.pdf) of 
% pressure and temperature where the pyroxene cores of Martian nakhlite formed.
% Written by Zilong Wang (Dragon Prince) on 8th December 2024.

clear;clc;

data_P=readtable("Output_P_Raincloud.csv",'VariableNamingRule','preserve');
data_T=readtable("Output_P_Raincloud.csv",'VariableNamingRule','preserve');

dataName={'Cec 022','Governador Valadares','Lafayette','MILs','Nakhla',...
    'NWA 10645','NWA 10720','NWA 11013','NWA 13669','NWA 5790',...
    'NWA 817','NWA 998','Ys','Qued Mya 005'};

P_pos_err=data_P.("Upper quartile")-data_P.Median;
P_neg_err=data_P.Median-data_P.("Lower quartile");
T_pos_err=data_T.("Upper quartile")-data_T.Median;
T_neg_err=data_T.Median-data_T.("Lower quartile");

C=[ 0.3098    0.1020    0.2392
    0.2510    0.1647    0.3490
    0.2039    0.2745    0.4784
    0.2392    0.4196    0.6039
    0.3922    0.5725    0.7059
    0.6000    0.7059    0.7765
    0.7804    0.7647    0.7569
    0.8510    0.7098    0.6275
    0.8235    0.5843    0.4549
    0.7373    0.4314    0.2824
    0.6000    0.2627    0.1529
    0.4627    0.1333    0.1216
    0.3765    0.0863    0.1569
    0.3137    0.0980    0.2353];

yline(0,'--k','Martian surface','LineWidth',1);

hold on

yline(1.19,'--k','10 km depth','LineWidth',1);
yline(2.38,'--k','20 km depth','LineWidth',1);

p1=errorbar(data_T.Median(1),data_P.Median(1),P_neg_err(1),P_pos_err(1),...
    T_neg_err(1),T_pos_err(1),'s','MarkerSize',10,...
    'MarkerEdgeColor','k','MarkerFaceColor',C(1,:),'CapSize',0);
p1.Color='k';

p2=errorbar(data_T.Median(2),data_P.Median(2),P_neg_err(2),P_pos_err(2),...
    T_neg_err(2),T_pos_err(2),'o','MarkerSize',8,...
    'MarkerEdgeColor','k','MarkerFaceColor',C(2,:),'CapSize',0);
p2.Color='k';

p3=errorbar(data_T.Median(3),data_P.Median(3),P_neg_err(3),P_pos_err(3),...
    T_neg_err(3),T_pos_err(3),'^','MarkerSize',8,...
    'MarkerEdgeColor','k','MarkerFaceColor',C(3,:),'CapSize',0);
p3.Color='k';

p4=errorbar(data_T.Median(4),data_P.Median(4),P_neg_err(4),P_pos_err(4),...
    T_neg_err(4),T_pos_err(4),'d','MarkerSize',8,...
    'MarkerEdgeColor','k','MarkerFaceColor',C(4,:),'CapSize',0);
p4.Color='k';

p5=errorbar(data_T.Median(5),data_P.Median(5),P_neg_err(5),P_pos_err(5),...
    T_neg_err(5),T_pos_err(5),'s','MarkerSize',10,...
    'MarkerEdgeColor','k','MarkerFaceColor',C(5,:),'CapSize',0);
p5.Color='k';

p6=errorbar(data_T.Median(6),data_P.Median(6),P_neg_err(6),P_pos_err(6),...
    T_neg_err(6),T_pos_err(6),'o','MarkerSize',8,...
    'MarkerEdgeColor','k','MarkerFaceColor',C(6,:),'CapSize',0);
p6.Color='k';

p7=errorbar(data_T.Median(7),data_P.Median(7),P_neg_err(7),P_pos_err(7),...
    T_neg_err(7),T_pos_err(7),'^','MarkerSize',8,...
    'MarkerEdgeColor','k','MarkerFaceColor',C(7,:),'CapSize',0);
p7.Color='k';

p8=errorbar(data_T.Median(8),data_P.Median(8),P_neg_err(8),P_pos_err(8),...
    T_neg_err(8),T_pos_err(8),'d','MarkerSize',8,...
    'MarkerEdgeColor','k','MarkerFaceColor',C(8,:),'CapSize',0);
p8.Color='k';

p9=errorbar(data_T.Median(9),data_P.Median(9),P_neg_err(9),P_pos_err(9),...
    T_neg_err(9),T_pos_err(9),'s','MarkerSize',10,...
    'MarkerEdgeColor','k','MarkerFaceColor',C(9,:),'CapSize',0);
p9.Color='k';

p10=errorbar(data_T.Median(10),data_P.Median(10),P_neg_err(10),P_pos_err(10),...
    T_neg_err(10),T_pos_err(10),'o','MarkerSize',8,...
    'MarkerEdgeColor','k','MarkerFaceColor',C(10,:),'CapSize',0);
p10.Color='k';

p11=errorbar(data_T.Median(11),data_P.Median(11),P_neg_err(11),P_pos_err(11),...
    T_neg_err(11),T_pos_err(11),'^','MarkerSize',8,...
    'MarkerEdgeColor','k','MarkerFaceColor',C(11,:),'CapSize',0);
p11.Color='k';

p12=errorbar(data_T.Median(12),data_P.Median(12),P_neg_err(12),P_pos_err(12),...
    T_neg_err(12),T_pos_err(12),'d','MarkerSize',8,...
    'MarkerEdgeColor','k','MarkerFaceColor',C(12,:),'CapSize',0);
p12.Color='k';

p13=errorbar(data_T.Median(13),data_P.Median(13),P_neg_err(13),P_pos_err(13),...
    T_neg_err(13),T_pos_err(13),'s','MarkerSize',10,...
    'MarkerEdgeColor','k','MarkerFaceColor',C(13,:),'CapSize',0);
p13.Color='k';

p14=errorbar(data_T.Median(14),data_P.Median(14),P_neg_err(14),P_pos_err(14),...
    T_neg_err(14),T_pos_err(14),'o','MarkerSize',8,...
    'MarkerEdgeColor','k','MarkerFaceColor',C(14,:),'CapSize',0);
p14.Color='k';

hold off

xlabel('Temperature (°C)')
ylabel('Pressure (kbar)')
lgd=legend([p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14],...
    'Cec 022','Governador Valadares','Lafayette','MILs','Nakhla',...
    'NWA 10645','NWA 10720','NWA 11013','NWA 13669','NWA 5790',...
    'NWA 817','NWA 998','Ys','Qued Mya 005',...
    'Location', 'northwest','NumColumns',2);
set(gca, 'Box', 'on', 'xcolor','k','ycolor','k',...
         'FontName', 'Calibri', 'FontSize', 13,...
         'LineWidth', .5, ...
         'XGrid', 'off', 'YGrid', 'off', ...                            
         'TickDir', 'out', 'TickLength', [.01 .01])
set(lgd, 'FontName',  'Calibri', 'FontSize', 12)

figureUnits = 'centimeters';
figureHandle = get(groot,'CurrentFigure');
figW = 700;
figH = 700;
set(figureHandle,'PaperUnits',figureUnits);
set(figureHandle,'Position',[100 100 figW figH]);
set(gca, 'LooseInset', get(gca, 'TightInset')); 
set(gcf, 'PaperPositionMode', 'auto');
figureHandle.Renderer='Painters';
fileout = 'PT_Plane_Diagram';
exportgraphics(gcf,[fileout,'.pdf'], 'ContentType', 'vector');