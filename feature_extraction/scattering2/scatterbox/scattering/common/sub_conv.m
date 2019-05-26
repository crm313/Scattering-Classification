%SUB_CONV Calculates a convolution & subsamples result

% Copyright 2011-2012, CMAP, Ecole Polytechnique
% Contributors: Joakim Andén
%
% This software is governed by the CeCILL license under French law and
% abiding by the rules of distribution of free software.  You can  use, 
% modify and/ or redistribute the software under the terms of the CeCILL
% license as circulated by CEA, CNRS and INRIA at the following URL
% "http://www.cecill.info". 
%
% The fact that you are presently reading this means that you have had
% knowledge of the CeCILL license and that you accept its terms.

function out = sub_conv(in,fin,flt,ds)
	if ~isvector(in)
		ifourier = @ifft2;
		convolution = @conv2;
	else
		ifourier = @ifft;
		convolution = @conv;
	end

	if ~isstruct(flt)
		f = flt;
		
		flt = struct();
		flt.flt = f;
		flt.type = 'fourier';
	end

	switch flt.type
		case 'fourier'
			out = ifourier(fin.*flt.flt);
		case 'space'
			out = convolution(in,flt.flt,'same');
		case 'fourier-subsample'
			if ~flt.do_periodic(log2(ds)+1)
				out = ifourier(fin.*flt.flt0);
			else
				if flt.M == 1
					fin = reshape(fin,[flt.N/ds,1,ds]);
				else
					fin = reshape(fin,[flt.N/ds,ds,flt.M/ds,ds]);
					fin = permute(fin,[1 3 2 4]);
					fin = reshape(fin,[flt.N/ds,flt.M/ds,ds^2]);
				end
				fin = fin(:,:,flt.inds{log2(ds)+1});
				out = squeeze(ifourier(sum(fin.*flt.flt{log2(ds)+1},3)))/sqrt(ds);
				if flt.M > 1
					out = out/sqrt(ds);
				end
			end
		otherwise
			error('Invalid convolution type');
	end

	if (~strcmp(flt.type,'fourier-subsample') || ~flt.do_periodic(log2(ds)+1)) && ds>1
		if size(out,2) > 1
			out = out(1:ds:end,1:ds:end)*(ds);
		else
			out = out(1:ds:end)*sqrt(ds);
		end
	end
end
