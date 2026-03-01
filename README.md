# AI 使用环境打包

## 初始化

- 启动程序

```bash
# 获取代码
git clone xxx.git aienv && cd aienv
# 构建镜像
docker compose build
# 配置环境变量
echo '
CLAWHUB_TOKEN=xxx # 你 CLAWHUB 的 token，如果没有，可以去官网注册一个，否则不会在启动的时候安装一些有用的 SKILL
' > .env
# 启动容器
docker compose up -d
```

- openclaw 配置

```shell
# 进入容器
docker compose exec -it openclaw bash
# 配置模型（按提示按需选择）
openclaw configure --section model
# 配置渠道（按提示按需选择）
openclaw configure --section channels
```

- 其它配置（工具或者技能，可选）

`docker compose exec -it openclaw bash` 进入容器， 写入 `~/.openclaw/.env` 文件。

```shell
TAVILY_API_KEY=xxx  # 可选，用于 Tavily 搜索的 API
```

## 默认安装的工具能力

- 编程运维工具
  - 编程语言
    - c/c++
    - python
    - nodejs
    - java
    - golang
    - rust
  - 数据库客户端
    - mysql
    - postgresql
    - redis
    - mongodb
  - 容器工具客户端
    - docker
    - kubectl
- 文档处理（支持一下格式读写和转换）
  - xlsx
  - docx
  - pptx
  - rss
  - xml
  - json
  - yaml
  - pdf
- 图形能力
  - 画图
    - graphviz
    - plantuml
    - matplotlib
    - lilypond
    - 常见图片格式的读写修改和转换
- 语音能力
  - funasr 用于语音识别成文本
- 视频
  - ffmpeg 视频合成和转换
- chromium 用于智能体的网页浏览,已安装了CJK字体
- playwright 用于自动化浏览器操作

## 默认安装的 SKILL

- web-search-plus 用于提升 web 搜索的体验
- beauty-generation-api 用于目前免费的文生图服务
- edge-tts 用于目前的文字转语音服务
- self-improving 智能体自我提升