local number_of_parallel_threads = 14
local cmake_usr_args_dict = {
    CONAN = "ON",
    CONAN_DISABLE_CHECK_COMPILER = "ON",
}

vim.g.cmake_build_path_pattern = { '~/prg/build_folders/%s/%s/%s',
    "fnamemodify( getcwd(), ':t' ), g:cmake_selected_kit, g:cmake_build_type" }

{{@if {{#work}}}}
{{@if {{#work}} == "maxwell" }}

vim.g.cmake_build_path_pattern = { '/local0/home/iilak/prg/build_folders/%s/%s/%s',
    "fnamemodify( getcwd(), ':t' ), g:cmake_selected_kit, g:cmake_build_type" }

{{@else}}

vim.g.cmake_build_path_pattern = { '/local0/home/iilak/prg/build_folders/%s/%s/%s',
    "fnamemodify( getcwd(), ':t' ), g:cmake_selected_kit, g:cmake_build_type" }

{{@fi}}
{{@fi}}

vim.g.cmake_build_executor_window_size = 80
vim.g.cmake_build_executor_split_mode = 'vsp'
vim.g.cmake_build_executor = "term"
vim.g.cmake_compile_commands_link = vim.fn.getcwd()

vim.g.cmake_variants = {
    debug = {
        cmake_build_type = 'Debug',
        cmake_build_args = string.format('--parallel %s', number_of_parallel_threads),
        cmake_usr_args = cmake_usr_args_dict
    },
    release = {
        cmake_build_type = 'Release',
        cmake_build_args = string.format('--parallel %s', number_of_parallel_threads),
        cmake_usr_args = cmake_usr_args_dict
    }
}
