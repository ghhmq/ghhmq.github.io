function x = select_signal_column(T)
% 从 table 中选择“信号列”；返回列向量
% Pick SIGNAL column from table; return column vector.

vars = T.Properties.VariableNames;
[idxSig, okSig] = listdlg('PromptString','选择信号列 / Select SIGNAL column:', ...
                          'ListString',vars,'SelectionMode','single');
if ~okSig, error('未选择信号列 / No signal column selected.'); end
sigName = vars{idxSig};
x = T.(sigName);
x = x(:);
end
