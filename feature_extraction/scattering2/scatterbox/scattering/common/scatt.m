%SCATT Scattering transform wrapper
%   [out,meta] = scatt(in,options) calculates the scattering coefficients of
%   in using parameters in options and performs the necessary pre- and 
%   post-processing.
%
%   For scattering options, see core_scatt for details.
%
%   The output is presented in the format specified by options.format. 
%   Possible formats are the following [default 'split']:
%       - 'raw' simply outputs the result of core_scatt without modifying it.
%         The variable meta is unused in this format.
%       - 'split' outputs the result of core_scatt in the form of a table. In
%         the case of 1D input, the output is two-dimensional with the first
%         dimension corresponding to the signal domain and the second 
%         dimension corresponding to the path space. For 2D input, the 
%         structure is the same except for the output being three-dimensional 
%         and the first two dimensions corresponding to the signal domain. 
%         The meta structure contains three variables parametrized by the 
%         path space: 'order' which specifies the order of the path from 0 to
%         M, 'scale' which encodes the successive scales in the path, and 
%         'orientation' which encodes the successive orientations. Scale and
%         resolution are specified in base M, where M is the maximal 
%         scale/resolution and the most significant digit corresponding so 
%         the first path component.
%       - 'array' outputs the same table as the format 'split', but collapsed
%         into a column vector.

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

function [out,meta] = scatt(in,options)
	if nargin < 2
		options = struct();
	end

	format = getoptions(options,'format','split');

	% Make sure 1D input is a column vector
	if sum(size(in)>1) == 1 && size(in,1) < size(in,2)
		in=in(:);
	end
	
	% Perform the scattering transform
	transf = core_scatt(in,options);

	% If format is raw, just output result from core_scatt
	if strcmp(format,'raw')
		out = transf;
		meta = [];
		return;
	end
	
	% Otherwise, create a table of signals ordered by path raster
	out = zeros([size(transf{1}{1}.signal) number_of_paths(transf)]);
	raster = 1;
	for s = 1:length(transf)
		for ss = 1:length(transf{s})
			% Store signal and meta-information
			out(:,:,raster) = transf{s}{ss}.signal;
			meta.order(raster) = s-1;
			meta.scale(raster) = transf{s}{ss}.meta.scale;
			meta.orientation(raster) = transf{s}{ss}.meta.orientation;
			raster = raster+1;
		end
	end
	
	% Remove singleton dimensions
	out = squeeze(out);
	
	% Convert into column vector
	if strcmp(format,'array')
	    out = out(:);
	end
end

function path_count = number_of_paths(in)
	path_count = 0;
	S = size(in);

	for s = 1:S(2)
		path_count = path_count+size(in{s},2);
	end
end

