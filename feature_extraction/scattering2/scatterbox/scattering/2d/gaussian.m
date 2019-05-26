%function g = gaussian(x,options)

% Copyright 2011-2012, CMAP, Ecole Polytechnique
% Contributors: Laurent Sifre, Joan Bruna
%
% This software is governed by the CeCILL license under French law and
% abiding by the rules of distribution of free software.  You can  use, 
% modify and/ or redistribute the software under the terms of the CeCILL
% license as circulated by CEA, CNRS and INRIA at the following URL
% "http://www.cecill.info". 
%
% The fact that you are presently reading this means that you have had
% knowledge of the CeCILL license and that you accept its terms.

function g = gaussian(x,options)
	sigma=getoptions(options,'gaussian_sigma',0.5); % good tradeoff for 4 orientations
	g=exp(-x.^2 /(2*sigma^2) );
end
