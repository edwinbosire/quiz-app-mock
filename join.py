import json

# Load the explanation data from the file
with open('QuizUp-Mock/Repository/explanation.json') as f:
    explanation_data = json.load(f)['data']

# Load the question data from the file
with open('QuizUp-Mock/Repository/questions.json') as f:
    question_data = json.load(f)['data']

# Pair the explanation and question objects based on their ids
paired_questions = []
for question in question_data:
    for explanation in explanation_data:
        if explanation['id'] == int(question['book_section_id']):
            paired_question = {
                'question_id': int(question['question_id']),
                'book_section_id': int(question['book_section_id']),
                'category': int(question['category']),
                'question': question['question'],
                'year': question['year'],
                'choices': question['choices'],
                'correct': question['correct'],
                'explanation': {
                    'id': explanation['id'],
                    'explanation': explanation['explanation']
                }
            }
            paired_questions.append(paired_question)
        else:
          unpaired_question = {
                'question_id': int(question['question_id']),
                'book_section_id': int(question['book_section_id']),
                'category': int(question['category']),
                'question': question['question'],
                'year': question['year'],
                'choices': question['choices'],
                'correct': question['correct'],
                'explanation': None,
            }
          paired_questions.append(unpaired_question)

# Write the paired questions to a new file
question_objects = [question for question in paired_questions]
with open('QuizUp-Mock/Repository/questions-new.json', 'w') as f:
    json.dump({'data': question_objects}, f)
