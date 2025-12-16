clc; clear; close all;

% === 1. 数据读取与预处理 ===
filename = 'multi_group_data.mat';
if ~exist(filename, 'file')
    error('错误: 找不到文件 %s。请先运行 Python 脚本生成数据。', filename);
end

data_struct = load(filename);
group_names = fieldnames(data_struct);
num_groups = length(group_names);

if num_groups == 0
    error('错误: 数据文件中没有找到任何组数据。');
end

% 找出最大长度并构建矩阵
max_len = 0;
for i = 1:num_groups
    current_data = data_struct.(group_names{i});
    if length(current_data) > max_len
        max_len = length(current_data);
    end
end

data_matrix = nan(max_len, num_groups);
clean_group_names = cell(1, num_groups);

for i = 1:num_groups
    raw_name = group_names{i};
    % 处理变量名
    clean_name = strrep(raw_name, 'Group_', ''); 
    clean_name = strrep(clean_name, '_', ' ');
    clean_group_names{i} = clean_name;
    
    current_data = data_struct.(raw_name);
    current_data = current_data(:);
    len = length(current_data);
    data_matrix(1:len, i) = current_data;
end

% 计算统计量
group_means = mean(data_matrix, 'omitnan');
group_stds = std(data_matrix, 'omitnan');
global_mean = mean(data_matrix(:), 'omitnan');
global_std = std(data_matrix(:), 'omitnan');

% 颜色定义
colors_main = lines(num_groups); % 使用 MATLAB 默认 lines 色图
color_ref = [0.8, 0.2, 0.2]; % 红色参考线
color_fit = [0.2, 0.2, 0.8]; % 蓝色拟合线
color_text = [0, 0, 0];

% =========================================================================
% 第一幅图：特定物理量随序数变化的趋势
% =========================================================================
figure('Name', '图1: 物理量趋势分析', 'Color', 'w', 'Position', [50, 50, 1200, 800]);

% --- 子表1: 折线图 (均值+误差线+线性拟合) ---
subplot(2, 2, 1);
hold on; grid on; box on;
x = 1:num_groups;
errorbar(x, group_means, group_stds, 'ko', 'MarkerFaceColor', 'w', 'LineWidth', 1.2);
% 线性拟合
p = polyfit(x, group_means, 1);
y_fit = polyval(p, x);
plot(x, y_fit, '--', 'Color', color_fit, 'LineWidth', 1.5, 'DisplayName', '线性拟合');
title('各序数点测量均值及趋势', 'Color', color_text);
xlabel('序数点', 'Color', color_text); ylabel('测量值', 'Color', color_text);
xticks(x); xticklabels(clean_group_names);
legend('show', 'Location', 'best');

% --- 子表2: 柱状图 (多组别均值+水平参考线) ---
subplot(2, 2, 2);
hold on; grid on; box on;
b = bar(x, group_means, 0.6);
b.FaceColor = 'flat';
for i = 1:num_groups, b.CData(i,:) = colors_main(i,:); end
yline(global_mean, '--r', 'LineWidth', 1.5, 'DisplayName', '全局均值参考');
title('多位置观测点均值对比', 'Color', color_text);
xticks(x); xticklabels(clean_group_names); xtickangle(30);
ylabel('平均值', 'Color', color_text);
legend('show', 'Location', 'best');

% --- 子表3: 直方图 (大量样本统计分布) ---
subplot(2, 2, 3);
hold on; grid on; box on;
all_data_flat = data_matrix(:);
all_data_flat(isnan(all_data_flat)) = [];
histogram(all_data_flat, 'Normalization', 'pdf', 'FaceColor', [0.5 0.5 0.5], 'EdgeColor', 'none');
title('总体样本统计分布直方图', 'Color', color_text);
xlabel('取值区间', 'Color', color_text); ylabel('频数密度', 'Color', color_text);

% --- 子表4: 箱线图 (多组数据集中趋势与离散程度) ---
subplot(2, 2, 4);
hold on; grid on; box on;
boxplot(data_matrix, 'Labels', clean_group_names, 'Symbol', 'r+');
title('各组数据统计特征箱线图', 'Color', color_text);
ylabel('数值', 'Color', color_text);


% =========================================================================
% 第二幅图：无线信号场强特性分析 (基于实验五理论)
% =========================================================================
figure('Name', '图2: 无线信号场强特性分析', 'Color', 'w', 'Position', [100, 100, 1200, 800]);

