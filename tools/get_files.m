function [filepaths, labels] = get_files(directory)
%    Find indices of nearest values in a reference array to a target array.
%
%    Parameters
%    ----------
%    directory : string
%        Path of data directory with labels as subdirectories
%
%    Returns
%    -------
%    filepaths : I x N(i) cell array of cell arrays
%        Cell array containing a cell arrays of filepaths to wav files for
%        each instrument
%    labels : 1 x N cell array
%        Cell array of instrument labels
    labels = get_dirs(directory);
    
    filepaths = cell(size(labels));
    for i = 1:length(labels)
        instrument_dir = fullfile(directory, labels{i});
        files = dir(fullfile(instrument_dir, '*.wav'));
        filepaths{i} = fullfile(instrument_dir, {files.name});
    end
    
end