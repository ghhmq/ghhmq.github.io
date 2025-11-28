%% Analyze Port 1 Signal — Modular (Fixed Fs, CN/EN)
% CN: 弹窗选文件 -> 选择信号列 -> 固定 Fs -> 预处理/FFT/峰谷 -> 积分 -> 绘图与导出
% EN: File dialog -> pick SIGNAL column -> fixed Fs -> preprocess/FFT/peaks -> integrate -> plot & export

clear; clc; clear functions;

% 载入统一配置（在这里改采样率/输出目录等） / Centralized config
C = cc.config();   % C.Fs_default, C.cfg, C.intOpts, C.exportDir

% 读入数据（固定 Fs，不再依赖时间列） / Load data (fixed Fs)
[x, Fs, srcPath] = cc.load_signal(C.Fs_default);
fprintf('[INFO] Loaded: %s | Fs = %.6f Hz (fixed)\n', srcPath, Fs);

% 分析：预处理 + FFT + 峰谷 / Analyze
R = cc.analyze(x, Fs, C.cfg);

% 积分（抑制漂移） / Integrate (drift-suppressed)
I = cc.integrate(R.xProc, R.Fs, C.intOpts);

% 绘图与导出 / Plot & export
cc.plot_and_export(R, I, C.exportDir, C.intOpts);

fprintf('[DONE] Results saved to "%s".\n', C.exportDir);
