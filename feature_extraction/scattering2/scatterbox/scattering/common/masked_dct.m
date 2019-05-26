%MASKED_DCT Computes a DCT on coefficients according to a specified mask.

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

function out = masked_dct(in,dim,m)
	% Reshape coefficient matrix to get transform dimension, 
	% collapsed non-transform dimensions, and pixel dimension
	in.coeffs = reshape(in.coeffs,[size(in.mask) numel(in.coeffs)/prod(size(in.mask))]);

	out = in;
	% For each non-transform index, determine the length of the transform.
	mask_length = sum(in.mask==1,1);
	
	% Is the transform dimension an orientation dimension or scale?
	is_orientation = (dim<m);
	dim = mod(dim,m);
	
	M = size(in.mask,1);
	
	for dct_length=unique(mask_length)
		if dct_length <= 1
			continue;
		end
		
		% Determine which non-transform indices to extract and what transform indices
		% NOTE: This assumes that the transform indices are the same for each column
		column_mask = find(mask_length==dct_length);
		dct_mask = find(in.mask(:,column_mask(1))==1);
		
		% Flip the indices so that low DCT frequencies end up at the low "regular" 
		% frequency positions
		dct_mask = dct_mask(end:-1:1);
		
		% Extract, transform & reinsert
		slice = in.coeffs(dct_mask,column_mask,:);
		slice = reshape(slice,[length(dct_mask) length(column_mask)*size(in.coeffs,3)]);
		slice = dct(slice);
		slice = reshape(slice,[length(dct_mask) length(column_mask) size(in.coeffs,3)]);
		out.coeffs(dct_mask,column_mask,:) = slice;
		
		if is_orientation
			out.orientation_tpos(dct_mask,column_mask) = out.orientation_tpos(dct_mask,column_mask)-mod(floor(out.orientation_tpos(dct_mask,column_mask)/M^dim),M)*M^dim;
			out.orientation_tfreq(dct_mask,column_mask) = out.orientation_tfreq(dct_mask,column_mask)+repmat([0:length(dct_mask)-1]',[1 length(column_mask)])*M^dim;
		else
			out.scale_tpos(dct_mask,column_mask) = out.scale_tpos(dct_mask,column_mask)-mod(floor(out.scale_tpos(dct_mask,column_mask)/M^dim),M)*M^dim;
			out.scale_tfreq(dct_mask,column_mask) = out.scale_tfreq(dct_mask,column_mask)+repmat([0:length(dct_mask)-1]',[1 length(column_mask)])*M^dim;
		end
	end
	
	% Restore original dimensions by combining non-transform dimensions with pixel dimension
	out.coeffs = reshape(out.coeffs,[size(in.mask,1) numel(out.coeffs)/size(in.mask,1)]);
end

