%AUDIO_NEXT_BANDS The next band to decompose for an audio filter bank

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

function j2 = audio_next_bands(j1,Q,a,J,P,bwm)
	D1 = log(2*Q/bwm)/log(a);

	if j1 < J-D1
		j2 = j1+D1;
	elseif j1 < J 
		j2 = J+P*(1-(a.^(J-j1)*bwm)/(2*Q));
	else
		j2 = J+P*(1-bwm/(2*Q));
	end

	j2 = ceil(j2-1e-6);
end
