%DCT_MASK Computes a mask on the DCT representation of a scattering vector
%   mask = dct_mask(meta,options) takes as input the metainformation from 
%   transform_scatt and a set of mask paremeters in options. It uses these to
%   create a mask of the DCT coefficients that selects the low-frequency (in
%   the sense of DCT frequency) components.
%
%   The mask parameters are found in options.dct_mask . These consist of four
%   values: a1, a2, b1 and b2. The first two, a1 and a2 specify a rectangle
%   in the DCT coefficient space, while b1 and b2 specify another rectangle.
%   The mask is then the union of these two rectangles. If we have J+P filters
%   in our wavelet decomposition, the first rectangle contains the
%   coefficients with k_1 (the DCT transform of j_1) less than a1*(J+P) and k_2
%   less than a2. In the same way, the second rectangle contains the
%   coefficients such that k_1 < b1*(J+P) and k_2 < b2. Default values are
%   a1 = 0.4, a2 = 3, b1 = 0.05, b2 = 6.

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

function mask = dctmask(meta,options)
	if nargin < 2
		options = struct();
	end

	order = meta.order;
	scale = meta.scale_tfreq;
	
	dct_mask = getoptions(options,'dct_mask',struct());
	a1 = getoptions(dct_mask,'a1',0.4);
	a2 = getoptions(dct_mask,'a2',3);
	b1 = getoptions(dct_mask,'b1',0.05);
	b2 = getoptions(dct_mask,'b2',6);
	
	J = max(scale(order==1))+1;
	
	mask = false(size(order));
	
	if 1 <= getoptions(options,'M',2)
		mask(order==1&scale<a1*J) = true;
	end
	if 2 <= getoptions(options,'M',2)
		mask(order==2&((floor(scale/J)<a1*J&mod(scale,J)<a2)|(floor(scale/J)<b1*J&mod(scale,J)<b2))) = true;
	end
end