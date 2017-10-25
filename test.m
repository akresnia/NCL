t = 0:0.001:1;
s = zeros(3,1001);
s(1,:) = sin(2*pi*t*15)+ 0.1*randn(size(t));
%s2 = awgn(sin(2*pi*(t+1)*15),10);
n1 = 0.8*randn(size(t));
s(2,:) = 0.4*sin(2*pi*(t-3)*15+0.5) +n1;
s(3,:) = 0.3*sin(2*pi*(t-4)*15)+0.3*randn(size(t));

%s = [s1;s2;s3];

save('test.mat', 's')