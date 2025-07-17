# 📦 Database Setup Guide — AgroVision Pro

This guide walks you through initializing the PostgreSQL database and Prisma ORM for the AgroVision Pro project. It assumes a local development environment **without Docker**.

---

## 🛠️ 1. Install PostgreSQL

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
```

---

## 🧑‍💻 2. Create Database and User

```bash
sudo -u postgres psql
```

Inside the shell:

```sql
CREATE USER agrovision WITH PASSWORD '0106800';
CREATE DATABASE agrovision_dev OWNER agrovision;
\q
```

---

## 📁 3. Set Up Prisma Schema

```bash
mkdir -p database/prisma
touch database/prisma/schema.prisma
```

Example `schema.prisma`:

```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

model User {
  id    Int    @id @default(autoincrement())
  email String @unique
  name  String?
}
```

---

## 🔐 4. Environment Variables

Create a `.env` file in the project root:

```env
DATABASE_URL="postgresql://agrovision:0106800@localhost:5432/agrovision_dev"
```

---

## 📦 5. Install Prisma

```bash
npm init -y
npm install prisma @prisma/client
```

(Optional) Initialize Prisma:

```bash
npx prisma init --schema=database/prisma/schema.prisma
```

---

## ⚙️ 6. Generate Prisma Client

```bash
npx prisma generate --schema=database/prisma/schema.prisma
```

---

## 🚀 7. Push Schema to Database

```bash
npx prisma db push --schema=database/prisma/schema.prisma
```

---

## 🧪 8. (Optional) Open Prisma Studio

```bash
npx prisma studio --schema=database/prisma/schema.prisma
```

---

## ✅ Summary

| Step | Command | Purpose |
|------|---------|---------|
| 1    | Install PostgreSQL | Local DB setup |
| 2    | Create user/db | Access control |
| 3    | Create schema | Define models |
| 4    | Add `.env` | Connection string |
| 5    | Install Prisma | ORM tools |
| 6    | Generate client | DB access layer |
| 7    | Push schema | Apply models |
| 8    | Open Studio | GUI for DB |

---

## 📌 Notes

- Make sure PostgreSQL is running locally.
- Always keep your `.env` file secure and out of version control.
- Use `prisma migrate` for production-ready schema changes.