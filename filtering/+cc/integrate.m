function y = integrate(x, Fs, opts)
% 稳健积分：pre-LP -> pre-HP -> trapz -> post-HP -> detrend
if nargin < 3 || isempty(opts), opts = struct(); end

defs = struct('hpHz_pre',0.2,'lp_pre',[],'hpHz_post',0.05,'detrendDeg',1);
opts = local_merge(defs, opts);

y = x(:);

% 预低通（可选）
if ~isempty(opts.lp_pre)
    Wn = opts.lp_pre/(Fs/2);
    if Wn>0 && Wn<1, [b,a] = butter(4,Wn,'low'); y = filtfilt(b,a,y); end
end
% 预高通
if ~isempty(opts.hpHz_pre) && opts.hpHz_pre>0
    Wn = opts.hpHz_pre/(Fs/2);
    if Wn>0 && Wn<1, [b,a] = butter(2,Wn,'high'); y = filtfilt(b,a,y); end
end
% 积分
y = cumtrapz(y) / Fs;
% 后高通
if ~isempty(opts.hpHz_post) && opts.hpHz_post>0
    Wn = opts.hpHz_post/(Fs/2);
    if Wn>0 && Wn<1, [b,a] = butter(2,Wn,'high'); y = filtfilt(b,a,y); end
end
% 去趋势
if ~isempty(opts.detrendDeg) && opts.detrendDeg >= 0
    y = detrend(y, opts.detrendDeg);
end

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
end
