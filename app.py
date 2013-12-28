from flask import Flask, render_template

from subprocess import call

app = Flask(__name__)

@app.route("/")
def home():
  return render_template("pianobar_control.html", owner_name="Robert") 

@app.route("/explain")
def explain():
  call("echo 'e' > ~/.config/pianobar/ctl", shell=True)
  return "Check the console"

@app.route("/info")
def info():
  call("echo 'i' > ~/.config/pianobar/ctl", shell=True)
  return "Check the console!"

if __name__ == "__main__":
  app.run(host='0.0.0.0', port=8082,debug=True)
