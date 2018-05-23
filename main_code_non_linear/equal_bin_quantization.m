function [vecX2, vecY2]=equal_bin_quantization(vecX, vecY, num_levels, num_trials)


     [aux,ind_sort_X]=sort(vecX, 'ascend');
      vecX2=zeros(num_trials,1);
      for j=1:num_levels
         vecX2(ind_sort_X(1+(j-1)*num_trials/num_levels:j*num_trials/num_levels))=j; 
      end
      [aux,ind_sort_Y]=sort(vecY, 'ascend');
      vecY2=zeros(num_trials,1);
      for j=1:num_levels
         vecY2(ind_sort_Y(1+(j-1)*num_trials/num_levels:j*num_trials/num_levels))=j; 
      end
      