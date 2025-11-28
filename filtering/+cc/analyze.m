function R = analyze(x, Fs, cfg)
% 预处理 + FFT + 峰谷检测（兼容省略 cfg）
if nargin < 3 || isempty(cfg), cfg = struct(); end

% 默认与合并 / defaults merge
defs = struct('doDetrend',true,'notchHz',[],'lowpassHz',[], ...
              'hannWindow',true,'zeroPadFactor',1, ...
              'minPeakProminence',0.1,'minPeakDistanceSec',[]);
cfg = local_merge(defs, cfg);
if ~isfield(cfg,'zeroPadFactor') || isempty(cfg.zeroPadFactor) || cfg.zeroPadFactor<1
    cfg.zeroPadFactor = 1;
end

xRaw = x(:);
N = numel(xRaw);
t = (0:N-1).' / Fs;

% 去非有限值 / remove non-finite
mask = isfinite(xRaw);
if ~all(mask)
    warning('非有限值已移除：%d/%d 保留 / Non-finite removed: %d/%d kept.', nnz(mask), N);
    xRaw = xRaw(mask); t = t(mask); N = numel(xRaw);
end

% 去趋势 / detrend
xProc = xRaw;
if cfg.doDetrend, xProc = detrend(xProc); end

% 陷波 / notch
if ~isempty(cfg.notchHz)
    f0 = cfg.notchHz / (Fs/2);
    bw = min(0.01, f0*0.05);
    if f0>0 && f0<1, [b,a] = iirnotch(f0, bw); xProc = filtfilt(b,a,xProc); end
end

% 低通 / low-pass
if ~isempty(cfg.lowpassHz)
    Wn = cfg.lowpassHz/(Fs/2);
    if Wn>0 && Wn<1, [b,a] = butter(4,Wn,'low'); xProc = filtfilt(b,a,xProc); end
end

% FFT
w  = cfg.hannWindow * hann(N) + (~cfg.hannWindow)*ones(N,1);
xw = xProc .* w;
M  = 2^nextpow2(round(N*cfg.zeroPadFactor));
Y  = fft(xw, M);
P2 = abs(Y/M);
P1 = P2(1:floor(M/2)+1);
P1(2:end-1) = 2*P1(2:end-1);
f  = (0:floor(M/2)).' * (Fs/M);

% 主频 / dominant frequency
if numel(P1) > 1
    [~, idxMax] = max(P1(2:end)); idxMax = idxMax + 1;
    domFreqHz = f(idxMax);
else
    domFreqHz = 0;
end
domPeriodSec = tern(domFreqHz>0, 1/domFreqHz, Inf);

% 峰谷 / peaks & valleys
if isempty(cfg.minPeakDistanceSec)
    if isfinite(domPeriodSec) && domFreqHz>0
        minDist = max(1, round(0.6*domPeriodSec*Fs));
    else
        minDist = max(1, round(0.01*Fs));
    end
else
    minDist = max(1, round(cfg.minPeakDistanceSec*Fs));
end
[peaks, peakLocs]     = findpeaks(xProc,'MinPeakProminence',cfg.minPeakProminence,'MinPeakDistance',minDist);
[valleys, valleyLocs] = findpeaks(-xProc,'MinPeakProminence',cfg.minPeakProminence,'MinPeakDistance',minDist);
valleys = -valleys;

% 平均波长 / mean wavelength
if numel(peakLocs)>=2
    dSamp = diff(peakLocs);
    wavelengthSamples = mean(dSamp);
    wavelengthSec = wavelengthSamples/Fs;
else
    wavelengthSamples = NaN; wavelengthSec = NaN;
end

% 输出 / pack
R = struct();
R.Fs = Fs; R.N = N;
R.durationSec = (N-1)/Fs;
R.time = t; R.xRaw = xRaw; R.xProc = xProc;
R.f = f; R.P1 = P1;
R.domFreqHz = domFreqHz; R.domPeriodSec = domPeriodSec;
R.peaks = peaks; R.peakLocs = peakLocs;
R.valleys = valleys; R.valleyLocs = valleyLocs;
R.wavelengthSamples = wavelengthSamples; R.wavelengthSec = wavelengthSec;

R.exportSummary = struct( ...
    'Fs_Hz', Fs, ...
    'N_samples', N, ...
    'Duration_s', R.durationSec, ...
    'DominantFreq_Hz', domFreqHz, ...
    'DominantPeriod_s', domPeriodSec, ...
    'MeanWavelength_samples', wavelengthSamples, ...
    'MeanWavelength_s', wavelengthSec, ...
    'NumPeaks', numel(peakLocs), ...
    'NumValleys', numel(valleyLocs) ...
    );

% helpers
function s = local_merge(defs, user)
    s = defs;
    if ~isstruct(user), return; end
    f = fieldnames(user);
    for i = 1:numel(f)
        if isfield(user,f{i}) && ~isempty(user.(f{i}))
            s.(f{i}) = user.(f{i});
        end
    end
end
function out = tern(cond, a, b)
    if cond, out = a; else, out = b; end
end
end
