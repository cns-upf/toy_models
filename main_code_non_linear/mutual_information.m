

function [MI0, pvalue,  MI_sur,P_X_Y, Perm_mat]=mutual_information(vecX, vecY, Nsur)

MI_sur=[];

%vector length
N=length(vecX);

%0 permutation
Perm_mat=1:N;

for sur=0:Nsur

       if sur>0
        
        newperm=randpermfull_no_repetition(N, Perm_mat); 
        vecY=vecY(newperm);
        Perm_mat=[Perm_mat; newperm];
        
       end
        
            %Alphabets
            X=unique(vecX);
            Y=unique(vecY);
            %Alphabet sizes
            Lx=length(X);
            Ly=length(Y);

            XY_mat=zeros(Lx, Ly);

            %Joint distribution (ML estimator)
                for k=1:N

                    x=vecX(k);
                    y=vecY(k);

                    i=find(X==x);
                    j=find(Y==y);

                    XY_mat(i,j)= XY_mat(i,j)+1;
                end

                %joint and marginal distribution
                PXY=XY_mat/N;
                PX=sum(PXY,2);
                PY=sum(PXY,1);

                %conditional distribution
                P_X_Y= PXY./repmat(PY,Lx,1);
                
                %non-zero measure indices
                index_no_0=find(PXY~=0);
                T=P_X_Y./repmat(PX,1,Ly);
                %T2=PXY./(repmat(PX,1,Ly).*repmat(PY,Lx,1));
                
                %MI computation
                MI=sum(sum(PXY(index_no_0).*log2(T(index_no_0))));
                %MI 2nd computation
                %MI2=sum(sum(PXY(index_no_0).*log2(T2(index_no_0))))

                if sur==0                    
                   MI0=MI;                   
                else                    
                   MI_sur=[MI_sur, MI];                                       
                end

end

pvalue=(1+sum(MI_sur>=MI0))/(1+Nsur);
