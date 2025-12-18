clc; clear; close all;

% === 1. 数据读取 ===
filename = 'data.xlsx';
if ~exist(filename, 'file')
    error('错误: 找不到文件 %s。', filename);
end

% 读取 Excel 文件
opts = detectImportOptions(filename);
opts.VariableNamingRule = 'preserve';
data_table = readtable(filename, opts);

% 辅助函数：获取列数据
get_col = @(name) data_table{:, name}(~isnan(data_table{:, name}));

% --- 教二数据 ---
j2_n = get_col('教二北逆时针');
j2_s = get_col('教二南逆时针');
j2_f2_corr = get_col('教二二层走廊');
j2_f2_class = get_col('教二二层教室');
j2_f4_corr = get_col('教二四层走廊');
j2_f4_class = get_col('教二四层教室');

% --- 教三数据 ---
j3_n = get_col('教三北逆时针');
j3_s = get_col('教三南逆时针');
j3_f2_corr = get_col('教三二层走廊');
j3_f2_class = get_col('教三二层教室');
j3_f4_corr = get_col('教三四层走廊');
j3_f4_class = get_col('教三四层教室');

% === 2. 数据整合 ===

% 室内数据保持合并，代表整体"室内"环境
data_b2_in = [j2_f2_corr; j2_f2_class; j2_f4_corr; j2_f4_class];
data_b3_in = [j3_f2_corr; j3_f2_class; j3_f4_corr; j3_f4_class];

% 选取"南面"作为室外参考基准
ref_b2_out = j2_s;
ref_b3_out = j3_s;

% === 3. 颜色定义 (统一色系) ===
% 使用 RGB 归一化值 [0-1]
c_south = [0.8500, 0.3250, 0.0980]; % 深橙红 (代表南面/强信号/混凝土)
c_north = [0.0000, 0.4470, 0.7410]; % 深蓝 (代表北面/弱信号/砖混)
c_indoor = [0.2000, 0.2000, 0.2000]; % 深灰 (代表室内)
c_fit_s = [0.6350, 0.0780, 0.1840]; % 暗红 (南面拟合线)
c_fit_n = [0.0000, 0.2000, 0.4000]; % 暗蓝 (北面拟合线)
c_corr = [0.4660, 0.6740, 0.1880];  % 绿色 (走廊)
c_class = [0.9290, 0.6940, 0.1250]; % 黄色 (教室)

% 设置通用绘图参数
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultLineLineWidth', 1.5);
set(0, 'DefaultFigureColor', 'w'); % 背景设为白色

%% --- 第一部分：教二（砖混结构）室外信号分析 (图1-4) ---

% 图1: 教二室外信号强度分布对比 (南 vs 北)
figure(1);
plot(j2_s, 'Color', c_south); hold on;
plot(j2_n, 'Color', c_north);
title('教二室外信号场强分布对比');
xlabel('采样点');
ylabel('信号强度 (dBm/Arbitrary)');
legend('教二南 (South)', '教二北 (North)');
grid on;
hold off;

% 图2: 教二室外信号直方图对比
figure(2);
h1 = histogram(j2_s, 20, 'Normalization', 'pdf', 'FaceColor', c_south, 'FaceAlpha', 0.5, 'EdgeColor', 'none');
hold on;
h2 = histogram(j2_n, 20, 'Normalization', 'pdf', 'FaceColor', c_north, 'FaceAlpha', 0.5, 'EdgeColor', 'none');
% 添加正态拟合曲线
[mu_s, sigma_s] = normfit(j2_s);
[mu_n, sigma_n] = normfit(j2_n);
x_range = linspace(min([j2_s; j2_n]), max([j2_s; j2_n]), 100);
plot(x_range, normpdf(x_range, mu_s, sigma_s), 'Color', c_fit_s, 'LineStyle', '--', 'LineWidth', 2);
plot(x_range, normpdf(x_range, mu_n, sigma_n), 'Color', c_fit_n, 'LineStyle', '--', 'LineWidth', 2);
title(['教二室外信号直方图对比 (南 \mu=', num2str(mu_s, '%.1f'), ', 北 \mu=', num2str(mu_n, '%.1f'), ')']);
xlabel('信号强度');
ylabel('概率密度');
legend('教二南', '教二北', '南面拟合', '北面拟合');
grid on;
hold off;

