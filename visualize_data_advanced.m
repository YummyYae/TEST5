clc; clear; close all;

% === 1. 数据读取与预处理 ===
filename = 'data.xlsx';
if ~exist(filename, 'file')
    error('错误: 找不到文件 %s。', filename);
end

% 读取 Excel 文件，保留原始列名
opts = detectImportOptions(filename);
opts.VariableNamingRule = 'preserve';
data_table = readtable(filename, opts);

% 定义预期的变量名映射 (根据用户描述)
% 如果实际变量名不同，请在此处修改
keys.j2_f2_corr = '教二二层走廊';
keys.j2_f4_corr = '教二四层走廊';
keys.j3_f2_corr = '教三二层走廊';
keys.j3_f4_corr = '教三四层走廊';

keys.j2_f2_class = '教二二层教室';
keys.j2_f4_class = '教二四层教室';
keys.j3_f2_class = '教三二层教室';
keys.j3_f4_class = '教三四层教室';

keys.j2_n_ccw = '教二北逆时针';
keys.j2_s_ccw = '教二南逆时针';
keys.j3_n_ccw = '教三北逆时针';
keys.j3_s_ccw = '教三南逆时针';

% 辅助函数：安全获取数据
function data = get_data(tbl, key)
    if ismember(key, tbl.Properties.VariableNames)
        data = tbl{:, key};
        if isnumeric(data)
            data = data(~isnan(data));
        end
        data = double(data(:)); % 转为列向量
    else
        warning('未找到变量: %s，使用空数据代替。', key);
        data = [];
    end
end

% 加载数据
d.j2_f2_corr = get_data(data_table, keys.j2_f2_corr);
d.j2_f4_corr = get_data(data_table, keys.j2_f4_corr);
d.j3_f2_corr = get_data(data_table, keys.j3_f2_corr);
d.j3_f4_corr = get_data(data_table, keys.j3_f4_corr);

d.j2_f2_class = get_data(data_table, keys.j2_f2_class);
d.j2_f4_class = get_data(data_table, keys.j2_f4_class);
d.j3_f2_class = get_data(data_table, keys.j3_f2_class);
d.j3_f4_class = get_data(data_table, keys.j3_f4_class);

d.j2_n_ccw = get_data(data_table, keys.j2_n_ccw);
d.j2_s_ccw = get_data(data_table, keys.j2_s_ccw);
d.j3_n_ccw = get_data(data_table, keys.j3_n_ccw);
d.j3_s_ccw = get_data(data_table, keys.j3_s_ccw);

% 计算均值和标准差
fields = fieldnames(d);
stats = struct();
for i = 1:length(fields)
    fn = fields{i};
    dat = d.(fn);
    if ~isempty(dat)
        stats.(fn).mean = mean(dat, 'omitnan');
        stats.(fn).std = std(dat, 'omitnan');
    else
        stats.(fn).mean = NaN;
        stats.(fn).std = NaN;
    end
end

% 通用绘图设置
set(0, 'DefaultAxesFontSize', 10);
set(0, 'DefaultLineLineWidth', 1.5);

% 定义高对比度且协调的色系 (白底突出)
premium_colors = [
    0.11, 0.39, 0.65; % 1. 宝石蓝 (Sapphire) - 深邃突出
    0.84, 0.35, 0.34; % 2. 珊瑚红 (Coral) - 醒目对比
    0.25, 0.55, 0.35; % 3. 森林绿 (Forest) - 自然协调
    0.91, 0.65, 0.15; % 4. 琥珀黄 (Amber) - 明亮活力
    0.53, 0.42, 0.66; % 5. 紫藤色 (Wisteria) - 优雅补充
    0.20, 0.60, 0.60  % 6. 孔雀蓝 (Teal) - 清新点缀
];

%% === 第一幅图：信号强度趋势展示 ===
figure('Name', '图1: 信号强度趋势展示', 'Color', 'w', 'Position', [100, 100, 1200, 800]);

% --- 子表1: 走廊位置数据 (楼层趋势) ---
subplot(2, 2, 1);
hold on; grid on; box on;
floors = [2, 4];
y_j2 = [stats.j2_f2_corr.mean, stats.j2_f4_corr.mean];
err_j2 = [stats.j2_f2_corr.std, stats.j2_f4_corr.std];
y_j3 = [stats.j3_f2_corr.mean, stats.j3_f4_corr.mean];
err_j3 = [stats.j3_f2_corr.std, stats.j3_f4_corr.std];

