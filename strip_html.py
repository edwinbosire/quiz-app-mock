import json
import re

# Load the JSON data from the file
with open('QuizUp-Mock/Repository/book_index.json') as f:
    data = json.load(f)

# Remove HTML tags from the explanation field
for obj in data['data']:
    obj['explanation'] = re.sub('<[^<]+?>', '', obj['explanation'])

# Write the updated data to a new JSON file
with open('QuizUp-Mock/Repository/explanation.json', 'w') as f:
    json.dump(data, f)

