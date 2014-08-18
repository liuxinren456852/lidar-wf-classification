clear all; clc;

figure(1); clf; hold on;

x = 0:0.1:50;

a = 31.0;
b = 16.0;
c = 1.88;
d = 2.22;
e = 2;

%gaussfn = @(x, p) p(1)*exp( -(x-p(2)).^2/(2*p(3).^2) ) + p(4);
gaussfn = @(x, p) p(1)*exp( - ( (x-p(2)) / p(3) ) .^ p(5) ) + p(4);

subplot(2,3,1); hold on;
for ai = 25:2:35,
    plot(x, gaussfn(x, [ai b c d e]), 'r-')
end;
h = title('p_1');
set(h, 'FontSize', 14);
xlabel('X'), ylabel('Y');
set(gca, 'FontSize', 12);
plot(x, gaussfn(x, [a b c d e]), 'b-')

subplot(2,3,2); hold on;
for bi = 14:1:18,
    plot(x, gaussfn(x, [a bi c d e]), 'r-')
end;
h = title('p_2');
set(h, 'FontSize', 14);
xlabel('X'), ylabel('Y');
set(gca, 'FontSize', 12);
plot(x, gaussfn(x, [a b c d e]), 'b-')


subplot(2,3,3); hold on;
for ci = 0.8:0.2:2.5,
    plot(x, gaussfn(x, [a b ci d e]), 'r-')
end;
h = title('p_3');
set(h, 'FontSize', 14);
xlabel('X'), ylabel('Y');
set(gca, 'FontSize', 12);
plot(x, gaussfn(x, [a b c d e]), 'b-')


subplot(2,3,4); hold on;
for di = 1:1:10,
    plot(x, gaussfn(x, [a b c di e]), 'r-')
end;
h = title('p_4');
set(h, 'FontSize', 14);
xlabel('X'), ylabel('Y');
set(gca, 'FontSize', 12);
plot(x, gaussfn(x, [a b c d e]), 'b-')

subplot(2,3,5); hold on;
for ei = 1.8:0.2:2.2,
    plot(x, gaussfn(x, [a b c d ei]), 'r-')
end;
h = title('p_5');
set(h, 'FontSize', 14);
xlabel('X'), ylabel('Y');
set(gca, 'FontSize', 12);
plot(x, gaussfn(x, [a b c d e]), 'b-')
