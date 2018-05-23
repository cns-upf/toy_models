%Function that computes mutual information between 2 variables coniditoned
%on a third variable using different null-hypotesis models


%OUTPUT:


%INPUT: Y: independent variable
%       X1:first dependent variable
%       X2 second dependent variable
%       max_sur: maximum number of surrogates
%c      cond: type of conditioning, Y-X1 given X2 or Y-X2 given X1
function [MI, pvalue, MI_sur, MI_cond, pval_cond,MI_sur_cond]=conditional_mutual_information(vecX, vecY, vecZ, max_sur)



N=length(vecX);

if length(vecY)~=N ||length(vecZ)~=N
    print('Error, dimensions across three sequences do not match');
end


  M=[vecX,vecY,vecZ];

  %Conditioned variable 
  Z=unique(vecZ);
  Nz=length(Z);
  pz=zeros(1,Nz);
  
  %Initialization%%%%%
  MI_cond=zeros(1,Nz);
  pval_cond=zeros(1,Nz);
  MI_sur_cond=cell(1,Nz);
  
  MI=0;
  MI_sur=[];
        for i=1:Nz  
                  
                 %MI computed for a given z value
                 Lz=sum(vecZ==Z(i));
                 vecX=M(vecZ==Z(i),1);
                 vecY=M(vecZ==Z(i),2);
                 Nsurz=min(max_sur,factorial(Lz)); %number of surrogates%
                 [MI_cond(i), pval_cond(i),MI_sur_cond{1,i}]=mutual_information(vecX, vecY, Nsurz);
                 pz(i)=sum(vecZ==Z(i))/N;
                 MI=MI+pz(i)*MI_cond(i);
                 
                 

                 %%%%Surrogate accumulation%%%%%%% 
                 MI_sur_aux=[];
                 if i==1
                     MI_sur=pz(i)*MI_sur_cond{1,i};
                 else
                     for j=1:length(MI_sur) 
                     MI_sur_aux=[MI_sur_aux,MI_sur(j)+ pz(i)*MI_sur_cond{1,i}];
                     end
                     MI_sur=[MI_sur_aux];
                 end
     
        end
         size(MI)
         size(MI_sur)
         pvalue=(1+sum(MI_sur>MI))/(length(MI_sur)+1);
end
        
        
   
   
   
        
        