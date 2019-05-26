%CL_SCATT Compute the Cosine Log-Scattering (CLS) representation of the input
%   [out,meta] = cl_scatt(in,options) calculates the CLS vector of in using
%   parameters in options. For parameters and return values, see the 
%   documentation of scatt, transform_scatt and dctmask.

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

function [out,meta] = cl_scatt(in,options)
	if nargin < 2
		options = struct();
	end
	
	[out,meta] = scatt(in,options);
	out = log(abs(out)+1e-12);
	[out meta] = transform_scatt(out,meta,options);
	
	mask = dctmask(meta,options);
	out = out(:,mask);
	
	meta.order = meta.order(mask);
	meta.orientation_tpos = meta.orientation_tpos(mask);
	meta.scale_tpos = meta.scale_tpos(mask);
	meta.orientation_tfreq = meta.orientation_tfreq(mask);
	meta.scale_tfreq = meta.scale_tfreq(mask);
end