errorbar(floors, y_j2, err_j2, '-o', 'DisplayName', '教二', 'Color', premium_colors(1,:), 'MarkerFaceColor', premium_colors(1,:), 'LineWidth', 1.5);
errorbar(floors, y_j3, err_j3, '-s', 'DisplayName', '教三', 'Color', premium_colors(5,:), 'MarkerFaceColor', premium_colors(5,:), 'LineWidth', 1.5);
xticks(floors); xticklabels({'二层', '四层'});
xlabel('楼层'); ylabel('平均信号强度');
title('走廊位置信号强度随楼层变化');
legend('show', 'Location', 'best');

% --- 子表2: 教室位置数据 (楼层趋势) ---
subplot(2, 2, 2);
hold on; grid on; box on;
y_j2_c = [stats.j2_f2_class.mean, stats.j2_f4_class.mean];
err_j2_c = [stats.j2_f2_class.std, stats.j2_f4_class.std];
y_j3_c = [stats.j3_f2_class.mean, stats.j3_f4_class.mean];
err_j3_c = [stats.j3_f2_class.std, stats.j3_f4_class.std];

errorbar(floors, y_j2_c, err_j2_c, '-o', 'DisplayName', '教二', 'Color', premium_colors(1,:), 'MarkerFaceColor', premium_colors(1,:), 'LineWidth', 1.5);
errorbar(floors, y_j3_c, err_j3_c, '-s', 'DisplayName', '教三', 'Color', premium_colors(5,:), 'MarkerFaceColor', premium_colors(5,:), 'LineWidth', 1.5);
xticks(floors); xticklabels({'二层', '四层'});
xlabel('楼层'); ylabel('平均信号强度');
title('教室位置信号强度随楼层变化');
legend('show', 'Location', 'best');

% --- 子表3: 外围逆时针路径 (空间变化) ---
subplot(2, 2, 3);
hold on; grid on; box on;
% 为了在同一张图显示，假设横轴是归一化的路径点或直接按顺序绘制
plot(d.j2_n_ccw, 'DisplayName', '教二北', 'Color', premium_colors(1,:), 'LineWidth', 1.5);
plot(d.j2_s_ccw, 'DisplayName', '教二南', 'Color', premium_colors(2,:), 'LineWidth', 1.5);
plot(d.j3_n_ccw, 'DisplayName', '教三北', 'Color', premium_colors(5,:), 'LineWidth', 1.5);
plot(d.j3_s_ccw, 'DisplayName', '教三南', 'Color', premium_colors(6,:), 'LineWidth', 1.5);
xlabel('路径点顺序'); ylabel('信号强度');
title('外围逆时针路径信号空间变化');
legend('show', 'Location', 'best');

% --- 子表4: 综合对比 (宏观序列) ---
subplot(2, 2, 4);
hold on; grid on; box on;
% 定义所有分组的顺序
all_groups_labels = {'教二走廊2F', '教二走廊4F', '教三走廊2F', '教三走廊4F', ...
                     '教二教室2F', '教二教室4F', '教三教室2F', '教三教室4F', ...
                     '教二北', '教二南', '教三北', '教三南'};
all_groups_means = [stats.j2_f2_corr.mean, stats.j2_f4_corr.mean, stats.j3_f2_corr.mean, stats.j3_f4_corr.mean, ...
                    stats.j2_f2_class.mean, stats.j2_f4_class.mean, stats.j3_f2_class.mean, stats.j3_f4_class.mean, ...
                    stats.j2_n_ccw.mean, stats.j2_s_ccw.mean, stats.j3_n_ccw.mean, stats.j3_s_ccw.mean];
plot(1:length(all_groups_means), all_groups_means, '-o', 'LineWidth', 2, 'Color', premium_colors(3,:), 'MarkerFaceColor', premium_colors(3,:));
xticks(1:length(all_groups_means));
xticklabels(all_groups_labels);
xtickangle(45);
ylabel('平均信号强度');
title('所有测量环境信号水平宏观对比');


%% === 第二幅图：不同场景直观对比 ===
figure('Name', '图2: 场景直观对比', 'Color', 'w', 'Position', [150, 150, 1200, 800]);

