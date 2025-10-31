# Smart Home Backend (Node.js + MongoDB)

## Setup

1. Install dependencies
```
cd backend
npm install
```

2. Configure environment
- Create a `.env` in `backend/` with:
```
PORT=3000
MONGODB_URI=mongodb://localhost:27017/smarthome
JWT_SECRET=replace_me
```

3. Run MongoDB locally (or use Atlas)

4. Start the server
```
npm run dev
```

The API will be available at `http://localhost:3000/api`.

## Endpoints
- GET `/api/users/profile`
- PUT `/api/users/profile`

Matches the mobile app expectations.

