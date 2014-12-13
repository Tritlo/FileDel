default: reqs
	python3 app.py

venv:
	pyvenv venv
reqs: venv
	pip install -r requirements.txt
