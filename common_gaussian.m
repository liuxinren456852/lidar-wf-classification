function y = common_gaussian(x, m, e, s, b, a)
% Skewed gaussian curve
% Created by Laky Sandor, BME
	y1 = exp(-abs(((x-e)/s).^b));
	y2 = (atan(a*(x-e))+pi/2)*(1/pi);
	y = y1 .* y2;
	y = y/max(y)*m;
end

