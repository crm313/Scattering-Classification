cwd = mfilename('fullpath');
cwd = cwd(1:find(cwd=='/',1,'last'));

addpath([cwd 'audio']);
addpath([cwd 'demo']);
addpath([cwd 'scattering/1d']);
addpath([cwd 'scattering/2d']);
addpath([cwd 'scattering/common']);
addpath([cwd 'scattering/display']);