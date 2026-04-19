# Brandora App 🛍️

Brandora App is a complete inventory and store management system. It consists of a mobile application built with **Flutter** and a backend built with **Node.js, Express, and MongoDB**.

## 📌 Features
- **Firebase Authentication**: Secure user login and registration.
- **Raw Materials Management**: Add, update, and track raw materials including quantities, prices, and units (kg, liter, meter, piece).
- **Products Management**: Create finished products, link them to raw materials (which automatically deducts from raw material stock upon production), and upload product images.
- **RESTful API**: A fully functional Node.js backend to handle data storage securely in MongoDB.

## 🛠️ Tech Stack
- **Frontend**: Flutter, Provider (State Management), HTTP.
- **Backend**: Node.js, Express.js.
- **Database**: MongoDB (Mongoose).
- **Authentication**: Firebase Auth & Firebase Admin SDK.

## 🚀 How to Run the App (Locally)

### 1. Backend Setup
1. Open a terminal and navigate to the `backend_engine` folder:
   ```bash
   cd backend_engine
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Make sure you have MongoDB running locally, or configure your `MONGO_URI` in a `.env` file.
4. Start the server:
   ```bash
   npm run dev
   ```
   *(The server will run on `http://localhost:3000`)*

### 2. Frontend Setup
1. Open a new terminal and navigate to the root directory (where `pubspec.yaml` is located).
2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app on an emulator or a connected physical device:
   ```bash
   flutter run
   ```

## 🌍 Cloud Deployment (Railway)

To host the backend online so it can be accessed from any device anywhere:
1. Upload the entire project to **GitHub**.
2. Go to **Railway.app** and create a New Project > Deploy from GitHub Repo.
3. In the Railway project Settings, set the **Root Directory** to `/backend_engine`.
4. Create a MongoDB Database inside the Railway project (it will automatically link).
5. In the Railway Variables tab, add a new variable named `FIREBASE_SERVICE_ACCOUNT` and paste the exact contents of your `serviceAccountKey.json` file.
6. Generate a Domain in Railway Settings, copy it, and paste it into `lib/core/services/api_service.dart`.