% --- 子表1: 教二建筑内部对比 ---
subplot(2, 2, 1);
hold on; grid on; box on;
j2_labels = {'教二北逆', '教二南逆', '二层走廊', '四层走廊', '二层教室', '四层教室'};
j2_vals = [stats.j2_n_ccw.mean, stats.j2_s_ccw.mean, stats.j2_f2_corr.mean, ...
           stats.j2_f4_corr.mean, stats.j2_f2_class.mean, stats.j2_f4_class.mean];
b1 = bar(j2_vals);
b1.FaceColor = 'flat';
b1.CData = premium_colors;
xticks(1:length(j2_labels)); xticklabels(j2_labels); xtickangle(30);
ylabel('信号强度');
title('教二建筑内部各位置对比');

% --- 子表2: 教三建筑内部对比 ---
subplot(2, 2, 2);
hold on; grid on; box on;
j3_labels = {'教三北逆', '教三南逆', '二层走廊', '四层走廊', '二层教室', '四层教室'};
j3_vals = [stats.j3_n_ccw.mean, stats.j3_s_ccw.mean, stats.j3_f2_corr.mean, ...
           stats.j3_f4_corr.mean, stats.j3_f2_class.mean, stats.j3_f4_class.mean];
b2 = bar(j3_vals);
b2.FaceColor = 'flat';
b2.CData = premium_colors;
xticks(1:length(j3_labels)); xticklabels(j3_labels); xtickangle(30);
ylabel('信号强度');
title('教三建筑内部各位置对比');

% --- 子表3: 跨建筑同类位置对比 ---
subplot(2, 2, 3);
hold on; grid on; box on;
cross_labels = {'二层走廊', '四层走廊', '二层教室', '四层教室'};
cross_vals = [stats.j2_f2_corr.mean, stats.j3_f2_corr.mean;
              stats.j2_f4_corr.mean, stats.j3_f4_corr.mean;
              stats.j2_f2_class.mean, stats.j3_f2_class.mean;
              stats.j2_f4_class.mean, stats.j3_f4_class.mean];
b3 = bar(cross_vals);
% 设置分组柱状图颜色 (教二 vs 教三)
b3(1).FaceColor = premium_colors(1,:);
b3(2).FaceColor = premium_colors(5,:);
legend({'教二', '教三'}, 'Location', 'best');
xticks(1:length(cross_labels)); xticklabels(cross_labels);
ylabel('信号强度');
title('跨建筑同类位置信号对比');

% --- 子表4: 关键衍生指标 (损耗) ---
subplot(2, 2, 4);
hold on; grid on; box on;
% 计算穿透损耗 (走廊 - 教室)
loss_pen_j2_f2 = stats.j2_f2_corr.mean - stats.j2_f2_class.mean;
loss_pen_j2_f4 = stats.j2_f4_corr.mean - stats.j2_f4_class.mean;
loss_pen_j3_f2 = stats.j3_f2_corr.mean - stats.j3_f2_class.mean;
loss_pen_j3_f4 = stats.j3_f4_corr.mean - stats.j3_f4_class.mean;

% 计算路径损耗差值 (外围 - 室内平均)
% 这里简单取外围均值 - 室内所有均值
mean_outer_j2 = mean([stats.j2_n_ccw.mean, stats.j2_s_ccw.mean]);
mean_inner_j2 = mean([stats.j2_f2_corr.mean, stats.j2_f4_corr.mean, stats.j2_f2_class.mean, stats.j2_f4_class.mean]);
diff_path_j2 = mean_outer_j2 - mean_inner_j2;

mean_outer_j3 = mean([stats.j3_n_ccw.mean, stats.j3_s_ccw.mean]);
mean_inner_j3 = mean([stats.j3_f2_corr.mean, stats.j3_f4_corr.mean, stats.j3_f2_class.mean, stats.j3_f4_class.mean]);
diff_path_j3 = mean_outer_j3 - mean_inner_j3;

loss_labels = {'J2 F2穿透', 'J2 F4穿透', 'J3 F2穿透', 'J3 F4穿透', 'J2 内外差', 'J3 内外差'};
loss_vals = [loss_pen_j2_f2, loss_pen_j2_f4, loss_pen_j3_f2, loss_pen_j3_f4, diff_path_j2, diff_path_j3];

b4 = bar(loss_vals);
b4.FaceColor = 'flat';
b4.CData = premium_colors;
xticks(1:length(loss_labels)); xticklabels(loss_labels); xtickangle(30);
ylabel('损耗/差值 (dB)');
title('关键衍生指标计算结果');


