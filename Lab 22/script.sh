#!/bin/bash
sudo yum update -y
sudo yum install pip -y
sudo yum install -y python3
sudo pip install flask
cat <<EOF > /home/ec2-user/app.py
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return "Hi, this is a TCP app"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
EOF

# Allows the app runs as a background process
sudo nohup python3 /home/ec2-user/app.py > /dev/null 2>&1 &
