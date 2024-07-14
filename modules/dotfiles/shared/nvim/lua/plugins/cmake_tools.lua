require("cmake-tools").setup({
{{@if {{#OS}} == "macOS"}}
    cmake_build_directory = "build/${kit}/${variant:buildType}",
{{@elif {{OS}} == "linux"}}
    cmake_build_directory = "build/${kit}/${variant:buildType}",
{{@else}}
    cmake_build_directory = string.format(
        "/local0/home/iilak/prg/build_folders/%s/${kit}/${variant:buildType}",
        vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    ),
{{@fi}}
    cmake_kits_path = "~/.config/cmake/cmake-kits.json"
})
