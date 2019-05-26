%function filters = gabor_filter_bank_2d(size_in,options)

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

function filters = gabor_filter_bank_2d(size_in,options)
	options.null=1;

	J=getoptions(options,'J',4);
	L=getoptions(options,'L',6);
	a=getoptions(options,'a',2);
	gab_type=getoptions(options,'gab_type','morlet');
	slant=getoptions(options,'slant',4/L);
	
	tau_as=0.8;% (as=adjacent scale) the value of the fourier transform of adjacent scales at crossing
	tau_lc=0.9;% (lc=low-coarse) the value of the fourier transform of low pass and coarse scale at crossing
	xi0=3*pi/4;

	switch gab_type
	case 'gabor'
		gab=@gabor_2d;
		sigma00=1.05;
		sigma0=2/3;
	case 'morlet'
		gab=@morlet_2d;
		sigma00=sqrt(-2*log(tau_as))/(xi0)*(a+1)/(a-1);
		sigma0=sqrt(-2*log(tau_lc/2))/(xi0 - sqrt(-2*log(tau_lc))/sigma00);
	end

	filters.infos.sigma0=sigma0;
	filters.infos.sigma00=sigma00;
	
	thetas=(0:2*L-1)  * pi / L;
	for res=0:floor(log2(a)*(J-1))
		N=ceil(size_in(1)/2^res);
		M=ceil(size_in(2)/2^res);

		scale=a^(J-1)*2^(-res);
		phif{res+1} = sqrt(2)*fft2(gabor_2d(N,M,sigma0*scale,1,0,0));%no slant for low freq

		%compute high pass filters psif{j}{theta}
		littlewood_final=zeros(N,M);
		littlewood_final=abs(phif{res+1}).^2;
		for j=floor(res/log2(a)):(J-1)
			for th=1:numel(thetas);
				theta=thetas(th);
				scale=a^j*2^(-res);
				psif{res+1}{j+1}{th} = ...
					fft2(gab(N,M,sigma00*scale ,slant,xi0/scale,theta) );
					littlewood_final = littlewood_final + abs(psif{res+1}{j+1}{th}).^2;
			end
		end

		%get max of littlewood paley
		K=max(max(littlewood_final));
		if getoptions(options,'no_norm',0)
			K=1;
		end
		phif{res+1}=phif{res+1}/sqrt(K);

		for j=floor(res/log2(a)):(J-1)
			for th=1:numel(thetas)/2;
				psif2{res+1}{j+1}{th}=sqrt(2/K)*psif{res+1}{j+1}{th};
			end
		end
	end	

	filters.psi=psif2;
	filters.phi=phif;
end
