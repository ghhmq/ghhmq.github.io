function C = config()
% 统一配置 / Centralized configuration (CN/EN)

% 输出目录 / Output dir
C.exportDir = "results";

% ********** 在这里修改采样率（固定 Fs）/ CHANGE FIXED SAMPLING RATE HERE **********
C.Fs_default = 32768;  % Fixed sampling rate (Δt = 1/Fs)
% *******************************************************************************

% 分析配置 / Analysis cfg
cfg = struct();
cfg.doDetrend          = true;   % 去趋势 / detrend
cfg.notchHz            = [];     % 工频陷波 50/60Hz；[]关闭 / power-line notch
cfg.lowpassHz          = [];     % 低通截止Hz；[]关闭 / low-pass cutoff
cfg.hannWindow         = true;   % FFT 使用 Hann 窗 / Hann window for FFT
cfg.zeroPadFactor      = 1;      % 零填充倍数 / zero-padding factor
cfg.minPeakProminence  = 0.3;    % 峰显著性 / min peak prominence
cfg.minPeakDistanceSec = [];     % 峰最小间隔秒；[]按主周期估计 / []=auto by period
C.cfg = cfg;

% 积分选项 / Integration options
intOpts = struct( ...
    'hpHz_pre',   0.2, ...  % 积分前高通 / high-pass before integration
    'lp_pre',     [],  ...  % 积分前低通 / optional low-pass
    'hpHz_post',  0.05, ... % 积分后高通 / high-pass after integration
    'detrendDeg', 1 ...     % 多项式去趋势阶数 / polynomial detrend order
);
C.intOpts = intOpts;
end
