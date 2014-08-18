clear all;

figure(1); clf; hold on;

load('trans_waveform_test')

from = 100; to = 150;

for i = from : to,
    plot(1:size(sum_samples, 2), sum_samples(i,:), 'g-');
end;

wsamp = trans_waveform(sum_samples, -1)

for i = from : to,
    plot(1:size(sum_samples, 2), wsamp(i,:), 'r-');
end

