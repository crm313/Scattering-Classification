%AUDIO_FILTER_BANK Calculates a mel-like filter bank
%   filters = audio_filter_bank(sizein,options) generates a mel-like filter
%   bank for signals of size sizein using parameters contained in options.
%   The filters are wavelets of a cauchy type.
%
%   The following options can be specified
%      options.Q - The Q factor used for the logarithmically spaced filters.
%          [default 16]
%      options.a - The elementary dilation factor for the same filters.
%          [default 2^(1/Q)]
%      options.J - The number of logarithmically spaced filters. Widest
%          wavelet will have support 2*Q*a^J in time.
%          [default log_a(N0/(2*Q))]
%      options.P - The number of linearly spaced low-frequency filters.
%          [default floor(1/log(a)-1)]
%      options.cauchy_order - The order of the lowest-frequency filter
%         in the cauchy wavelet definition. Higher orders have more vanishing
%         moments, but are located at higher frequencies.
%          [default 2]
%      options.lowpass_width - Determines the width of the lowpass filter in
%         the frequency domain. Has to be adjusted in tandem with cauchy_order
%         to achieve a good energy conservation.
%          [default 0.63]

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

function filters = audio_filter_bank(sizein,options)
	if nargin < 2
		options = struct();
	end
	
	N0 = max(sizein);

	% Get the filter options
	Q = getoptions(options,'Q',16);
	a = getoptions(options,'a',2^(1/Q));
	J = getoptions(options,'J',floor(log(N0/2/Q)/log(a)));
	P = getoptions(options,'P',floor(1/log(a)-1));
	
	cauchy_order = getoptions(options,'cauchy_order',2);
		
	lowpass_width = getoptions(options,'lowpass_width',0.63);
	
	% Specify the wavelet & scaling functions
	wavelet = @(N,s)(cauchy_wavelet(N,177.5*(Q/8)^2,s));
	scaling = @(N,s)(cauchy_scaling(N,cauchy_order,s*Q));
	
	% Normalization parameter, set after the first iteration
	lambda_psi = 1;
	
	% For all possible resolutions (original size divided by powers of 2)
	for j0 = 0:floor(log2(N0))
		% For each resolution, starting at N0, then N0/2, etc, we calculate a filter bank
		
		N = N0/2^j0;

		% Stop when we are no longer divisible by 2
		if N>floor(N)+1e-6
			break;
		end
		
		% Initialize filterbank for resolution N/2^j0
		psif{j0+1} = cell(1,J+P);
		
		% Calculate the logarithimically spaced filters, starting at an offset (lower resolutions do not have as many high frequencies)
		offset = round(j0/log2(a));
		for j1 = 0:J-1-offset
			psif{j0+1}{offset+j1+1}{1} = lambda_psi*wavelet(N,a^j1);
		end
		
		% Calculate the linearly spaced filters, if there are any
		if P > 0
			% Interpolate between lowest-frequency logarithmically spaced filter & a low-frequency cauchy wavelet of order options.cauchy_order
			q = sqrt(177.5*(Q/8)^2/cauchy_order);
			for k = 1:P
				% Interpolate so that bandwidth remains constant, but maximum shifts linearly towards 0
				if P > 1, qk = q/(q-(k-1)*(q-1)/(P-1)); else, qk = 1; end
				psik = lambda_psi*cauchy_wavelet(N,177.5*(Q/8)^2/qk^2,a^J*qk*N/N0);
				
				% Determine position of filter & skip if too high or of low value
				[peak,peak_ind] = max(psik);
				if peak_ind <= N/2+1 && peak > 0.5*lambda_psi
					psif{j0+1}{J+k}{1} = psik;
				end
			end
		end
		
		% Normalization, compute the Littlewood-Paley sum and adjust it so that the maximum is 2
		if j0 == 0
			S = zeros(N,1);
		
			% Calculate Littlewood-Paley & normalization constant
			for j1 = offset:length(psif{j0+1})-1-P
				S = S+abs(psif{j0+1}{j1+1}{1}).^2;
			end
			
			lambda_psi = sqrt(2/max(S));
			
			% Renormalize the previously computed filters
			for j1 = offset:length(psif{j0+1})-1
				psif{j0+1}{j1+1}{1} = lambda_psi*psif{j0+1}{j1+1}{1};
			end
		end
		
		% Calculate the lowpass filter phi
		phif{j0+1} = scaling(N,a^J*N/N0/lowpass_width);
	end

	filters.type = 'nondyadic-1d';
	
	filters.psi = psif;
	filters.phi = phif;

	filters.Q = Q;
	filters.a = a;
	filters.J = J;
	filters.P = P;
end

function f = cauchy_wavelet(N,p,s)
	% Calculate cauchy wavelet for a given signal size, filter order and scale
	% \psi(\omega) = \omega^p e^{-p(\omega-1)}
	
	omega = [0:N-1]'/N*2*s;
	f1 = omega.^p; f1(isinf(f1)|isnan(f1)) = 0;
	f2 = exp(-p*(omega-1)); f2(isinf(f2)|isnan(f2)) = 0;
	f = f1.*f2;
end

function f = cauchy_scaling(N,p,s)
	% Calculate cauchy scaling function for a given signal size, filter order and scale
	% \phi(\omega) = \int_\omega^\infty \omega^p e^{-p(\omega-1)}
	
	% Perform partial integration
	omega = [0:N-1]'/N*2*s;
	f = zeros(size(omega));
	for q = 0:p
		f1 = omega.^q; f1(isinf(f1)|isnan(f1)) = 0;
		f2 = 1/p*exp(-p*(omega-1)); f2(isinf(f2)|isnan(f2)) = 0;
		f = q/p*f+f1.*f2;
	end
	
	% Normalize and mirrorize
	f = f/f(1);
	f(2:end) = f(2:end)+f(end:-1:2);
end