# 生成配置文件，只替换前后是@和@的内容。
configure_file(lit.site.cfg.py.in lit.site.cfg.py @ONLY)

# 添加一个自定义目标，用于运行测试。
# 显示进度和信息。
# 读区BIN目录下面的配置文件。
add_custom_target(check
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/llvm-lit "${CMAKE_CURRENT_BINARY_DIR}" -sv)