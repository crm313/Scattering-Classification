%CORE_SCATT The core scattering function
%   out = core_scatt(in,options) calculates the scattering coefficients of in 
%   using parameters from options.
%   The scattering transform is calculated using the following steps:
%       1) create/retrieve filter bank
%
%       2) create/retrieve generic functions
%          - next_bands(j)
%            get the next bands of decomposition, give the previous one 'j'
%          - downsampling_fac(resolution,j)
%            get the downsampling factor to apply for a signal at 'resolution'
%            filtered at scale 'j'
%
%       3) main loop
%          for all orders
%             for all signals of previous order:
%                - decompose (wavelet transform, modulus, subsampling)
%                - smooth (low pass, subsampling)
%             end
%          end
%
%   The following options can be specified
%       options.M - maximal scattering order [default 2]
%       options.J - maximal scale
%          [default 4 for dyadic filter banks]
%       options.filter_bank_name - handle for filter bank generator
%          [default @cauchy_filter_bank]
%       options.filters - explicitly defined filters (J and filter_bank_name
%          ignored)
%       options.delta - path offset; paths are only computed for 
%          j_{n+1} > j_n+delta, but only if antialiasing factor aa_psi is
%          compatible. [default 1 for dyadic filter banks]
%       options.aa - antialiasing factor; output is oversampled by 2^aa
%          [default 1]
%       options.aa_psi - intermediate antialiasing factor; when calculating
%          wavelet coefficients, oversample by 2^aa_psi. [default aa]
%       options.richer_scatt - if 1, output S (non-smoothed) as well as SJ 
%          (smoothed) [default 0]
%
%	
%   The output out is a nested cell array containing the scattering 
%   coefficients. out{m+1}{k} holds the kth scattering coefficient of order 
%   m, containing two fields signal and meta. The former contains the actual
%   signal while the latter specifies its scale, resolution, etc. Scale and
%   resolution are specified in base M, where M is the maximal 
%   scale/resolution and the most significant digit corresponding so the first
%   path component. If options.richer_scatt is enabled, out is divided into 
%   out.S and out.SJ


% Copyright 2011-2012, CMAP, Ecole Polytechnique
% Contributors: Joan Bruna, Laurent Sifre, Joakim Andén
%
% This software is governed by the CeCILL license under French law and
% abiding by the rules of distribution of free software.  You can  use, 
% modify and/ or redistribute the software under the terms of the CeCILL
% license as circulated by CEA, CNRS and INRIA at the following URL
% "http://www.cecill.info". 
%
% The fact that you are presently reading this means that you have had
% knowledge of the CeCILL license and that you accept its terms.

