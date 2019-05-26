%CAUCHY_FILTER_BANK Create a filter bank of Cauchy wavelets
%   filters = cauchy_filter_bank(sizein,options) generates a cauchy wavelet
%   filter bank for signals of size sizein using parameters contained in 
%   options.
%
%   The following options can be specified
%      options.a - The elementary dilation factor [default 2]
%      options.J - The maximal scale of the filters, giving a maximal temporal
%         support of a^(J-1) [default 4]
%      options.cauchy_order - The order of the cauchy filters. Higher orders 
%         have more vanishing moments, but are located at higher frequencies.
%         [default 2]
%      options.cauchy_lambda - The maximum discontinuity of the filters in the
%         Fourier domain at 2*pi.

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

function filters = cauchy_filter_bank(sizein, options)
	if nargin < 2
		options = struct();
	end
	
	a=getoptions(options,'a',2);
	J=getoptions(options,'J',4);

	% For all possible resolutions (original size divided by powers of 2)
	for res=0:floor(log2(a)*(J-1))
		N=ceil(sizein(1)/2^res);

		mod_omega=(0:2*N-1)'/(sqrt(2)*N)*4*pi;

		% Calculate wavelet filters and S^2, the Littlewood-Paley sum
		littlewood_rad=zeros(2*N,1);
		for j=floor(res/log2(a)):J-1
			scale=a^j*2^(-res);
			psif_rad{j+1} = cauchy(scale*mod_omega,options);
			littlewood_rad = littlewood_rad + abs(psif_rad{j+1}.^2);
		end

		K_rad=max(littlewood_rad);
		
		% Find first local maximum (where neighbors are smaller than center)
		local_max_littlewood_rad = circshift(littlewood_rad,-1)<=littlewood_rad & ...
			circshift(littlewood_rad,+1)<=littlewood_rad;
		Rcut = find(local_max_littlewood_rad>0);

		% Extract up to first maximum
		mask=zeros(size(mod_omega));
		mask(1:Rcut)=1;

		% Define phi as sqrt(1-S^2) where S^2 is Littlewood-Paley sum
		phi0f = mask.*sqrt(1- littlewood_rad/K_rad);
		phi0f(end:-1:end-Rcut+2)=phi0f(2:Rcut);

		% Subsample to get wanted phi
		phi0 = ifft(phi0f);
		phif{res+1} = 2*fft(phi0(1:2:end));

		% Renormalize by K_rad and subsample to get wanted psis
		for j=floor(res/log2(a)):J-1
			psi0f = ifft(psif_rad{j+1}/sqrt(K_rad));
			psif{res+1}{j+1}{1} = sqrt(2)*2*fft(psi0f(1:2:end));% sqrt(2) since we keep only positive thetas, 2 is for downsampling
		end
	end
	
	filters.psi = psif;
	filters.phi = phif;
	filters.a = a;

	filters.type = 'cauchy-1d';
end