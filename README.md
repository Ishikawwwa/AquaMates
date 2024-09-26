# **Aqua Mates**

Welcome! This is a social hydration app where users can add friends and track each other's hydration progress.

![image](https://github.com/user-attachments/assets/acba0410-d42d-4719-8b78-d5655b709382)

## **Table of Contents**

- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Usage](#usage)
  - [Running the App](#running-the-app)
  - [Web Deployment](#web-deployment)
- [Contributing](#contributing)
- [Contact](#contact)

## **Features**

- **User Authentication:** Sign up and log in using your email.
- **Hydration Tracking:** Track your daily water intake.
- **Friend System:** Add friends by email and view their hydration progress.
- **Progress Streaks:** Maintain streaks by consistently hitting your hydration goals.

![2024-09-26 13-42-00](https://github.com/user-attachments/assets/1068c2ae-d6ef-4e0f-951f-c04945c6f758)


## **Getting Started**

### **Prerequisites**

Before you begin, ensure you have met the following requirements:

- **Flutter SDK:** Make sure Flutter is installed on your machine.
  - Install from [Flutter.dev](https://flutter.dev/docs/get-started/install)
- **IDE:** Use an IDE such as [Android Studio](https://developer.android.com/studio) or [Visual Studio Code](https://code.visualstudio.com/) with Flutter and Dart plugins.

### **Installation**

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Ishikawwwa/AquaMates.git
   cd aquamates
   ```

2. **Install dependencies:**
   Run the following command to install the required packages:
   ```bash
   flutter pub get
   ```

3. **Set up Firebase:**
   - Follow the instructions on [Firebase.com](https://console.firebase.google.com/).

## **Usage**

### **Running the App**

You can run the app on different platforms. Here’s how to get started:

#### **1. Android or iOS**

- **Connect a device or start an emulator/simulator:**
  Ensure you have an Android device connected or an emulator running. Similarly, for iOS, ensure an iPhone simulator is running.

- **Run the app:**
  ```bash
  flutter run
  ```
  This will build and launch the app on your connected device or emulator/simulator.

#### **2. Web**

- **Run the app in a browser:**
  ```bash
  flutter run -d chrome
  ```
  This will build and serve the web app, opening it in a new browser tab.

### **Web Deployment**

To deploy the app on GitHub Pages:

1. **Build the web app:**
   ```bash
   flutter build web
   ```

2. **Deploy to GitHub Pages:**

   - Switch to the `gh-pages` branch:
     ```bash
     git checkout --orphan gh-pages
     git reset --hard
     ```

   - Copy the contents of the `build/web` directory to the root of the `gh-pages` branch:
     ```bash
     cp -r build/web/* .
     ```

   - Commit and push:
     ```bash
     git add .
     git commit -m "Deploy Flutter web app"
     git push origin gh-pages --force
     ```

3. **Access your app:**
   The app will be available at `https://yourusername.github.io/your-repo-name/`.

## **Contributing**

Contributions are welcome! Here’s how you can help:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes.
4. Commit your changes (`git commit -m 'Add some feature'`).
5. Push to the branch (`git push origin feature-branch`).
6. Open a Pull Request.

## **Contact**

If you have any questions, feel free to reach out
