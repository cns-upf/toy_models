clear all;
clc

% network and simulation parameters

n_net = 4; % number of network configurations to simulate
N = 4; % number of nodes in network

tau_x = 1; % leakage time constant (common to all nodes)
C = zeros(N,N,n_net); % connectivity matrices
Sigma = zeros(N,N,n_net); % input covariance matrices


T = 1000; % duration of simulation
T0 = 100; % initialization time for network dynamics

dt = 0.05; % temporal resolution for simulation

nT = floor(T/dt); % simulation timesteps
nT0 = floor(T0/dt); % simulation timesteps to ignore (due to initial condition)

n_sampl = floor(1./dt); % sampling to get 1 point every second
nTs = floor(T); % number of simulated time points after subsampling


% original network configurations, where C[i,j] is the weight from node j to node i

% 1 C symmetric and Sigma homogeneous
% 2 C symmetric and Sigma heterogeneous
% 3 C directed and Sigma heterogeneous
% 4 same as 3 with non-Gaussian observation noise

% config 3 with 2 loops
C(2,1,3) = 1;
C(3,2,3) = 1;
C(1,3,3) = 1;
C(4,3,3) = 0.5;
C(3,4,3) = 0.5;

% config 1 and 2
C(:,:,1) = 0.5*(C(:,:,3)+C(:,:,3)');

C(:,:,2) = C(:,:,1);

% config 4
C(:,:,4) = C(:,:,3);

% config 1
for i=1:N
    Sigma(i,i,1) = 1;
end

% config 2, 3 and 4
Sigma(:,:,2) = Sigma(:,:,1);
Sigma(2,2,2) = 0.75;
Sigma(1,1,2) = 0.5;

Sigma(:,:,3) = Sigma(:,:,2);

Sigma(:,:,4) = Sigma(:,:,2);

% config 4
std_noise = 0.5; % standard deviation for normal noise added to config 4
amp_noise = 0.5; % amplitude of noise for config 4

% all configs
C = C*0.8; % homogeneous scaling
I0 = 0.05; % homogeneous inputs


% erase previous plots
close all;


% simulation for 4 configurations
for i_net=1:n_net

    % simulated Jacobian,
    J_sim = -eye(N)/tau_x + C(:,:,i_net);
    % simulated input noise
    Sigma_sim = Sigma(:,:,i_net);
    % multivariate Ornstein-Uhlenbeck simulation,
    X_tmp = zeros(N,nT); % time series with time step dt
    v_noise = sqrt(Sigma_sim) * (randn(N,nT0+nT) * (dt^0.5)); % input noise
    for iT=2:(nT0+nT)
        X_tmp(:,iT) = X_tmp(:,iT-1) + dt*(J_sim*X_tmp(:,iT-1)) + I0 + v_noise(:,iT);
    end

    % subsampling
    ts_X = zeros(T,N); % time series with time step 1 (subsampled)
    for iT=1:T
        ts_X(iT,:) = X_tmp(:,nT0+iT*n_sampl); % swap order of indices
    end

    % gaussian noise for config 4
    if i_net==n_net
        ts_X = ts_X + amp_noise*(lognrnd(0,std_noise,T,N)-1);
    end

    % mean calculation and demeaning
    X = mean(ts_X,1);
    for i=1:N
        ts_X(:,i) = ts_X(:,i) - X(i);
    end
    %print(mean(ts_X,1))

    % empirical covariances
    Q0 = (ts_X(1:nTs-1,:)'*ts_X(1:nTs-1,:)) / (nTs-2);
    Q1 = (ts_X(1:nTs-1,:)'*ts_X(2:nTs,:)) / (nTs-2);

    % Pearson correlations,
    K = Q0;
    K = K ./ sqrt(diag(K)*diag(K)');
    for i=1:N
        K(i,i) = 0;
    end

    % partial correlation
    P = pinv(Q0);
    P = -P ./ sqrt(diag(P)*diag(P)');
    for i=1:N
        P(i,i) = 0;
    end

    % MVAR estimate
    A_MVAR = pinv(Q0)*Q1;
    C_MVAR = A_MVAR';
    for i=1:N
        C_MVAR(i,i) = 0;
    end
    Sigma_MVAR = Q0 - A_MVAR*(Q0*A_MVAR');

    % theoretical MOU estimate
    J_MOU = real(logm(pinv(Q0)*Q1));
    C_MOU = J_MOU';
    for i=1:N
        C_MOU(i,i) = 0;
    end
    Sigma_MOU = - J_MOU*Q0 - Q0*J_MOU';


    % plots
    figure;

    subplot(4,3,1);
    imagesc(C(:,:,i_net),[0,1]);
    title('C orig');
    colorbar;

    subplot(4,3,2);
    imagesc(diag(Sigma(:,:,i_net)),[0,1.5]);
    title('Sigma orig');
    colorbar;


    subplot(4,3,4);
    imagesc(X,[0,9]);
    title('mean X');
    colorbar;

    subplot(4,3,5);
    imagesc(Q0,[0,1.5]);
    title('Q0');
    colorbar;

    subplot(4,3,6);
    imagesc(Q1,[0,1.5]);
    title('Q1');
    colorbar;


    subplot(4,3,7);
    imagesc(K,[0,1]);
    title('CORR');
    colorbar;


    subplot(4,3,8);
    imagesc(P,[0,0.5]);
    title('PC');
    colorbar;

    if 0
        subplot(4,3,10);
        imagesc(C_MVAR,[0,0.5]);
        title('C MVAR');
        colorbar;

        subplot(4,3,11);
        imagesc(diag(Sigma_MVAR),[0,1]);
        title('Sigma MVAR');
        colorbar;

    else

        subplot(4,3,10);
        imagesc(C_MOU,[0,1]);
        title('C MOU');
        colorbar;

        subplot(4,3,11);
        imagesc(diag(Sigma_MOU),[0,1.5]);
        title('Sigma MOU');
        colorbar;

    end
        
end

%savefig('fig_est_th')

