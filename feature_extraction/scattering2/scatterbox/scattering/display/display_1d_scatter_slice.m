%DISPLAY_1D_SCATTER_SLICE Shows the scattering vector of a time-slice
%   display_1d_scatter_slice(in,meta,ts,options) displays the first- and
%   second-order coefficients of a scattering vector in with metadata meta for
%   a given point in time ts (or the average of multiple time points). This is
%   done by displaying the first order frequency vertically for the first and
%   second order and the second order frequency horizontally.
%
%   The following options can be specified
%      options.display_with_log - When set to 1, instead of displaying the 
%         value of the coefficents, its logarithm is displayed. [default 1]

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

function display_1d_scatter_slice(in,meta,ts,options)
	if nargin < 3
		ts = [];
	end
	
	if nargin < 4
		options = struct();
	end
	
	with_log = getoptions(options,'display_with_log',1);
	
	% What time points?
	if isempty(ts)
		ts = 1:size(in,1);
	end
	
	% How many scales do we have?
	M = sum(meta.order==1);
	
	% Average the time points, if multiple
	in = mean(in(ts,:),1);
	
	in = in/norm(in(:));
	
	% Display logarithm?
	if with_log
		in = log10(abs(in)+1e-4);
	end
	
	% Plot first order, vertical
	subplot(1,8,1);
	imagesc([1 1],[M 1],in(meta.order==1).');
	set(gca,'XTick',[]);
	set(gca,'YDir','normal');
	ylabel('\omega_1');
	title('q=1');
	
	% Plot second order with first frequency on vertical and second on horizontal
	subplot(1,8,2:8);
	A = -ones(M)*Inf;
	A(1+meta.scale(meta.order==2)) = in(meta.order==2);
	A = A(min(mod(meta.scale(meta.order==2),M))+1:end,:);
	imagesc([1 size(A,1)],[M 1],A(end:-1:1,:).',[-4 0]);
	set(gca,'YTick',[]);
	set(gca,'YDir','normal');
	xlabel('\omega_2');
	title('q=2');
end