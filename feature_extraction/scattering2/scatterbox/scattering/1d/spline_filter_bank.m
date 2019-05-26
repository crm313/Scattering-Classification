%SPLINE_FILTER_BANK Create a filter bank of spline wavelets
%   filters = spline_filter_bank(sizein,options) generates a spline wavelet
%   (linear,cubic) filterbank for signals of size sizein using parameters 
%   contained in options.
%
%   The following options can be specified
%      options.J - The maximal scale of the filters, giving a maximal temporal
%         support of 2^(J-1) [default 4]
%      options.spline_order - If 1, generates linear splines and if 3
%         generates cubic splines [default 3]

% Copyright 2011-2012, CMAP, Ecole Polytechnique
% Contributors: Laurent Duvernet, Joakim Andén
%
% This software is governed by the CeCILL license under French law and
% abiding by the rules of distribution of free software.  You can  use, 
% modify and/ or redistribute the software under the terms of the CeCILL
% license as circulated by CEA, CNRS and INRIA at the following URL
% "http://www.cecill.info". 
%
% The fact that you are presently reading this means that you have had
% knowledge of the CeCILL license and that you accept its terms.

function filters = spline_filter_bank(sizein,options)
	if nargin < 2
		options = struct();
	end
	
	N = max(sizein);
	
	a = 2;
	J = getoptions(options,'J',4);
	spline_order = getoptions(options,'spline_order',3);
	
	% Create function S needed to define spline wavelets
	if spline_order == 1
		S = @(omega)((1+2*cos(omega/2).^2)./(48*sin(omega/2).^4));
		S2pi = 2^4;
	elseif spline_order == 3
		S = @(omega)((5+30*cos(omega/2).^2+30*sin(omega/2).^2.*cos(omega/2).^2+70*cos(omega/2).^4+ ...
			2*sin(omega/2).^4.*cos(omega/2).^2+2/3*sin(omega/2).^6)./(105*2^8*sin(omega/2).^8));
		S2pi = 2^8;
	else
		error('Only linear and cubic splines supported!');
	end
	
	psif = {};
	phif = {};
	
	% For all possible resolutions (original size divided by powers of 2)
	for j0 = 0:floor(log2(N))
		N0 = N/2^j0;
		
		% Have we gone further than the largest scale?
		if N0 <= N/2^J;
			continue;
		end
		
		epsilon = 0;
		
		omega = [0:N0-1]'/N0*2*pi;
		
		for j1 = j0:J-1
			% Define spline wavelet
			if j1 == j0
				omega1 = a^(j1+1-j0)*omega;
				psif{j0+1}{j1+1}{1} = sqrt(2)*exp(-i*epsilon*omega1/2)./omega1.^(spline_order+1).* ...
					sqrt(S(omega1/2+pi)./(S(omega1).*S(omega1/2)));
				psif{j0+1}{j1+1}{1}(1) = 0;
				k2pi = N0/a^(j1+1-j0);
				pts = 1+k2pi:k2pi:N0/2+1;
				psif{j0+1}{j1+1}{1}(pts) = sqrt(2)*exp(-i*epsilon*omega1(pts)/2)./omega1(pts).^(spline_order+1).* ...
					sqrt(S2pi./S(omega1(pts)/2));
			else
				omega1 = a^(j1+1-j0)*omega(1:N0/2);
				psif{j0+1}{j1+1}{1} = [sqrt(2)*exp(-i*epsilon*omega1/2)./omega1.^(spline_order+1).* ...
					sqrt(S(omega1/2+pi)./(S(omega1).*S(omega1/2))) ; zeros(N0/2,1)];
				psif{j0+1}{j1+1}{1}(1) = 0;
				k2pi = N0/a^(j1+1-j0);
				pts = 1+k2pi:k2pi:N0/2;
				psif{j0+1}{j1+1}{1}(pts) = sqrt(2)*exp(-i*epsilon*omega1(pts)/2)./omega1(pts).^(spline_order+1).* ...
					sqrt(S2pi./S(omega1(pts)/2));
			end

			% Correct problematic points
			%if spline_order == 1
			%	k2pi = N0/a^(j1+1-j0);
			%	psif{j0+1}{j1+1}{1}(1:2*k2pi:N0/2) = 0;
			%	psif{j0+1}{j1+1}{1}(k2pi+1:2*k2pi:N0/2) = -sqrt(2)*pi^(-2)*16*sqrt(3)./(4*[0:N0/(4*k2pi)-1]+2).^2;
			%	if j1 == j0
			%		psif{j0+1}{j1+1}{1}(N0/2+1) = -sqrt(2)*pi^(-2)*4*sqrt(3);
			%	end
			%end

			%if spline_order == 3
			%	k2pi = N0/a^(j1+1-j0);
			%	psif{j0+1}{j1+1}{1}(1:2*k2pi:N0/2) = 0;
			%	psif{j0+1}{j1+1}{1}(k2pi+1:2*k2pi:N0/2) = -sqrt(2)*pi.^(-4) * 2^8*3*sqrt(35/17)*1./(4*[0:N0/(4*k2pi)-1]+2).^4;
			%	if j1 == j0
			%		psif{j0+1}{j1+1}{1}(N0/2+1) = -sqrt(2)*pi.^(-4) * 2^4*3*sqrt(35/17);
			%	end
			%end
		end
		
		% Define lowpass filter
		omega = [0:N0/2 -N0/2+1:-1]'/N0*2*pi;
		omega1 = a^(J-j0)*omega;
		phif{j0+1} = 1./(omega1.^(spline_order+1).*sqrt(S(omega1)));
		phif{j0+1}(1) = 1;
	end

	filters.type = 'spline-1d';
	
	filters.psi = psif;
	filters.phi = phif;

	filters.a = a;
	filters.J = J;
end
