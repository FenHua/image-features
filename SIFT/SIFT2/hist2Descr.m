function [feat] = hist2Descr(feat,descr,descr_mag_thr)
% 将直方图转换为描述子
descr = descr/norm(descr);
descr = min(descr_mag_thr,descr);
descr = descr/norm(descr);
feat.descr = descr;
end