function out = core_scatt(in,options)
	if nargin < 2
		options = struct();
	end

	dim_in = sum(size(in)>1);
	size_in = size(in);

	M=getoptions(options,'M',2);

	% 1) create/retrieve filter bank
	if isfield(options,'filters') && ~isempty(options.filters)
		filters=options.filters;
	else
		switch dim_in
		case 1
			filter_bank=getoptions(options,'filter_bank_name',@cauchy_filter_bank);
		case 2
			filter_bank=getoptions(options,'filter_bank_name',@radial_filter_bank);
		end
		filters=filter_bank(size_in,options);
	end

	% 2) create/retrieve generic functions
	filter_type = getoptions(filters,'type','dyadic');
	a=getoptions(filters,'a',2);						% elementary dilation factor
	aa = getoptions(options,'aa',1);
	aa_psi = getoptions(options,'aa_psi',aa);
	delta=getoptions(options,'delta',1/log2(a));
	
	% - next_bands
	if strcmp(filter_type,'nondyadic-1d')				% non-dyadic audio filter bank (constant-Q)
		next_bands=getoptions(options,'next_bands',@(j) (audio_next_bands(j,filters.Q,filters.a,filters.J,filters.P,a^(1/log2(a)-delta))));
	else
		next_bands=getoptions(options,'next_bands',@(j) (max(0,j+delta)));
	end

	%  - downsampling_fac
	if strcmp(filter_type,'nondyadic-1d')				% non-dyadic audio filter bank (constant-Q)
		downsampling_fac = getoptions(options,'downsampling_fac',@(res,j)(max(0,audio_downsampling(j,filters.Q,filters.a,filters.J,filters.P,2^aa)-res)));
		downsampling_fac_psi = getoptions(options,'downsampling_fac_psi',@(res,j)(max(0,audio_downsampling(j,filters.Q,filters.a,filters.J,filters.P,2^aa_psi)-res)));
	else
		downsampling_fac = getoptions(options,'downsampling_fac',@(res,j) max(0,floor(j * log2(a)-res-aa)));
		downsampling_fac_psi = getoptions(options,'downsampling_fac_psi',@(res,j) max(0,floor(j * log2(a)-res-aa_psi)));
	end

	% 3) main loop
	% for all orders
	% 	for all signals of previous order:
	% 		- decompose (wavelet transform, modulus, subsampling)
	% 		- smooth (low pass, subsampling)
	% 	end
	% end

	% Initialize using input
	S{1}{1}.signal=in;
	S{1}{1}.meta.scale=-1;
	S{1}{1}.meta.orientation=0;
	S{1}{1}.meta.resolution=0;

	for m=1:M+1
		raster=1;
		if m > size(S,2)		% No more coefficients to calculate
			continue;
		end
		
		for s=1:numel(S{m})
			sig=S{m}{s}.signal;
			infos=S{m}{s}.meta;

			% Decompose/propagate - retrieve high frequencies
			if m<=M
				children=decompose(sig,infos,filters,next_bands,downsampling_fac_psi);
				for ic=1:numel(children)
					S{m+1}{raster}=children{ic};
					raster=raster+1;
				end
			end

			% Smooth
			SJ{m}{s}=smooth(sig,infos,filters,downsampling_fac);
		end
	end

	% Save both smoothed and unsmoothed?
	outformat=getoptions(options,'richer_scatt',0);
	if outformat 
		out.S=S;
		out.SJ=SJ;
	else
		out=SJ;
	end
end

function children = decompose(sig,infos,filters,next_bands,downsampling_fac)
	% Decompose a signal into its wavelet coefficients, downsample and compute the modulus
	
	number_of_j = length(filters.psi{1});
	sigf=fourier(sig);
	res=infos.resolution;
	prev_j=(infos.scale>=0)*mod(infos.scale,number_of_j) + -100*(infos.scale<0);
	raster=1;
	children={};
	for j=max(0,next_bands(prev_j)):numel(filters.psi{res+1})-1
		number_of_orientation = numel(filters.psi{res+1}{j+1});
		for th=1:number_of_orientation
			ds = downsampling_fac(infos.resolution,j);
			out = abs(sub_conv(sig,sigf,filters.psi{res+1}{j+1}{th},2^ds));

			children{raster}.signal = out;
			children{raster}.meta.resolution = res+ds;
			children{raster}.meta.scale = (infos.scale>=0)*infos.scale*number_of_j + j;
			children{raster}.meta.orientation = infos.orientation*number_of_orientation + th-1;

			raster=raster+1;
		end
	end
end

function smoothed_sig = smooth(sig,infos,filters,downsampling_fac)
	% Smooth a signal and downsample
	
	sigf=fourier(sig);
	number_of_j = length(filters.psi{1});
	smoothed_sig.meta=infos;
	ds = downsampling_fac(infos.resolution,number_of_j);
	smoothed_sig.signal = sub_conv(sig,sigf,filters.phi{infos.resolution+1},2^ds);
	smoothed_sig.meta.orignorm = norm(sig(:));
end

function sigf=fourier(sig)
	dim_in = sum(size(sig)>1);
	switch dim_in
		case 1
			sigf=fft(sig);
		case 2
			sigf=fft2(sig);
	end
end