%% === 第三幅图：数据统计分布特性 ===
figure('Name', '图3: 统计分布特性分析', 'Color', 'w', 'Position', [200, 200, 1200, 800]);

% 聚合数据用于统计 (例如所有教室数据)
agg_data = [d.j2_f2_class; d.j2_f4_class; d.j3_f2_class; d.j3_f4_class];
agg_data(isnan(agg_data)) = [];
agg_mean = mean(agg_data);
agg_std = std(agg_data);

% --- 子表1: 概率密度分布直方图与拟合 ---
subplot(2, 2, 1);
hold on; grid on; box on;
histogram(agg_data, 'Normalization', 'pdf', 'DisplayName', '实测分布', 'FaceColor', premium_colors(2,:), 'EdgeColor', 'none');
x_range = linspace(min(agg_data), max(agg_data), 100);
% 手动实现 normpdf: (1/(sigma*sqrt(2*pi))) * exp(-0.5*((x-mu)/sigma)^2)
y_norm = (1 / (agg_std * sqrt(2 * pi))) * exp(-0.5 * ((x_range - agg_mean) / agg_std).^2);
plot(x_range, y_norm, '-', 'Color', premium_colors(5,:), 'LineWidth', 2, 'DisplayName', '正态拟合');
xline(agg_mean, '--', 'Color', [0.2 0.2 0.2], 'LineWidth', 1.5, 'DisplayName', '均值');
title('聚合数据集(教室)概率密度分布');
xlabel('信号强度'); ylabel('概率密度');
legend('show');

% --- 子表2: 累积分布函数图 (CDF) ---
subplot(2, 2, 2);
hold on; grid on; box on;
% 手动实现 cdfplot (经验累积分布)
sorted_agg = sort(agg_data);
n_agg = length(agg_data);
y_emp = (1:n_agg) / n_agg;
plot(sorted_agg, y_emp, 'Color', premium_colors(1,:), 'LineWidth', 2, 'DisplayName', '实测CDF');

% 手动实现 normcdf: 0.5 * (1 + erf((x-mu)/(sigma*sqrt(2))))
y_cdf = 0.5 * (1 + erf((x_range - agg_mean) / (agg_std * sqrt(2))));
plot(x_range, y_cdf, '--', 'Color', premium_colors(5,:), 'LineWidth', 2, 'DisplayName', '理论正态CDF');
title('累积分布函数对比');
xlabel('信号强度'); ylabel('累积概率');
legend('show', 'Location', 'best');

% --- 子表3: Q-Q 图 (以教二二层走廊为例) ---
subplot(2, 2, 3);
hold on; grid on; box on;
test_data = d.j2_f2_corr;
test_data(isnan(test_data)) = [];
% 手动实现 Q-Q 图
sorted_test = sort(test_data);
n_test = length(test_data);
% 计算百分位
p_vals = ((1:n_test) - 0.5) / n_test;
% 标准正态分布的分位数 (使用 erfinv)
theoretical_q = sqrt(2) * erfinv(2 * p_vals - 1);
plot(theoretical_q, sorted_test, '+', 'Color', premium_colors(1,:), 'DisplayName', '数据点');
% 添加参考线 (y = sigma*x + mu)
ref_x = linspace(min(theoretical_q), max(theoretical_q), 100);
ref_y = std(test_data) * ref_x + mean(test_data);
plot(ref_x, ref_y, '--', 'Color', premium_colors(5,:), 'LineWidth', 1.5, 'DisplayName', '参考线');

title('Q-Q 图 (教二二层走廊)');
xlabel('标准正态分位数'); ylabel('输入数据分位数');
legend('show', 'Location', 'best');

% --- 子表4: 时间/空间序列折线图 (外围路径) ---
subplot(2, 2, 4);
hold on; grid on; box on;
% 绘制几条路径的原始波动
plot(d.j2_n_ccw, 'Color', premium_colors(1,:), 'DisplayName', '教二北');
yline(stats.j2_n_ccw.mean, '--', 'Color', premium_colors(1,:), 'HandleVisibility', 'off');

plot(d.j2_s_ccw, 'Color', premium_colors(2,:), 'DisplayName', '教二南');
yline(stats.j2_s_ccw.mean, '--', 'Color', premium_colors(2,:), 'HandleVisibility', 'off');

xlabel('测量点顺序'); ylabel('信号强度');
title('外围路径信号序列波动');
legend('show');
