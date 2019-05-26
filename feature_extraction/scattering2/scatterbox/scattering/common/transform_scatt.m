%TRANSFORM_SCATT Apply an orthogonal linear transformation
%   [out,meta] = transform_scatt(transf,transf_meta,options) applies a linear 
%   transformation to the scattering vector specified by transf and transf_meta
%   obtained from scatt using the 'split' format. The structure options contains
%   parameters for the linear transformation to be applied.
%
%   The following options can be specified
%       options.transf_type - Transformation type. For the moment, only 'dct' 
%          is supported. [default 'dct']
%       options.transf_mode - Transformation dimensions. For a transf_mode of 0,
%          all dimensions are used, for 1, only orientations are 
%          transformed, and for 2, only scales are transformed. [default 0]
%       options.transf_order - If set to 1, transformation is done on
%          gamma1, then gamma2,..., j1, then j2,..., then and if set to 0, the
%          transformation is done in the opposite order. [default 0]

% Copyright 2011-2012, CMAP, Ecole Polytechnique
% Contributors: Joan Bruna, Joakim Andén
%
% This software is governed by the CeCILL license under French law and
% abiding by the rules of distribution of free software.  You can  use, 
% modify and/ or redistribute the software under the terms of the CeCILL
% license as circulated by CEA, CNRS and INRIA at the following URL
% "http://www.cecill.info". 
%
% The fact that you are presently reading this means that you have had
% knowledge of the CeCILL license and that you accept its terms.

function [out,meta]=transform_scatt(transf,transf_meta,options)
	if nargin < 2
		options = struct();
	end

	S=size(transf);
	
	transf_type=getoptions(options,'transf_type','dct');
	
	if ~strcmp(transf_type,'dct')
		error('unsupported transformation');
	end

	transf_mode=getoptions(options,'transf_mode',0);

	flip_transf_order=getoptions(options,'transf_order',0);

	if(length(S)==3)		% Bidimensional input, combine into one dimension
		numpixels=S(1)*S(2);
		transf=reshape(transf,S(1)*S(2),S(3));
	elseif(length(S)==2)
		numpixels=S(1);
	else
		error('unsupported input');
	end

	% Determine number of orientations (L) and scales (J)
	first_order=find(transf_meta.order==1);
	J=max(transf_meta.scale(first_order))+1;
	L=max(transf_meta.orientation(first_order))+1;
	
	% Zeroth order is trivially transformed
	zeroth_order=find(transf_meta.order==0);
	out=transf(:,zeroth_order);
	meta.order=zeros(1,length(zeroth_order));
	meta.orientation_tpos(1) = 0;
	meta.scale_tpos(1) = 0;
	meta.orientation_tfreq(1) = 0;
	meta.scale_tfreq(1) = 0;

	insize_or=[];
	insize_sc=[];
	
	% Transform orders 1,...,M
	for m=1:max(transf_meta.order)
		% Determine dimensions of path space
		insize_or=[L insize_or];
		insize_sc=[J insize_sc];
		insize=[insize_or insize_sc];
		
		% Prepare L,L,...,L,J,J,...,J matrix to store coefficients
		full.coeffs=zeros([numpixels insize]);
		full.mask=zeros(insize);
		full.orientation_tpos=zeros(insize);
		full.scale_tpos=zeros(insize);
		full.orientation_tfreq=zeros(insize);
		full.scale_tfreq=zeros(insize);

		% Fill with coeffs of proper order
		mth_order=find(transf_meta.order==m);
		for ss=mth_order
			% Determine position in matrix using orientation and scale
			code_or = transf_meta.orientation(ss);
			code_sc = transf_meta.scale(ss);
			raster = code_or + L^m*code_sc;
			
			% Place coefficients in matrix and record related variables
			full.coeffs(numpixels*raster+1:numpixels*(raster+1))=transf(:,ss);
			full.mask(raster+1)=1;
			full.orientation_tpos(raster+1)=code_or;
			full.scale_tpos(raster+1)=code_sc;
			full.orientation_tfreq(raster+1)=0;
			full.scale_tfreq(raster+1)=0;
		end
	
		% Determine which dimensions to transform along
		% 	Dims 0,...m-1 are orientations
		% 	Dims m,...2m-1 are scales
		switch transf_mode
		case 0
			transf_array=0:2*m-1;	% Transform along both scale and orientation
		case 1
			transf_array=0:m-1;		% Transform along orientation
		case 2
			transf_array=m:2*m-1;	% Transform along scale
		end
		
		% Perform transforms in opposite order?
		if flip_transf_order
			transf_array=fliplr(transf_array);
		end

		% Put 'pixel' dimension last
		full.coeffs = permute(full.coeffs,[2:ndims(full.coeffs) 1]);
		for dim=transf_array
			% Skip singleton dimensions
			if size(full.coeffs,dim+1) == 1
				continue;
			end
			
			% Shift coefficients (and related variables) so that desired dimension is first
			% and resize so that non-transform dimensions are collapsed
			full=structshiftdim(full,dim);
			[full,sz]=structreshape_fwd(full);

			% Transform along 1st dimension
			full=masked_dct(full,dim,m);

			% Restore original structure
			full=structreshape_inv(full,sz);
			full=structshiftdim(full,-dim);
		end
		
		% Restore pixel dimension as first dimension
		full.coeffs = permute(full.coeffs,[ndims(full.coeffs) 1:ndims(full.coeffs)-1]);
		
		% Collapse all non-pixel dimensions
		full.coeffs=reshape(full.coeffs,size(full.coeffs,1),numel(full.coeffs)/size(full.coeffs,1));
		
		% Add mth-order coefficients to output along with meta-variables
		out = [out full.coeffs(:,full.mask(:)==1)];
		
		meta.order=[meta.order m*ones(1,sum(full.mask(:)==1))];
		meta.orientation_tpos = [meta.orientation_tpos reshape(full.orientation_tpos(full.mask(:)==1),[1 sum(full.mask(:)==1)])];
		meta.scale_tpos = [meta.scale_tpos reshape(full.scale_tpos(full.mask(:)==1),[1 sum(full.mask(:)==1)])];
		meta.orientation_tfreq = [meta.orientation_tfreq reshape(full.orientation_tfreq(full.mask(:)==1),[1 sum(full.mask(:)==1)])];
		meta.scale_tfreq = [meta.scale_tfreq reshape(full.scale_tfreq(full.mask(:)==1),[1 sum(full.mask(:)==1)])];
	end
