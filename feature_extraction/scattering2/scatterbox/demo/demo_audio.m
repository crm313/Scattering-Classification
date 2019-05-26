N = 2^16;

% Load and prepare a sample signal
load handel;
y = y(1:N);
y = y/norm(y);

% Initialize filter bank
opt.M = 2;					% Scattering order
opt.Q = 16;					% Q-factor of filter
opt.J = 80;					% Maximal scale corresponding to T=Q*2^(J/Q+1),
							% here it's 1024
opt.filters = audio_filter_bank([N 1],opt);

% Specify antialiasing & path 
opt.aa = 1;
opt.aa_psi = 2;
opt.delta = -opt.Q;

% Calculate scattering vector
[sc,meta] = scatt(y,opt);

% We should conserve at least 95% of the energy
fprintf('Energy captured in scattering: %f\n',norm(sc(:))^2);

% Display 3rd 'slice' of scattering
figure(1);display_1d_scatter_slice(sc,meta,3);

% Display time-average of scattering
figure(2);display_1d_scatter_slice(sc,meta);

% Display a time-frequency image
figure(3);scattergram(y,opt,48);

% Compute log-scattering coefficients
sc = log(abs(sc)+1e-12);

% Perform a DCT on each log-scattering vector
[sc,meta] = transform_scatt(sc,meta,opt);

% Create a mask using the default parameters
mask = dctmask(meta,opt);

% Extract the relevant coefficients
scp = sc(:,mask);

% Define a looser mask & use it
opt.dct_mask.a1 = 0.5;
opt.dct_mask.a2 = 2;
opt.dct_mask.b1 = 0.15;
opt.dct_mask.b2 = 9;
mask = dctmask(meta,opt);
scp = sc(:,mask);

% Or use cl_scatt to get cosine log-scattering coefficients directly
scb = cl_scatt(y,opt);

if norm(scp(:)-scb(:)) > 1e-10
	error('Norms should match!');
end

% Reconstruct (sort of) the example from the DAFx paper
y = wavread('modulation.wav');

opt.Q = 4;
opt.a = 2^(1/8);
opt.J = 10*8;
opt.filters = audio_filter_bank(size(y),opt);
opt.aa_psi = 2;
opt.delta = -opt.Q;

figure(4);scattergram(y,opt,18);