% 图3: 教二室外信号 CDF 对比
figure(3);
h_cdf1 = cdfplot(j2_s); hold on;
h_cdf2 = cdfplot(j2_n);
set(h_cdf1, 'Color', c_south, 'LineWidth', 2);
set(h_cdf2, 'Color', c_north, 'LineWidth', 2);
title('教二室外信号 CDF 对比');
legend('教二南', '教二北', 'Location', 'NorthWest');
xlabel('信号强度');
grid on;
hold off;

% 图4: 教二室外信号 Q-Q 图 (仅展示南面)
figure(4);
qqplot(j2_s);
% 获取当前线条并修改颜色
h_qq = get(gca, 'Children');
% qqplot通常生成三个对象：数据点、参考线、上下限
% 这里简单处理，尝试设置所有线条颜色
set(h_qq, 'Color', c_south, 'MarkerEdgeColor', c_south); 
title('教二南室外信号 Q-Q 图');
grid on;

%% --- 第二部分：教三（混凝土结构）室外信号分析 (图5-8) ---

% 图5: 教三室外信号强度分布对比
figure(5);
plot(j3_s, 'Color', c_south); hold on;
plot(j3_n, 'Color', c_north);
title('教三室外信号场强分布对比');
xlabel('采样点');
ylabel('信号强度');
legend('教三南', '教三北');
grid on;
hold off;

% 图6: 教三室外信号直方图对比
figure(6);
histogram(j3_s, 20, 'Normalization', 'pdf', 'FaceColor', c_south, 'FaceAlpha', 0.5, 'EdgeColor', 'none');
hold on;
histogram(j3_n, 20, 'Normalization', 'pdf', 'FaceColor', c_north, 'FaceAlpha', 0.5, 'EdgeColor', 'none');
[mu3_s, sigma3_s] = normfit(j3_s);
[mu3_n, sigma3_n] = normfit(j3_n);
x_range3 = linspace(min([j3_s; j3_n]), max([j3_s; j3_n]), 100);
plot(x_range3, normpdf(x_range3, mu3_s, sigma3_s), 'Color', c_fit_s, 'LineStyle', '--', 'LineWidth', 2);
plot(x_range3, normpdf(x_range3, mu3_n, sigma3_n), 'Color', c_fit_n, 'LineStyle', '--', 'LineWidth', 2);
title(['教三室外信号直方图对比 (南 \mu=', num2str(mu3_s, '%.1f'), ', 北 \mu=', num2str(mu3_n, '%.1f'), ')']);
xlabel('信号强度');
ylabel('概率密度');
legend('教三南', '教三北', '南面拟合', '北面拟合');
grid on;
hold off;

% 图7: 教三室外 CDF 对比
figure(7);
h_cdf3 = cdfplot(j3_s); hold on;
h_cdf4 = cdfplot(j3_n);
set(h_cdf3, 'Color', c_south, 'LineWidth', 2);
set(h_cdf4, 'Color', c_north, 'LineWidth', 2);
title('教三室外信号 CDF 对比');
legend('教三南', '教三北', 'Location', 'NorthWest');
xlabel('信号强度');
grid on;
hold off;

% 图8: 教三室外 Q-Q 图 (仅展示南面)
figure(8);
qqplot(j3_s);
h_qq2 = get(gca, 'Children');
set(h_qq2, 'Color', c_south, 'MarkerEdgeColor', c_south);
title('教三南室外信号 Q-Q 图');
grid on;

%% --- 第三部分：室内外对比分析 (图9-10) ---

% 图9: 教二室内外 CDF 对比 (室外取南面)
figure(9);
h_out_b2 = cdfplot(j2_s);
hold on;
h_in_b2 = cdfplot(data_b2_in);
set(h_out_b2, 'LineWidth', 2, 'Color', c_south);
set(h_in_b2, 'LineWidth', 2, 'Color', c_indoor, 'LineStyle', '--');
title('教二（砖混）室内外信号 CDF 对比');
legend('室外 (南)', '室内 (整体)', 'Location', 'NorthWest');
xlabel('信号强度');
grid on;
hold off;

