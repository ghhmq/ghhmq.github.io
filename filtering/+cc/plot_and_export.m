function plot_and_export(R, I, exportDir, intOpts)
% 绘图与导出（PNG/CSV/Summary）
if ~exist(exportDir,'dir'), mkdir(exportDir); end

% 波形 + 峰谷
f1 = figure('Name','Waveform with Peaks/Valleys','Color','w');
plot(R.time, R.xProc, 'LineWidth', 1); hold on; grid on;
plot(R.time(R.peakLocs),   R.peaks,   'r*', 'MarkerSize', 6);
plot(R.time(R.valleyLocs), R.valleys, 'g*', 'MarkerSize', 6);
xlabel('Time (s)'); ylabel('Amplitude');
title('Processed Signal with Peaks/Valleys');
legend('Signal','Peaks','Valleys','Location','best');
saveas(f1, fullfile(exportDir,'waveform_peaks.png'));

% 单边幅度谱
f2 = figure('Name','Single-Sided Amplitude Spectrum','Color','w');
plot(R.f, R.P1, 'LineWidth', 1); grid on;
xlabel('Frequency (Hz)'); ylabel('Amplitude');
title(sprintf('Spectrum (dominant = %.4f Hz, period = %.6f s)', R.domFreqHz, R.domPeriodSec));
xlim([0 max(R.f)]);
saveas(f2, fullfile(exportDir,'spectrum.png'));

% 积分曲线
f3 = figure('Name','Integrated (drift-suppressed)','Color','w');
plot(R.time, I, 'LineWidth', 1); grid on;
xlabel('Time (s)'); ylabel('Integrated value');
title('Integrated Signal (drift-suppressed)');
saveas(f3, fullfile(exportDir,'integrated.png'));

% CSV 导出
writetable(table(R.f, R.P1, 'VariableNames',{'freq_Hz','amp'}), ...
    fullfile(exportDir,'spectrum.csv'));
writetable(table(R.peakLocs, R.time(R.peakLocs), R.peaks, ...
    'VariableNames',{'idx','time_s','amp'}), fullfile(exportDir,'peaks.csv'));
writetable(table(R.valleyLocs, R.time(R.valleyLocs), R.valleys, ...
    'VariableNames',{'idx','time_s','amp'}), fullfile(exportDir,'valleys.csv'));
writematrix([R.time I], fullfile(exportDir,'integrated.csv'));

% 摘要
summaryT = struct2table(R.exportSummary);
summaryT.int_hp_pre_Hz  = intOpts.hpHz_pre;
summaryT.int_hp_post_Hz = intOpts.hpHz_post;
summaryT.int_detrendDeg = intOpts.detrendDeg;
writetable(summaryT, fullfile(exportDir,'summary.csv'));
end
