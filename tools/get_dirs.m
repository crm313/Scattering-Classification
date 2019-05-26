function dir_names = get_dirs(parent_dir)
    dir_info = dir(parent_dir);
    is_dir = [dir_info.isdir];
    dir_names = {dir_info(is_dir).name};
    dir_names(ismember(dir_names,{'.','..'})) = [];
end