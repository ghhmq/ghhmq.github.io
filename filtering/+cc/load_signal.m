function [x, Fs_out, usedPath] = load_signal(Fs_default)
% 交互式读取 MAT/CSV/XLSX；只选“信号列”；Fs 固定为 Fs_default
% Interactive loader; pick SIGNAL column only; fixed Fs.

if nargin < 1 || isempty(Fs_default), Fs_default = 32768; end

[fn, fp] = uigetfile({'*.mat;*.csv;*.xlsx','MAT/CSV/XLSX files'}, ...
                     '选择数据文件 / Choose data file');
if isequal(fn,0), error('未选择文件 / No file chosen.'); end
usedPath = fullfile(fp, fn);
[~,~,ext] = fileparts(usedPath);

switch lower(ext)
    case '.mat'
        S = load(usedPath);
        fns = fieldnames(S);
        if isempty(fns), error('MAT 文件为空 / MAT file is empty.'); end
        if numel(fns) == 1
            x = S.(fns{1})(:);
        else
            [idx, ok] = listdlg('PromptString','选择变量 / Select variable:', ...
                                'ListString',fns,'SelectionMode','single');
            if ~ok, error('未选择变量 / No variable selected.'); end
            x = S.(fns{idx})(:);
        end
        Fs_out = Fs_default;

    case '.csv'
        T = readtable(usedPath);
        x = cc.select_signal_column(T);
        Fs_out = Fs_default;

    case '.xlsx'
        T = readtable(usedPath); % 默认第一张 / default first sheet
        x = cc.select_signal_column(T);
        Fs_out = Fs_default;

    otherwise
        error('不支持的格式：%s / Unsupported extension: %s', ext, ext);
end
end
