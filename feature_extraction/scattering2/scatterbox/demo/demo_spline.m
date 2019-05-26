% Load and prepare a sample signal
load handel;
y = y(1:2^floor(log2(length(y))));
y = y/norm(y);

% Initialize filter bank
opt.M = 3;
opt.spline_order = 3;
opt.J = 10;
opt.filters = spline_filter_bank(size(y),opt);

% Specify antialiasing & path 
opt.aa = 1;
opt.aa_psi = 1;

% Calculate scattering vector
[sc,meta] = scatt(y,opt);

% We should conserve at least 99% of the energy
fprintf('Energy captured in scattering: %f\n',norm(sc(:))^2);
