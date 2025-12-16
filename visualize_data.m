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
    % 处理变量名: 移除可能的前缀 Group_ 并将下划线转为空格
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

% === 2. 绘图设置 ===
% 定义颜色 (RGB)
colors_main = [
    0.00, 0.45, 0.74; % 蓝色
    0.85, 0.33, 0.10; % 橙色
    0.54, 0.27, 0.07; % 棕色
    0.49, 0.18, 0.56; % 紫色
    0.47, 0.67, 0.19; % 绿色
    0.30, 0.75, 0.93; % 青色
    0.64, 0.08, 0.18  % 红色
];
% 循环使用颜色
colors_main = repmat(colors_main, ceil(num_groups/size(colors_main,1)), 1);

color_ref = [0.64, 0.08, 0.18]; % 参考线颜色 (深红)
color_text = [0, 0, 0];         % 文本颜色 (黑)

% 创建图形窗口
figure('Name', '详细数据分析报告', 'Color', 'w', 'Position', [50, 50, 1400, 900]);

% === 子图 1: 数据序列折线图 (Time Series / Sequence) ===
subplot(2, 2, 1);
hold on;
grid on;
box on;

% 绘制参考线 (全局平均值)
yline(global_mean, '--', 'Color', color_ref, 'LineWidth', 1.5, 'DisplayName', sprintf('全局均值 (%.2f)', global_mean));

% 绘制各组数据
for i = 1:num_groups
    % 移除 NaN
    current_data = data_matrix(:, i);
    current_data = current_data(~isnan(current_data));
    x_axis = 1:length(current_data);
    
    plot(x_axis, current_data, '-o', ...
        'Color', colors_main(i,:), ...
        'LineWidth', 1.5, ...
        'MarkerSize', 4, ...
        'MarkerFaceColor', colors_main(i,:), ...
        'DisplayName', clean_group_names{i});
end

title('数据序列折线图', 'Color', color_text, 'FontSize', 12, 'FontWeight', 'bold');
xlabel('样本序号', 'Color', color_text);
ylabel('数值', 'Color', color_text);
legend('show', 'Location', 'best', 'TextColor', color_text);
set(gca, 'XColor', color_text, 'YColor', color_text);

% === 子图 2: 统计柱状图 (Bar Chart with Error Bars) ===
subplot(2, 2, 2);
hold on;
grid on;
box on;

% 绘制柱状图
b = bar(1:num_groups, group_means, 0.6);
b.FaceColor = 'flat';
for i = 1:num_groups
    b.CData(i,:) = colors_main(i,:);
end

% 绘制误差线 (标准差)
errorbar(1:num_groups, group_means, group_stds, 'k.', 'LineWidth', 1.5, 'CapSize', 10);

% 标注数值
for i = 1:num_groups
    text(i, group_means(i) + group_stds(i) + 0.1 * max(group_means), ...
        sprintf('%.2f\n(±%.2f)', group_means(i), group_stds(i)), ...
        'HorizontalAlignment', 'center', ...
        'Color', color_text, 'FontSize', 9);
end

title('各组均值与标准差柱状图', 'Color', color_text, 'FontSize', 12, 'FontWeight', 'bold');
xticks(1:num_groups);
xticklabels(clean_group_names);
xtickangle(30);
ylabel('数值', 'Color', color_text);
set(gca, 'XColor', color_text, 'YColor', color_text);

% === 子图 3: 分布拟合图 (Distribution & PDF) ===
subplot(2, 2, 3);
hold on;
grid on;
box on;

for i = 1:num_groups
    current_data = data_matrix(:, i);
    current_data = current_data(~isnan(current_data));
    
    % 绘制直方图 (概率密度)
    h = histogram(current_data, 'Normalization', 'pdf', ...
        'FaceColor', colors_main(i,:), ...
        'FaceAlpha', 0.3, ...
        'EdgeColor', 'none', ...
        'DisplayName', [clean_group_names{i} ' (Hist)']);
    
    % 绘制拟合曲线 (正态分布)
    x_fit = linspace(min(data_matrix(:), [], 'omitnan'), max(data_matrix(:), [], 'omitnan'), 100);
    y_fit = normpdf(x_fit, group_means(i), group_stds(i));
    
    plot(x_fit, y_fit, '--', ...
        'Color', colors_main(i,:), ...
        'LineWidth', 2, ...
        'DisplayName', [clean_group_names{i} ' (Fit)']);
end

title('数据分布与正态拟合图', 'Color', color_text, 'FontSize', 12, 'FontWeight', 'bold');
xlabel('数值区间', 'Color', color_text);
ylabel('概率密度', 'Color', color_text);
% 仅显示拟合曲线的图例，避免太乱
% legend('show', 'Location', 'best'); 
set(gca, 'XColor', color_text, 'YColor', color_text);

% === 子图 4: 详细箱线图 (Box Plot) ===
subplot(2, 2, 4);
hold on;
grid on;
box on;

% 绘制箱线图
% 使用 'Colors' 参数设置箱体颜色比较复杂，这里使用默认黑色线条，但我们可以叠加彩色点
boxplot(data_matrix, 'Labels', clean_group_names, 'Symbol', 'k+', 'Colors', 'k');

% 叠加平均数标记 (绿色菱形)
plot(1:num_groups, group_means, 'd', ...
    'MarkerEdgeColor', 'k', ...
    'MarkerFaceColor', [0.47, 0.67, 0.19], ... % 绿色
    'MarkerSize', 8, ...
    'DisplayName', '平均值');

% 叠加原始数据点 (抖动散点图 Jitter Plot)
for i = 1:num_groups
    current_data = data_matrix(:, i);
    current_data = current_data(~isnan(current_data));
    
    % 生成随机 x 坐标抖动
    x_jitter = i + (rand(size(current_data)) - 0.5) * 0.2;
    
    scatter(x_jitter, current_data, 15, colors_main(i,:), 'filled', 'MarkerFaceAlpha', 0.6);
end

title('数据分布箱线图 (含原始数据点)', 'Color', color_text, 'FontSize', 12, 'FontWeight', 'bold');
ylabel('数值', 'Color', color_text);
xtickangle(30);
set(gca, 'XColor', color_text, 'YColor', color_text);

disp('高级图表绘制完成！');
