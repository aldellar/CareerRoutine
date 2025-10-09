# 🤝 CollabSpace

**CollabSpace** is a collaborative workspace management web application designed to streamline project organization and user collaboration. It features account authentication, workspace creation, user role management, and responsive UI built with modern web technologies.

---

## 🛠 Tech Stack

- **Frontend**: React, Material UI
- **Backend**: Node.js, Express
- **Database**: PostgreSQL
- **Authentication**: JWT-based
- **API Documentation**: OpenAPI/Swagger

---

## 🌟 Features

- 🔐 Secure login with hashed password storage
- 🧑‍💼 Workspace and user management
- 🧭 Role-based interface
- 🔄 Session handling via JWT tokens
- ⚡ Fast PostgreSQL queries using JSONB columns

---

## 🧪 Seeded Test Accounts

Use these accounts to sign in during development/testing:

| Email                                      | Password    | Name              |
| ------------------------------------------ | ----------- | ----------------- |
| [molly@books.com](mailto\:molly@books.com) | mollymember | Andrew Dellaringa |
| [anna@books.com](mailto\:anna@books.com)   | annaadmin   | Anna Hendo        |

---

## 🧰 Database Setup

PostgreSQL database is seeded with test data:

- 2 Users
- 3 Workspaces: Project Alpha, Project Beta, Project Charlie
- Pre-linked workspace-user relationships

Each project has both users as members.

---

## 🚀 Getting Started

1. **Clone the repo**

```bash
git clone https://github.com/yourusername/collabspace.git
cd collabspace
```

2. **Backend Setup**

```bash
cd backend
npm install
npm start
```

3. **Frontend Setup**

```bash
cd frontend
npm install
npm start
```

4. **Environment Variables** Make sure to configure your `.env` file for the backend with your database credentials and JWT secret.

---

## 🛡 Authentication

CollabSpace uses JWT to protect API routes. Users must log in to receive a token, which is then validated on all protected routes.

---

## 📄 License

MIT

---

## ✍️ Author

Created by **Andrew DellAringa**

