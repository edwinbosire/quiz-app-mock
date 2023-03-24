import json
from bs4 import BeautifulSoup

# Load the explanation data from the file
with open('QuizUp-Mock/Repository/explanation.json') as f:
    explanation_data = json.load(f)['data']

# Fix broken HTML tags in each explanation
for explanation in explanation_data:
    explanation_text = explanation['explanation']
    soup = BeautifulSoup(explanation_text, 'html.parser')
    explanation['explanation'] = str(soup)

# Write the updated explanation data to the file
with open('QuizUp-Mock/Repository/explanation_fixed.json', 'w') as f:
    json.dump({'data': explanation_data}, f)
