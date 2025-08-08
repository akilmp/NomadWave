from flask import Flask, Response
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)
co2_per_request = Counter(
    'co2_per_request',
    'Estimated grams of CO2 emitted per request'
)

@app.after_request
def track_co2(response):
    # In a real service this value would be calculated per request
    co2_per_request.inc(0.001)
    return response

@app.route('/metrics')
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

@app.route('/')
def index():
    return 'OK'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
