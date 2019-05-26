%[H0,G0,H,G] = splinewavelet(m,L)
%
%   Builds filters of length L to a Spline wavelets of Battle-Lemarie
%   with m=1 for linear splines and m=3 for cubic splines
%   H0 and G0 are the low pass and band-pass filters of the first filtering
%   H is a real low-pass filter to be used afterwards
%   and G the a complex analytic band-pass filter to be used afterwards


% Copyright 2011-2012, CMAP, Ecole Polytechnique
% Contributors: Stéphane Mallat
%
% This software is governed by the CeCILL license under French law and
% abiding by the rules of distribution of free software.  You can  use, 
% modify and/ or redistribute the software under the terms of the CeCILL
% license as circulated by CEA, CNRS and INRIA at the following URL
% "http://www.cecill.info". 
%
% The fact that you are presently reading this means that you have had
% knowledge of the CeCILL license and that you accept its terms.


function [H0,G0,H,G,H1] = splinewavelet(m,L);
	%Definition of the first filter G0
	K = 2:L;
	Omega = 2* pi *(1:L-1)/(2*L);
	if(m==3)
		S(K) = 5 + 30 * cos(Omega/2).^2 + 30 * sin(Omega/2).^2 .* cos(Omega/2).^2 ;
		S(K) = S(K)+70*cos(Omega/2).^4+2 * sin(Omega/2).^4 .* cos(Omega/2).^2 +2/3*sin(Omega/2).^6;
		S(K) = S(K) ./ (105 * 2^8 * sin(Omega/2).^8);

		S2(K) = 5 + 30 * cos(Omega).^2 + 30 * sin(Omega).^2 .* cos(Omega).^2 ;
		S2(K) = S2(K)+70*cos(Omega).^4+2 * sin(Omega).^4 .* cos(Omega).^2 +2/3*sin(Omega).^6;
		S2(K) = S2(K) ./ (105 * 2^8 * sin(Omega).^8);
	elseif (m==1)
		S(K) = (1 + 2 * cos(Omega/2).^2) ./ (48 * sin(Omega/2).^4);
		S2(K) = (1 + 2 * cos(Omega).^2) ./ (48 * sin(Omega).^4);
	end

	H1(1:L) = 0;
	H1(K) = sqrt(S(K)./ (2^(2*m+1) * S2(K)));
	H1(1) = sqrt(2);

	K = 2:L/2;
	Omega = 2*pi *(1:L/2-1)/L;
	if(m==3)
		S(K) = 5 + 30 * cos(Omega/2).^2 + 30 * sin(Omega/2).^2 .* cos(Omega/2).^2 ;
		S(K) = S(K)+70*cos(Omega/2).^4+2 * sin(Omega/2).^4 .* cos(Omega/2).^2 +2/3*sin(Omega/2).^6;
		S(K) = S(K) ./ (105 * 2^8 * sin(Omega/2).^8);

		S2(K) = 5 + 30 * cos(Omega).^2 + 30 * sin(Omega).^2 .* cos(Omega).^2 ;
		S2(K) = S2(K)+70*cos(Omega).^4+2 * sin(Omega).^4 .* cos(Omega).^2 +2/3*sin(Omega).^6;
		S2(K) = S2(K) ./ (105 * 2^8 * sin(Omega).^8);
	elseif (m==1)
		S(K) = (1 + 2 * cos(Omega/2).^2) ./ (48 * sin(Omega/2).^4);
		S2(K) = (1 + 2 * cos(Omega).^2) ./ (48 * sin(Omega).^4);
	end

	H0(1:L) = 0;
	H0(K) = sqrt(S(K)./ (2^(2*m+1) * S2(K)));
	H0(1) = sqrt(2);
	H0(L:-1:L/2+2) = H0(2:L/2);

	H(1:L/2) = H0(1:2:L);
	H(L/2+1:L) = H0(1:2:L);

	G0(1:L) = 0;
	G0(1:L/2) = exp(-i * (2*pi *(0:L/2-1)/L + pi)) .* conj(H0(L/2+1:L));
	G0(L/2+1:L) = exp(-i * (2*pi *(L/2:L-1)/L + pi)) .* conj(H0(1:L/2));
	G(1:L) = 0;
	G(1:L/2) = sqrt(2) * G0(1:2:L);
	G0 = G0 .* H1 ;

	H0 = H0 * sqrt(2.)/H0(1);
	G0 = G0 * sqrt(2.)/H0(1);
	H0 = ifft(H0);
	G0 = ifft(G0);
	H = H * sqrt(2.)/H(1);
	G = G *sqrt(2) /H(1);
	H = ifft(H);
	G = ifft(G);
end

