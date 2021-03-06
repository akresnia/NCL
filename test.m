 dt=0.004;  
 t = 0:dt:4-dt;  
 N = size(t);
% s = zeros(2,length(t));
% 
% n1 = 0.05*randn(N);     n2 = 0.05*randn(N);
% source1 = @(t) sin(2*pi*t*5);
% source2 = @(t) sin(2*pi*t*81)+n2;
% s(1,:) = 1.7*source1(t); 
% s(2,:) = 0.7*source1(t) + source2(t) + 0.05*randn(N); 
% plot(s')
n1 = 0.05*randn(N);
source = @(t) sin(2*pi*t*4);
s(1,:) = source(t);
s(2,:) =(0.6*source(t+1*dt)+0.601) .* (0.4*sin(2*pi*(t)*13) + 0.1*randn(N));
s(3,:) = (0.6*source(t+2*dt)+0.601) .* (0.4*sin(2*pi*(t)*17) + 0.1*randn(N));
s(4,:) = (0.6*source(t+3*dt)+0.601) .* (0.4*sin(2*pi*(t)*23) + 0.1*randn(N));


save('test.mat', 's')

% t=0:0.002:10;
% s = zeros(2,length(t));
% s(1,:)=1.7*sin(2*pi*5*t);
% s(2,:)=sin(2*pi*81*t);
% s(2,2:end)=s(2,2:end)+0.7*s(1,1:end-1);
% s(2,:)=s(2,:)+0.1*randn(1,length(t));
% save('test.mat', 's')
%   
%s(4,:) = 0.2.*randn(N);
%s(4,:) = 0.7*source1(t-2)+0.4*source2(t-3) + 0.05*randn(N); 
%f1= 17.*ones(N)+0.1*randn(N);
%f2 = 25.*ones(N)+0.5*cos(2*pi*t*0.5)+0.05*randn(N);
%f3 = -2*t+43*ones(N);

% 
%A2 = 0.5*(1.5-real(exp(2*pi*1j*t*0.2)));
%f3 = real(A2.*exp(2*pi*1j*t*3.4))+43*ones(N);

%s(1,:) = 0.5*sin(2*pi*t*3)+1.01+ 0.05*randn(N);
%s(2,:) =(0.3*s(1,:)).*(sin(2*pi*(t)*23)) + 0.01*randn(N);
%s(3,:) =(0.5*s(1,:)).*(sin(2*pi*(t)*29)) + 0.01*randn(N);
%s(4,:) =(0.7*s(1,:)).*(sin(2*pi*(t)*35)) + 0.01*randn(N);
% 
% s(1,:) = 0.5*sin(2*pi*t*3);%+ 0.01*randn(N);
% s(2,:) =[0.5,(0.501+0.5*s(1,2:end))].*(0.4*sin(2*pi*(t).*17)) + 0.1*randn(N);
% s(3,:) =[0.5,0.5,(0.501+0.5*s(1,3:end))].*(0.5*sin(2*pi*(t).*25)) + 0.1*randn(N);
% s(4,:) =(0.501+0.5*s(1)).*(0.4*sin(2*pi*(t).*43)) + 0.1*randn(N);
% % s(3,:) =0.5*[s(1,1:2000) zeros(1,2000)]+ 0.4*sin(2*pi*(t+0.002)*29) + 0.1*randn(N);
% % s(4,:) =0.6*[zeros(1,1999) s(1,2000:end)]+ 0.4*sin(2*pi*(t+0.001)*35) + 0.1*randn(N);
% %s(5,:) = 0.1*randn(N);
% %s(6,:) = cos(2*pi*t*50)+0.1*randn(N);
% %s(7,:) = cos(2*pi*t*60)+0.1*randn(N);
% 

%adftest(X)
%spectrogram(s(2,:),50,25,50,250,'yaxis')