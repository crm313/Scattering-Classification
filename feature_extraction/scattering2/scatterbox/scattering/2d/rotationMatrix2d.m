%function Rotmat = rotationMatrix2d(theta)

% Copyright 2011-2012, CMAP, Ecole Polytechnique
% Contributors: Joan Bruna, Laurent Sifre
%
% This software is governed by the CeCILL license under French law and
% abiding by the rules of distribution of free software.  You can  use, 
% modify and/ or redistribute the software under the terms of the CeCILL
% license as circulated by CEA, CNRS and INRIA at the following URL
% "http://www.cecill.info". 
%
% The fact that you are presently reading this means that you have had
% knowledge of the CeCILL license and that you accept its terms.

function Rotmat = rotationMatrix2d(theta)
	%in the usual setting it should be the inverse but matlab work with the other orientation...
	Rotmat=[cos(theta) sin(theta) ; - sin(theta) cos(theta) ];
end
