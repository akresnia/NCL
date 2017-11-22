t = 0:0.001:4-0.001;
s = zeros(7,length(t));
N = size(t);
s(1,:) = sin(2*pi*t*3)+ 0.05*randn(N);
%s(1,2001:end) = 2.*ones(1,2001)';
s(2,:) =0.3*s(1,:)+ 0.5*sin(2*pi*(t)*13) + 0.1*randn(N);
s(3,:) =0.5*[s(1,1:floor(N(2)/2)) zeros(1,floor(N(2)/2))]+ 0.2*sin(2*pi*(t)*19) + 0.1*randn(N);
s(4,:) =0.6*[zeros(1,floor(N(2)/2)) s(1,floor(N(2)/2+1):end)]+ 0.4*sin(2*pi*(t)*25) + 0.1*randn(N);
s(5,:) = 0.4*randn(N);
s(6,:) = 0.3*randn(N);
s(7,:) = 0.3*randn(N);
noise_0 = zeros(7, length(t));
noise_1 = 0.01*randn(7,length(t));
noise_2 = 0.015*randn(7,length(t));
noise_3 = 0.005*randn(7,length(t));

noise = cat(3,noise_0, noise_1, noise_2, noise_3,...
    noise_0, noise_1, noise_2, noise_3, noise_1, noise_2);
s = cat(3,s,s,s,s,s,s,s,s,s,s);
s = s+noise;

for ch=1:7
    for tr=1:size(s,3)
        s(ch,:,tr) = s(ch,:,tr)/std(s(ch, :,tr));
    end
end


save('test_multitrial.mat', 's')
%adftest(X)