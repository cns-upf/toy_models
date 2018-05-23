function [R, esc] = randpermfull_no_repetition(N,M)

esc=0;
check=0;
K=0;
  while check==0
  aux=randpermfull(N);
    check=1;
    j=1;
	while check==1 && j<= size(M,1)
      if aux==M(j,:)
        K=K+1;
       check=0;
	  end
       j=j+1;
	 end
   
  if (K>20) %display('There is no such a permutation');
  esc=1;
  break;
  end
end
R=aux;
end



