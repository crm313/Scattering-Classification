%CAUCHY Evaluates a cauchy function on omega

% Copyright 2011-2012, CMAP, Ecole Polytechnique
% Contributors: Laurent Sifre
%
% This software is governed by the CeCILL license under French law and
% abiding by the rules of distribution of free software.  You can  use, 
% modify and/ or redistribute the software under the terms of the CeCILL
% license as circulated by CEA, CNRS and INRIA at the following URL
% "http://www.cecill.info". 
%
% The fact that you are presently reading this means that you have had
% knowledge of the CeCILL license and that you accept its terms.

function cau=cauchy(omega,options)
	% lambda controls the maximum discontinuity of the filter at 2*pi
	lambda = getoptions(options,'cauchy_lambda',0.01);
	% p control the selectivity of the filter
	p = getoptions(options,'cauchy_order',2);

	epsilon = lambda^(1/p) / exp(1);
	m = -log(epsilon) + log(-log(epsilon));
	sc = m/(2*pi);

	cau= (sc* omega).^p .* exp( - p*(sc*omega-1));
end