%function filts=cubicspline(N,options)

% Copyright 2011-2012, CMAP, Ecole Polytechnique
% Contributors: Laurent Sifre, Joan Bruna
%
% This software is governed by the CeCILL license under French law and
% abiding by the rules of distribution of free software.  You can  use, 
% modify and/ or redistribute the software under the terms of the CeCILL
% license as circulated by CEA, CNRS and INRIA at the following URL
% "http://www.cecill.info". 
%
% The fact that you are presently reading this means that you have had
% knowledge of the CeCILL license and that you accept its terms.

function filts=cubicspline(N,options)
	[h0,g0,h,g]=splinewavelet(3,N);

	J=getoptions(options,'J',4);
	filts.psi{1}=fft(g0)/sqrt(2);
	for j=2:J
		filts.psi{j}=zeros(size(filts.psi{j-1}));
		slice=filts.psi{j-1}(1:2:end);
		filts.psi{j}(1:length(slice))=slice;
	end
	filts.phi = zeros(size(filts.psi{1}));
	slice=fft(h0)/sqrt(2);
	L=length(slice);
	slice=slice(1:L/2);
	slice=slice(1:2^(J-1):end);
	L=length(slice);
	filts.phi(1:L)=slice;
	%filts.phi(end:-1:end-L+2)=slice(2:end);

	filts.littlewood=zeros(size(filts.psi{1}));

	filts.littlewood = filts.littlewood + abs(filts.phi).^2;
	for j=1:J
		filts.littlewood = filts.littlewood + .5* abs(filts.psi{j}).^2;
	end
end