% 图10: 教三室内外 CDF 对比 (室外取南面)
figure(10);
h_out_b3 = cdfplot(j3_s);
hold on;
h_in_b3 = cdfplot(data_b3_in);
set(h_out_b3, 'LineWidth', 2, 'Color', c_south);
set(h_in_b3, 'LineWidth', 2, 'Color', c_indoor, 'LineStyle', '--');
title('教三（混凝土）室内外信号 CDF 对比');
legend('室外 (南)', '室内 (整体)', 'Location', 'NorthWest');
xlabel('信号强度');
grid on;
hold off;

%% --- 第四部分：穿透损耗分析 (图11-12) ---

% 计算所有损耗 (基准：各楼南面均值)
mean_ref_b2 = mean(j2_s);
loss_j2_f2_corr = mean_ref_b2 - mean(j2_f2_corr);
loss_j2_f2_class = mean_ref_b2 - mean(j2_f2_class);
loss_j2_f4_corr = mean_ref_b2 - mean(j2_f4_corr);
loss_j2_f4_class = mean_ref_b2 - mean(j2_f4_class);

mean_ref_b3 = mean(j3_s);
loss_j3_f2_corr = mean_ref_b3 - mean(j3_f2_corr);
loss_j3_f2_class = mean_ref_b3 - mean(j3_f2_class);
loss_j3_f4_corr = mean_ref_b3 - mean(j3_f4_corr);
loss_j3_f4_class = mean_ref_b3 - mean(j3_f4_class);

% 图11: 不同建筑材料穿透损耗对比 (砖混 vs 混凝土)
figure(11);
locations = {'二层走廊', '二层教室', '四层走廊', '四层教室'};
y_j2 = [loss_j2_f2_corr, loss_j2_f2_class, loss_j2_f4_corr, loss_j2_f4_class];
y_j3 = [loss_j3_f2_corr, loss_j3_f2_class, loss_j3_f4_corr, loss_j3_f4_class];
data_fig11 = [y_j2; y_j3]'; 

b11 = bar(data_fig11);
b11(1).FaceColor = c_north; % 砖石 - 蓝色系
b11(2).FaceColor = c_south; % 混凝土 - 红色系
set(gca, 'XTickLabel', locations);
title('不同建筑材料穿透损耗对比');
ylabel('损耗 (dB)');
legend('砖混结构 (教二)', '混凝土结构 (教三)', 'Location', 'NorthWest');
grid on;
% 显示数值
xtips1 = b11(1).XEndPoints; ytips1 = b11(1).YEndPoints; labels1 = string(round(b11(1).YData, 1));
text(xtips1, ytips1, labels1, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
xtips2 = b11(2).XEndPoints; ytips2 = b11(2).YEndPoints; labels2 = string(round(b11(2).YData, 1));
text(xtips2, ytips2, labels2, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');


% 图12: 室内不同深度（走廊vs教室）损耗对比
figure(12);
groups = {'教二 2F', '教二 4F', '教三 2F', '教三 4F'};
y_corr = [loss_j2_f2_corr, loss_j2_f4_corr, loss_j3_f2_corr, loss_j3_f4_corr];
y_class = [loss_j2_f2_class, loss_j2_f4_class, loss_j3_f2_class, loss_j3_f4_class];
data_fig12 = [y_corr; y_class]';

b12 = bar(data_fig12);
b12(1).FaceColor = c_corr;  % 走廊 - 绿色
b12(2).FaceColor = c_class; % 教室 - 黄色
set(gca, 'XTickLabel', groups);
title('室内不同深度损耗对比 (走廊 vs 教室)');
ylabel('损耗 (dB)');
legend('走廊 (一层墙)', '教室 (多层墙/室中室)', 'Location', 'NorthWest');
grid on;
% 显示数值
xtips3 = b12(1).XEndPoints; ytips3 = b12(1).YEndPoints; labels3 = string(round(b12(1).YData, 1));
text(xtips3, ytips3, labels3, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
xtips4 = b12(2).XEndPoints; ytips4 = b12(2).YEndPoints; labels4 = string(round(b12(2).YData, 1));
text(xtips4, ytips4, labels4, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');

disp('所有12幅图像已生成完毕。');
