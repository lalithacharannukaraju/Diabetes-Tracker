## Diabetes Tracker Backend

Node.js + Express + MongoDB backend for the Diabetes Tracker Flutter app.

### Tech stack

- **Runtime**: Node.js (LTS recommended)
- **Framework**: Express
- **Database**: MongoDB (e.g. MongoDB Atlas or local MongoDB)
- **ORM**: Mongoose
- **Auth**: JWT with bcrypt password hashing

### Data model (high level)

- **User**
  - `username` (unique)
  - `passwordHash`
- **Medicine**
  - `user` (owner)
  - `name`
  - `dosage`
  - `timeHour` (0–23)
  - `timeMinute` (0–59)
  - `weekdays` (array of `1..7`, Mon–Sun)
  - `importance` (`low` | `medium` | `high`)
- **DietEntry**
  - `user`
  - `date` (stored as midnight UTC for a calendar day)
  - `text`
- **TakenMedicine**
  - `user`
  - `medicine`
  - `date` (calendar day when it was taken)

### API overview

All routes (except auth) require an `Authorization: Bearer <token>` header.

- **Auth**
  - `POST /api/auth/register` – body: `{ "username", "password" }` → returns `{ token, user }`
  - `POST /api/auth/login` – body: `{ "username", "password" }` → returns `{ token, user }`
- **Medicines**
  - `GET /api/medicines` – list medicines for current user
  - `POST /api/medicines` – create medicine
  - `PUT /api/medicines/:id` – update medicine
  - `DELETE /api/medicines/:id` – delete medicine and any taken records
  - `POST /api/medicines/:id/toggle-taken` – body: `{ "date": "YYYY-MM-DD" }` → `{ taken: true|false }`
  - `GET /api/medicines/status?date=YYYY-MM-DD` – `{ takenMedicineIds: [medicineId...] }`
- **Diet**
  - `GET /api/diet?date=YYYY-MM-DD` – list diet entries for that day
  - `POST /api/diet` – body: `{ "date": "YYYY-MM-DD", "text": "..." }`

### Configuration

Create a `.env` file in `backend/` (you can copy `.env.example`):

```bash
cp .env.example .env
```

Set the values:

- **PORT** – HTTP port for the backend (default `4000`)
- **MONGODB_URI** – your MongoDB connection string
  - local: `mongodb://localhost:27017/diabetes_tracker`
  - Atlas: e.g. `mongodb+srv://USER:PASSWORD@cluster0.mongodb.net/diabetes_tracker`
- **JWT_SECRET** – a long, random string for signing tokens

### Install & run locally

From the project root:

```bash
cd backend
npm install
npm run dev
```

The server will start on `http://localhost:4000` by default.

### Deployment notes

You can deploy this backend to any Node hosting that supports environment variables, such as:

- Render, Railway, Fly.io, Heroku-compatible platforms, or a VPS.

Basic steps:

1. Push your repo to GitHub.
2. Create a new web service on your platform and point it at the `backend/` directory.
3. Set environment variables: `PORT`, `MONGODB_URI` (Atlas is recommended), and `JWT_SECRET`.
4. Use the start command: `npm install && npm start` with working directory set to `backend`.

