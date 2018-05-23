%Figure 1: Connectivity matrix%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch num_model
    
    case 1
    p_V_X=1;
    p_V_Y=0;   
    p_X_Y=1;
    case 2
    p_V_X=0;
    p_V_Y=1;   
    p_X_Y=1;    
    case 3
    p_V_X=1;
    p_V_Y=1;   
    p_X_Y=0;  
    
    
end
     MAT_CONN_MODEL=diag(ones(1,3));
     MAT_CONN_MODEL(1,2)=p_V_X;
     MAT_CONN_MODEL(1,3)=p_V_Y;
     MAT_CONN_MODEL(2,1)=p_V_X;
     MAT_CONN_MODEL(3,1)=p_V_Y;
     MAT_CONN_MODEL(2,3)=p_X_Y;
     MAT_CONN_MODEL(3,2)=p_X_Y;
     
     
 figure(1)
 hold on
 set(gca, 'fontsize', 24)
 imagesc(MAT_CONN_MODEL)
 title('Model binary connectivity matrix')
 colorbar


%Figure 2: Relationship V with X and Y%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MAT=[vecV,vecX,vecY];
figure(2)
set(gca, 'fontsize', 24)
hold on

rate_X_mean=zeros(1,length(unique(vecV)));
rate_X_std=zeros(1,length(unique(vecV)));
rate_Y_mean=zeros(1,length(unique(vecV)));
rate_Y_std=zeros(1,length(unique(vecV)));

    for i_v=1:length(unique(vecV))
        
        rate_X_mean(i_v)=mean(MAT(MAT(:,1)==i_v,2));
        rate_X_std(i_v)=std(MAT(MAT(:,1)==i_v,2));
        
        rate_Y_mean(i_v)=mean(MAT(MAT(:,1)==i_v,3));
        rate_Y_std(i_v)=std(MAT(MAT(:,1)==i_v,3));

    end
    
    errorbar(1:3, rate_X_mean,rate_X_std)%, 'linewidth',2);
    errorbar(1:3, rate_Y_mean,rate_Y_std)%, 'r','linewidth',2);
    
    legend('V-X', 'V-Y')
    xlim([0.5,3.5]);
    xlabel('Stimulus value')
    ylabel('Number of spikes')



    
%Figure 3: Relationship X and Y%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
figure(3)
set(gca, 'fontsize', 24)
hold on


rate_Y_mean=zeros(1,length(unique(vecX)));
rate_Y_std=zeros(1,length(unique(vecX)));
X=unique(vecX);
    for i_x=1:length(X)
        x_val=X(i_x);
        rate_Y_mean(i_x)=mean(MAT(MAT(:,2)==x_val,3));
        rate_Y_std(i_x)=std(MAT(MAT(:,2)==x_val,3));

    end
    
    errorbar(rate_Y_mean,rate_Y_std)%,'linewidth',2);
    
    legend('X-Y')
    xlabel('Number of spikes X')
    ylabel('Number of spikes Y')


