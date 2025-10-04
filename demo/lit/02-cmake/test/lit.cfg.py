import lit.formats

# 测试名字
config.name = 'My lit Example'
# 使用Shell的方式运行测试
config.test_format = lit.formats.ShTest()
# 测试文件后缀名
config.suffixes = ['.cpp', '.cc']
# 排除文件
config.excludes = []
# 测试的源文件目录
# 测试的执行文件目录(这里不需要，使用系统自带的命令)
config.test_source_root = os.path.dirname(__file__)
config.test_exec_root = os.path.join(config.obj_root, 'test')

# 修改环境变量
config.substitutions.append(('%CC', "/usr/bin/cc"))
config.substitutions.append(('%FILECHECK', "/Users/wangyansheng/anaconda3/bin/filecheck"))