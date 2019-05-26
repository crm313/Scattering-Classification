%AUDIO_DOWNSAMPLING The downsampling factor for an audio filter bank

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

function ds = audio_downsampling(j1,Q,a,J,P,bwm)
	ds = floor(min(j1,J)*log2(a)+log2(2*Q)-log2(bwm)+1e-6);
end
