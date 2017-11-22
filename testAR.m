dt=0.004;
t = 0:dt:4-dt;
N = size(t);
s = zeros(2,length(t));

A1 = [-0.1, -0.27607; 0.38106, -0.26535];
A2 = [0.2,0.15;0.3,-0.5];
s(:,1) = [0.01;-0.02]; %initial values
s(:,2) = A1*s(:,1)+0.01*randn(2,1); %
for n=3:length(t)
    s(:,n) = A1*s(:,n-1)+A2*s(:,n-2)+0.01*randn(2,1); %AR series generated manually
end
save('testAR.mat', 's')

% Mdl1 = arima('Constant',0.05,'AR',{0.6,0.2,-0.1},...
% 	'Variance',0.01);
% Mdl2 = arima('Constant',0.05,'AR',{0.2,0.5,-0.2;0.6,0.2,-0.1},...
% 	'Variance',0.02);
% [Y1,E1] = simulate(Mdl1,1000);
% [Y2,E2] = simulate(Mdl2,1000);
% s = [Y1';Y2'];
%https://www.mathworks.com/help/econ/armairf.html

%s(1,3:end) = A1(1,:)*s(1,2:end-2) + A(1,2)*s(1,1:end-3);

%make_mv_file2
%load('testAR.mat_mout.mat')