function matchingcols=comparcol(colvec,matrix,tol)
C=colvec(:,ones(1,size(matrix,2))); % replicate column vector into a matrix of same size as input matrix
matchingcols=find(max(mean(C==matrix),mean(~C==matrix))-0.5>tol); %return column indeces for all columns of matrix that match colvec (or its complement) too closely