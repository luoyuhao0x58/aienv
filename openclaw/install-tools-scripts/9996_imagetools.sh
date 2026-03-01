#! /bin/bash

# graphviz
apt install -y python3-graphviz

# plantuml
mkdir -p /opt/plantuml
sudo wget https://v6.gh-proxy.org/https://github.com/plantuml/plantuml/releases/latest/download/plantuml.jar -O /opt/plantuml/plantuml.jar
echo '#! /bin/bash
exec java -Djava.awt.headless=true -jar /opt/plantuml/plantuml.jar "$@"
' > /usr/local/bin/plantuml
chmod a+x /usr/local/bin/plantuml

# matplotlib
apt install -y python3-matplotlib

# lilypond
apt install -y lilypond

# pic tools
apt install -y imagemagick python3-pil

# OCR
# 依赖过多，需要整合，后续再改。
# python3 -m venv /opt/ocr
# /opt/ocr/bin/pip install paddle paddleocr ddddocr