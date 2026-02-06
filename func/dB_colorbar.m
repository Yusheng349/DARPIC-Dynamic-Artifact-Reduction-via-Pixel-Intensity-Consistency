function pic_dB = dB_colorbar(pic)
%DB_COLORBAR 此处显示有关此函数的摘要
%   此处显示详细说明
maxElm = max(pic, [], 'all');
a = max(pic, 0) ./ maxElm;
pic_dB = 20 * log10(a);
pic_dB = max(-40, pic_dB);
figure; imshow(pic_dB, [-40, 0]);
colormap('hot');
% colorbar;
end