end

function out=structreshape_inv(in,sizein)
	% Restore original size of coeffs
	out.coeffs=reshape(in.coeffs,sizein);
	out.mask=reshape(in.mask,sizein(1:end-1));
	out.orientation_tpos=reshape(in.orientation_tpos,sizein(1:end-1));
	out.scale_tpos=reshape(in.scale_tpos,sizein(1:end-1));
	out.orientation_tfreq=reshape(in.orientation_tfreq,sizein(1:end-1));
	out.scale_tfreq=reshape(in.scale_tfreq,sizein(1:end-1));
end

function [out,sizeout]=structreshape_fwd(in)
	% Save original size of coeffs (same for related variables except for last)
	sizeout=size(in.coeffs);

	% Collapse all dimensions that are not first
	out.coeffs=reshape(in.coeffs,sizeout(1),prod(sizeout)/sizeout(1));
	out.mask=reshape(in.mask,sizeout(1),prod(sizeout(1:end-1))/sizeout(1));
	out.orientation_tpos=reshape(in.orientation_tpos,sizeout(1),prod(sizeout(1:end-1))/sizeout(1));
	out.scale_tpos=reshape(in.scale_tpos,sizeout(1),prod(sizeout(1:end-1))/sizeout(1));
	out.orientation_tfreq=reshape(in.orientation_tfreq,sizeout(1),prod(sizeout(1:end-1))/sizeout(1));
	out.scale_tfreq=reshape(in.scale_tfreq,sizeout(1),prod(sizeout(1:end-1))/sizeout(1));
end

function out=structshiftdim(in,dim)
	n = ndims(in.coeffs);
	
	% Shift all dimensions by dim
	order = mod([0:n-2]+dim,n-1)+1;
	
	% Permute all dimensions except for last
	out.coeffs=permute(in.coeffs,[order n]);

	out.mask=permute(in.mask,order);
	out.orientation_tpos=permute(in.orientation_tpos,order);
	out.scale_tpos=permute(in.scale_tpos,order);
	out.orientation_tfreq=permute(in.orientation_tfreq,order);
	out.scale_tfreq=permute(in.scale_tfreq,order);
end