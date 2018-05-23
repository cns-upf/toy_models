clc
clear all
close all
figures_model=1; %model figures visualization (yes:1. no:0)


%%
%%%1. MODEL GENERATION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %V: variable categorizing the stimulus outcome.
    %X: variable denoting the number of spikes in one recorded sequence.
    %Y: variable denoting the number of spikes in a second recorded sequence.
    
    %Main model parameteters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    stimulus_encoding='non linear'; %type of neural coding linear vs. non-linear
    P_source_max=0.3; %probability of spikes for srlected simtulus outcome 
    epsilon=0.1;      %channel crossover probability between binary sequences: P(Y_i=1|X_i=0)=P(Y_i=0|X_i=1)=epsilon
    num_levels=6; %number of quantized levels of X and Y to approximate conditioning
    %needs to be a divisor of num_trials
    num_trials=50*num_levels;   %number of trials/realizations of the stimulus
    sequence_length=25;  %number of spike train bins
%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%TOY MODELS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%MODEL 1:          V-X-Y   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %conditions: MI:      I(V;X) sign, I(V;Y) sign, I(X;Y) sign, 
    %            cond MI: I(V;X|Y) sign, I(V;Y|X) no sign, I(X;Y|V) sign 
    %
    %%%%MODEL 2:          V-Y-X   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %conditions: MI:      I(V;X) sign, I(V;Y) sign, I(X;Y) sign, 
    %            cond MI: I(V;X|Y) no sign I(V;Y|X) sign, I(X;Y|V) sign
    %
    %%%%MODEL 3:          Y-V-X  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %conditions: MI:      I(V;X) sign, I(V;Y) sign, I(X;Y) sign, 
    %            cond MI: I(V;X|Y) sign, I(V;Y|X) sign, I(X;Y|V) no sign 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    num_model=3;
    %Generate the observables (vecV, vecX, vecY) of the variables V,X,Y from the model
    [vecV,vecX,vecY]=generate_model(P_source_max,epsilon,num_trials,sequence_length,num_model,stimulus_encoding);
    
    if figures_model
        generate_figures_model
    end
    
%%
%%%2. CONNECTIVITY  ESTIMATION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    clc
    figures_results=1;%results figures visualization (yes:1. no:0)

    %Statistical parameteters%%%%%%%%%%%%%%%%%%%%%%%%
    num_surs=100; %number of surrogates
    max_sur=10; %%maximum number of surrogates per conditioned value in the conditional mutual information computation
    sign_alpha=0.05; %significance threshold
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%CONNECTIVITY MEASURE TYPES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   num_measure=1;
   %MUTUAL INFORMATION: I(A;B)=E_[A,B][log(P(A,B)/P(A)P(B))]
   %num_measure=2
   %CONDITIONAL MUTUAL INFORMATION: I(A;B|C)=E_[A,B,C][log(P(A,B|C)/P(A|C)P(Y|C))]
   %num_measure=3
   %PEARSON CORRELATION:
   %num_measure=4
   %PARTIAL CORRELATION:  
   cont=0;
   
   cont=cont+1;
   switch num_measure
       
       case 1
            [a_V_X, p_V_X]=mutual_information(vecV, vecX, num_surs);
            [a_X_Y, p_X_Y]=mutual_information(vecX, vecY, num_surs);
            [a_V_Y, p_V_Y]=mutual_information(vecV, vecY, num_surs);
       
       
       case 2
            %%quantization into num_levels
            [vecX2, vecY2]=equal_bin_quantization(vecX, vecY, num_levels, num_trials);
           
            [a_V_X, p_V_X]=conditional_mutual_information(vecV,vecX,vecY2, max_sur);
            [a_X_Y, p_X_Y]=conditional_mutual_information(vecX,vecY,vecV, max_sur);     
            [a_V_Y, p_V_Y]=conditional_mutual_information(vecV,vecY,vecX2, max_sur);
           
       case 3
            
            [a_V_X,p_V_X] = corr(vecV,vecX);
            [a_X_Y,p_X_Y] = corr(vecX,vecY);
            [a_V_Y,p_V_Y] = corr(vecV,vecY);
             
        case 4

            [a_V_X,p_V_X] = partialcorr(vecV,vecX, vecY);
            [a_X_Y,p_X_Y] = partialcorr(vecX,vecY,vecV);
            [a_V_Y,p_V_Y] = partialcorr(vecV,vecY, vecX);
             
   end
           
   
 %%%%CONNECTIVITY MATRIX OUTPUTS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
     %Binary (unweighted) connectivity matrix (1->significant connection, 0-> no signficiantconnection) 
     MAT_CONN_SIGN=zeros(3);
     MAT_CONN_SIGN(1,2)=p_V_X;
     MAT_CONN_SIGN(1,3)=p_V_Y;
     MAT_CONN_SIGN(2,1)=p_V_X;
     MAT_CONN_SIGN(3,1)=p_V_Y;
     MAT_CONN_SIGN(2,3)=p_X_Y;
     MAT_CONN_SIGN(3,2)=p_X_Y;
     MAT_CONN_SIGN=MAT_CONN_SIGN<sign_alpha;
    
     %Weigted connectivity  matrix
     MAT_CONN=diag(ones(1,3));
     MAT_CONN(1,2)=a_V_X;
     MAT_CONN(1,3)=a_V_Y;
     MAT_CONN(2,1)=a_V_X;
     MAT_CONN(3,1)=a_V_Y;
     MAT_CONN(2,3)=a_X_Y;
     MAT_CONN(3,2)=a_X_Y;

%%%Ouput estimated connectivity matrices%%%%%%%%%%%%%%%%%%%%%
     if figures_results
         figure(4+cont)
         hold on
         set(gca, 'fontsize', 24)
         imagesc(MAT_CONN_SIGN)
         xlim([0.5,3.5])
         ylim([0.5,3.5])
%          xticks({}) 
%          yticks({}) 
         colorbar
         saveas(gcf, ['Fig4_' num2str(num_measure) '.png'])
         %title('Estimated binary connectivity matrix')
         
     
         
         figure(5+cont)
         hold on
         set(gca, 'fontsize', 24)
         imagesc(MAT_CONN)
         %title('Estimated weighted connectivity matrix')
         %saveas(gcf, ['Fig5_' num2str(num_measure) '.png'])
         colorbar
     end
     


