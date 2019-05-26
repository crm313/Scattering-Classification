%function H0=angularspline(om)

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

function H0=angularspline(om)
	om=abs(om);
	zeroes=find(om==0);
	bigangles=find(om>=pi/2);

	Omega=2*om;

	S = 5 + 30 * cos(Omega/2).^2 + 30 * sin(Omega/2).^2 .* cos(Omega/2).^2 ;
	S = S+70*cos(Omega/2).^4+2 * sin(Omega/2).^4 .* cos(Omega/2).^2 +2/3*sin(Omega/2).^6;
	S = S ./ (105 * 2^8 * sin(Omega/2).^8);

	S2 = 5 + 30 * cos(Omega).^2 + 30 * sin(Omega).^2 .* cos(Omega).^2 ;
	S2 = S2+70*cos(Omega).^4+2 * sin(Omega).^4 .* cos(Omega).^2 +2/3*sin(Omega).^6;
	S2 = S2 ./ (105 * 2^8 * sin(Omega).^8);

	H0 = sqrt(S./ (2^7 * S2));
	H0 = H0 / sqrt(2);
	H0(zeroes)=1;
	H0(bigangles)=0;
end