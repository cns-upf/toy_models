close all
clc

T = 20; % number of observed time samples
vT = (1:T)'; % vector of time stamps
n_sub = 20; % number of subjects (repetitions of the same experience)

% normal distribution (white noise with unit variance, no temporal correlations)
ts_rand = randn(T,n_sub);

% generation of time series with underlying modulation
a = 0.2; % amplitude of modulation
f = 0.2; % frequency of modulation
v_mod = a * sin(vT*f*2*pi);
ts_mod = v_mod*ones(1,n_sub) + randn(T,n_sub);

% plot time series
figure;
subplot(211); hold on;
plot(vT,ts_mod,'color','r')
plot(vT,v_mod,'color',[0.5,0,0],'linestyle','--')
subplot(212);
plot(vT,ts_rand,'color','k')
xlabel('time')


% plot standard error of the mean (over subjects)
figure;
subplot(211);
errorbar(vT,mean(ts_mod,2),std(ts_mod,0,2)/sqrt(n_sub),'r')
subplot(212)
errorbar(vT,mean(ts_rand,2),std(ts_rand,0,2)/sqrt(n_sub),'k')
xlabel('time')


% average power spectrum over subjects

freq = 1.*(0:T/2)'/T; % frequency range

pws_rand = abs(fft(ts_rand,[],1)).^2;
pws_rand = pws_rand(1:1+T/2,:);

pws_mod = abs(fft(ts_mod,[],1)).^2;
pws_mod = pws_mod(1:1+T/2,:);

figure; hold on;
errorbar(freq,mean(pws_mod,2),std(pws_mod,0,2)/sqrt(n_sub),'r');
errorbar(freq,mean(pws_rand,2),std(pws_rand,0,2)/sqrt(n_sub),'k');
xlabel('frequency')
ylabel('spectral power')
title('average power spectrum over subjects')


% power spectrum of averaged time series (over subjects)

pws_av_rand = abs(fft(mean(ts_rand,2),[],1)).^2;
pws_av_rand = pws_av_rand(1:1+T/2);

pws_av_mod = abs(fft(mean(ts_mod,2),[],1)).^2;
pws_av_mod = pws_av_mod(1:1+T/2);


figure; hold on;
plot(freq,pws_av_mod,'color','r');
plot(freq,pws_av_rand,'color','k');
xlabel('frequency');
ylabel('spectral power');
title('power spectrum of averaged time series');


% surrogate time series

n_shuf = 200;
ts_rand_shuf = zeros(T,n_sub,n_shuf);
ts_mod_shuf = zeros(T,n_sub,n_shuf);

for i_shuf=1:n_shuf
    % random permutations of each time series 
    for i_sub=1:n_sub
        ts_rand_shuf(:,i_sub,i_shuf) = ts_rand(randperm(T),i_sub);
        ts_mod_shuf(:,i_sub,i_shuf) = ts_mod(randperm(T),i_sub);
    end
end

% significance test for power spectrum

pws_av_rand_shuf = abs(fft(squeeze(mean(ts_rand_shuf,2)),[],1)).^2;
pws_av_rand_shuf = pws_av_rand_shuf(1:1+T/2,:);
pws_av_rand_shuf = sort(pws_av_rand_shuf,2); % sort the distribution of surrogate values (for each frequency)

pws_av_mod_shuf = abs(fft(squeeze(mean(ts_mod_shuf,2)),[],1)).^2;
pws_av_mod_shuf = pws_av_mod_shuf(1:1+T/2,:);
pws_av_mod_shuf = sort(pws_av_mod_shuf,2); % sort the distribution of surrogate values (for each frequency)


pval = 0.05; % desired p-value threshold,
n_comp = 9;

figure; hold on;
plot(freq,pws_av_mod_shuf(:,n_shuf-floor(pval*n_shuf)+1),'--','color',[0.5,0,0]);
plot(freq,pws_av_rand_shuf(:,n_shuf-floor(pval*n_shuf)+1),'--','color','k');
plot(freq,pws_av_mod,'color','r');
plot(freq,pws_av_rand,'color','k');
xlabel('frequency');
ylabel('spectral power');
title('statistical significance for p<0.05');


figure; hold on;
plot(freq,pws_av_mod_shuf(:,n_shuf-floor(pval*n_shuf/n_comp)+1),'--','color',[0.5,0,0]);
plot(freq,pws_av_rand_shuf(:,n_shuf-floor(pval*n_shuf/n_comp)+1),'--','color','k');
plot(freq,pws_av_mod,'color','r');
plot(freq,pws_av_rand,'color','k');
xlabel('frequency');
ylabel('spectral power');
title('Bonferroni correction for p<0.05 with 9 tests');


i_f = 5; % index of frequency for histogram
figure; hold on;
hist(pws_av_mod_shuf(i_f,:));
lim_tmp = pws_av_mod_shuf(i_f,n_shuf-floor(pval*n_shuf));
plot([lim_tmp,lim_tmp],[0,100],':r')
plot(pws_av_mod(i_f),10,'xr')
xlabel('spectral power');
ylabel('surrogate count');
title('histogram');

