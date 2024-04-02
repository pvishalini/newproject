from flask import Flask, render_template, request

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('test.html')

@app.route('/submit', methods=['POST'])
def submit():
    first_name = request.form['first_name']
    last_name = request.form['last_name']
    full_name = f"{first_name} {last_name}"
    return render_template('test.html', full_name=full_name)

if __name__ == '__main__':
    app.run(debug=True)