% 参数设置 (基于布灵顿模型假设)
ht = 30; % 发射天线高度 (m)
hr = 1.5; % 接收天线高度 (m)
f_MHz = 2400; % 频率 (MHz)
% 假设各组数据对应不同的距离点 (0.1km 到 1km)
sim_dist = linspace(0.1, 1, num_groups); 

% --- 子表1: 路径损耗模型对比 (布灵顿 vs 自由空间) ---
subplot(2, 2, 1);
hold on; grid on; box on;
d_km = linspace(0.01, 1, 100);
% 布灵顿模型 (Bullington): Lp = 116.5 + 40*log10(d) - 20*log10(ht)
L_bullington = 116.5 + 40*log10(d_km) - 20*log10(ht);
% 自由空间模型 (Free Space): Lfs = 32.4 + 20*log10(f) + 20*log10(d)
L_fs = 32.4 + 20*log10(f_MHz) + 20*log10(d_km);

plot(d_km, L_bullington, 'r-', 'LineWidth', 2, 'DisplayName', '布灵顿模型 (40log d)');
plot(d_km, L_fs, 'b--', 'LineWidth', 2, 'DisplayName', '自由空间模型 (20log d)');
title('路径损耗模型理论对比', 'Color', color_text);
xlabel('距离 d (km)', 'Color', color_text);
ylabel('路径损耗 L_p (dB)', 'Color', color_text);
legend('show', 'Location', 'best');
text(0.1, mean(L_bullington), 'L_p = 116.5 + 40log_{10}d - 20log_{10}h_t', 'Color', 'r', 'FontSize', 8);

% --- 子表2: 阴影衰落特性 (Shadow Fading) ---
subplot(2, 2, 2);
hold on; grid on; box on;
% 拟合一条对数衰减曲线作为 "大尺度平均路径损耗"
p_fit = polyfit(log10(sim_dist), group_means, 1);
y_trend = polyval(p_fit, log10(sim_dist));

% 绘制均值趋势 (大尺度衰落)
plot(sim_dist, y_trend, 'k-', 'LineWidth', 2, 'DisplayName', '大尺度平均值 \overline{P_r}(d)');
% 绘制实测数据 (包含阴影衰落)
errorbar(sim_dist, group_means, group_stds, 'bo', 'MarkerFaceColor', 'b', 'DisplayName', '实测值 (含 X_\sigma)');

title('阴影衰落特性分析', 'Color', color_text);
xlabel('距离 (km)', 'Color', color_text);
ylabel('接收功率 (dBm)', 'Color', color_text);
legend('show');
% 标注公式
text(mean(sim_dist), max(group_means)+2, 'P_r(d) = \overline{P_r}(d) + X_\sigma', 'FontSize', 10, 'Color', color_text, 'HorizontalAlignment', 'center');

% --- 子表3: 建筑物穿透损耗 (Building Penetration Loss) ---
subplot(2, 2, 3);
hold on; grid on; box on;
% 选取两组数据分别代表 "室外" 和 "室内" (假设第一组室外，最后一组室内)
idx_out = 1;
idx_in = num_groups;
P_out = data_matrix(:, idx_out); P_out(isnan(P_out)) = [];
P_in = data_matrix(:, idx_in); P_in(isnan(P_in)) = [];
mean_out = mean(P_out);
mean_in = mean(P_in);
delta_P = abs(mean_out - mean_in);

b = bar([1, 2], [mean_out, mean_in], 0.5);
b.FaceColor = 'flat';
b.CData(1,:) = [0.2 0.6 0.8];
b.CData(2,:) = [0.8 0.4 0.2];
xticklabels({'室外 (Outside)', '室内 (Inside)'});
ylabel('平均信号强度 (dBm)', 'Color', color_text);
title('建筑物穿透损耗 \Delta P', 'Color', color_text);
% 标注损耗
h_line = max(mean_out, mean_in) + 5;
plot([1, 2], [h_line, h_line], 'k-', 'LineWidth', 1);
text(1.5, h_line + 2, sprintf('\\Delta P = %.2f dB', delta_P), 'HorizontalAlignment', 'center', 'FontWeight', 'bold');
text(1.5, h_line + 6, '\Delta P = 1/N\Sigma P_{out} - 1/M\Sigma P_{in}', 'HorizontalAlignment', 'center', 'FontSize', 8);

