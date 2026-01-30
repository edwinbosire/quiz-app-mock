# UX Wireframe Flows – Spaced Repetition Flashcards (SRS)

## 1. Entry Points (How Users Discover Flashcards)

### Entry Point A — Tab Bar
```
[ Home ] [ Exams ] [ Flashcards ] [ Profile ]
```
- Flashcards is a first-class tab
- Badge indicator shows number of cards due today (e.g. 🔴 5)

---

### Entry Point B — Exam Bookmarking
```
Exam Question Screen
────────────────────────
Q: What year was Magna Carta signed?

(A) 1215
(B) 1315
(C) 1415
(D) 1515

[ Bookmark ☆ ]   [ Next ]
```
**Action**
- Tap ⭐ Bookmark
- Toast: “Saved to Flashcards”

---

### Entry Point C — Push Notification
```
🧠 6 cards ready for review
3 minutes is all you need
```
Tap → Opens Review Session (Due Cards)

---

## 2. Flashcards Home Screen

### Purpose
- Show status
- Provide clear “Start Review” CTA
- Allow creation & management

```
Flashcards
────────────────────────
📅 Due Today
[ 6 cards ]   →  Start Review

📊 Progress
Streak: 4 days
Mastered: 128 cards

───────────────
[ + New Card ]
[ Browse All Cards ]
[ Topics ]
```

---

## 3. Review Session Flow (Core Experience)

### 3.1 Review Start
```
Review Session
────────────────────────
6 cards • ~3 minutes

[ Start ]
```

---

### 3.2 Card – Front (Recall Phase)
```
──────── Flashcard ────────
Question
──────────────────────────
What does “Rule of Law” mean?

(Think before flipping)

[ Tap to reveal answer ]
```

---

### 3.3 Card – Back (Answer Phase)
```
──────── Flashcard ────────
Answer
──────────────────────────
That everyone is subject to the law,
including the government.

───────────────
How did you do?

[ ❌ Again ]  [ 😐 Hard ]
[ 🙂 Good ]   [ 😄 Easy ]
```

---

### 3.4 Scheduling Feedback
```
✓ Scheduled again in 5 days
```
Automatically advances to next card.

---

### 3.5 Session Complete
```
🎉 Session Complete
────────────────────────
Reviewed: 6 cards
Next review: Tomorrow

[ Done ]
```

---

## 4. Interleaving Behavior

- Cards mixed by topic, difficulty, and creation source
- No more than 2 cards from same topic consecutively
- Behavior is implicit (no UI explanation)

---

## 5. Manual Card Creation Flow

### Entry
```
Flashcards → + New Card
```

### Create Card Screen
```
New Flashcard
────────────────────────
Question
[ Enter prompt here ]

Answer
[ Enter explanation here ]

Topic (optional)
[ British History ▼ ]

[ Save Card ]
```
- New cards scheduled for first review in 2 days

---

## 6. Bookmark → Flashcard Flow

- Bookmarking during exam auto-creates a card
- Front: Question
- Back: Correct answer + explanation
- Topic auto-assigned
- First review scheduled in 2 days

---

## 7. Browse & Edit Cards

### Browse All Cards
```
All Flashcards
────────────────────────
🔍 Search cards

• Rule of Law
  Topic: UK Values

• Magna Carta
  Topic: History

• Parliament Roles
  Topic: Government
```

### Card Detail / Edit
```
Flashcard
────────────────────────
Question
What is Habeas Corpus?

Answer
Protection against unlawful detention

Topic
UK Law

[ Edit ]
[ Delete ]
```
- Editing a card resets its SRS schedule

---

## 8. Notifications UX Flow

- Triggered only if cards are due today
- User has not opened the app yet
- Max 1 per day, 5 per week

Push opens directly into Review Session Start

---

## 9. Empty States

### No Cards Yet
```
No flashcards yet 📭

Bookmark questions during exams
or create your own.

[ + Create First Card ]
```

### No Cards Due Today
```
All done for today 🎉

Next review: Tomorrow

[ Browse Cards ]
```

---

## 10. UX Principles Summary

- One-tap to review
- Forced active recall
- Predictable spacing
- Minimal, relevant notifications
- Progress without guilt

