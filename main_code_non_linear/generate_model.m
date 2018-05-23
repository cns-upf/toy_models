function [V,X,Y]=generate_model(P_source_max,epsilon,num_trials,sequence_length,num_model, encoding)


%Local PARAMETERS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P_source_min=0.1; 
P_source_delta=0.2;


if strcmp(encoding, 'linear')
P_source=[P_source_min,(P_source_max+P_source_min)/2, P_source_max];
P_source2=[P_source_min,(P_source_max+P_source_delta+P_source_min)/2,P_source_max+P_source_delta];  
elseif strcmp (encoding, 'non linear')
P_source=[P_source_min,P_source_max,P_source_min];
P_source2=[P_source_min,P_source_max+P_source_delta,P_source_min];
end


%Number of stimuli outcomes;
M=length(P_source);
%Difference in source coding distrbution for Model 3%%%%%%%%%%


               %Initialization
                V=[];
                X=[];
                Y=[];
%Trial Loop%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    for r=1:num_trials
     
                    %source message
                    index_message=ceil(M*rand);
                
                    %channel input Markov Chain
                    x0=zeros(1,sequence_length);
                    y0=zeros(1,sequence_length);
                    P_1=rand(1,sequence_length);
                    P_2=rand(1,sequence_length);
                    
                    %Model selection%%%%%%%%%%%%%%%%%%%%
                        if num_model==1
                            %%%%Chain model V-X-Y%%%%%%%%%%%%%%%%%%
                            x0=P_1(1,:)<=P_source(index_message);
                            y0=mod(x0+(rand(1,sequence_length)<epsilon),2);

                        elseif num_model==2
                            %%%%Chain model V-X-Y%%%%%%%%%%%%%%%%%%
                            y0=P_1(1,:)<=P_source(index_message);
                            x0=mod(y0+(rand(1,sequence_length)<epsilon),2);

                        elseif num_model==3
                            %%%%Chain model V-X-Y%%%%%%%%%%%%%%%%%%
                            x0=P_1(1,:)<=P_source(index_message);
                            y0=P_2(1,:)<=P_source2(index_message);

                        end

                     %Model variable samples
                     V=[V,index_message];
                     X=[X,sum(x0)];
                     Y=[Y,sum(y0)];

                    clear x0 y0
                    end
                    
                    V=V';
                    X=X';
                    Y=Y';
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    
         