% --- 子表4: 路径损耗指数拟合 (Path Loss Exponent) ---
subplot(2, 2, 4);
hold on; grid on; box on;
% 使用 log-distance 坐标
scatter(log10(sim_dist), group_means, 50, 'filled', 'DisplayName', '实测数据');
plot(log10(sim_dist), y_trend, 'r-', 'LineWidth', 2, 'DisplayName', sprintf('拟合斜率 k = %.2f', p_fit(1)));
title('路径损耗指数 n 拟合', 'Color', color_text);
xlabel('log_{10}(距离)', 'Color', color_text);
ylabel('接收功率 (dBm)', 'Color', color_text);
legend('show', 'Location', 'best');
grid minor;
text(min(log10(sim_dist)), min(group_means), sprintf('n \\approx %.2f', -p_fit(1)/10), 'BackgroundColor', 'w', 'EdgeColor', 'k');


% =========================================================================
% 第三幅图：多维度统计分析
% =========================================================================
figure('Name', '图3: 多维度统计分析', 'Color', 'w', 'Position', [150, 150, 1200, 800]);

% 选取第一组数据作为主要分析对象 (如果数据量太少，拼接所有数据)
if size(data_matrix, 1) > 50
    sample_data = data_matrix(:, 1);
else
    sample_data = data_matrix(:);
end
sample_data(isnan(sample_data)) = [];
sample_mean = mean(sample_data);
sample_std = std(sample_data);

% --- 子表1: 概率密度分布直方图与拟合曲线 ---
subplot(2, 2, 1);
hold on; grid on; box on;
histogram(sample_data, 'Normalization', 'pdf', 'FaceColor', [0.7 0.7 0.7], 'EdgeColor', 'none');
x_range = linspace(min(sample_data), max(sample_data), 100);
y_pdf = normpdf(x_range, sample_mean, sample_std);
plot(x_range, y_pdf, 'r-', 'LineWidth', 2, 'DisplayName', '理论分布模型');
xline(sample_mean, '--k', 'DisplayName', '均值');
xline(sample_mean + sample_std, ':k', 'DisplayName', '+1 Std');
xline(sample_mean - sample_std, ':k', 'DisplayName', '-1 Std');
title('概率密度分布与拟合', 'Color', color_text);
legend('show');

% --- 子表2: 累积分布函数折线图 (CDF) ---
subplot(2, 2, 2);
hold on; grid on; box on;
[f_emp, x_emp] = ecdf(sample_data);
plot(x_emp, f_emp, 'b-', 'LineWidth', 1.5, 'DisplayName', '实测经验分布');
y_cdf = normcdf(x_range, sample_mean, sample_std);
plot(x_range, y_cdf, 'r--', 'LineWidth', 1.5, 'DisplayName', '理论模型分布');
title('累积分布函数对比', 'Color', color_text);
legend('show', 'Location', 'southeast');

% --- 子表3: Q-Q图 (分位数-分位数) ---
subplot(2, 2, 3);
hold on; grid on; box on;
qqplot(sample_data);
title('Q-Q图 (正态性检验)', 'Color', color_text);
% qqplot 自动设置了 title 和 label，这里覆盖一下颜色
set(gca, 'XColor', color_text, 'YColor', color_text);
h = get(gca, 'Children');
% 尝试调整线条样式 (qqplot 返回的句柄结构可能不同，简单处理)

% --- 子表4: 时间序列折线图 (波动与稳定性) ---
subplot(2, 2, 4);
hold on; grid on; box on;
t = 1:length(sample_data);
plot(t, sample_data, 'b-o', 'MarkerSize', 3, 'MarkerFaceColor', 'b', 'DisplayName', '观测序列');
yline(sample_mean, 'r-', 'LineWidth', 1.5, 'DisplayName', '均值');
yregion = [sample_mean - sample_std, sample_mean + sample_std];
% 绘制半透明区域表示 +/- 1 Std
fill([t(1) t(end) t(end) t(1)], [yregion(1) yregion(1) yregion(2) yregion(2)], ...
    'r', 'FaceAlpha', 0.1, 'EdgeColor', 'none', 'DisplayName', '±1 Std 范围');
title('时间序列波动分析', 'Color', color_text);
xlabel('时间/序号', 'Color', color_text); ylabel('观测值', 'Color', color_text);
legend('show');

disp('三幅高级分析图表绘制完成！');
