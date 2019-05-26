%GETOPTIONS Extracts options from a struct and provides a default value

% Copyright 2011-2012, CMAP, Ecole Polytechnique
% Contributors: Gabriel Peyré, Joakim Andén
%
% This software is governed by the CeCILL license under French law and
% abiding by the rules of distribution of free software.  You can  use, 
% modify and/ or redistribute the software under the terms of the CeCILL
% license as circulated by CEA, CNRS and INRIA at the following URL
% "http://www.cecill.info". 
%
% The fact that you are presently reading this means that you have had
% knowledge of the CeCILL license and that you accept its terms.

function value = getoptions(options,name,default_value)
	value = [];
	
	if isfield(options, name)
	    value = getfield(options,name);
	end
	
	if isempty(value)
		value = default_value;
	end
end