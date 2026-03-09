			**Kigali City Services** 

| Type | Link |
| :---- | :---- |
| **Demo Video** | **[https://youtu.be/IuXnCBHNpzQ](https://youtu.be/IuXnCBHNpzQ)**  |
| **Github repository** | **[https://github.com/josep-prog/kigali\_service\_app.git](https://github.com/josep-prog/kigali_service_app.git)**  |
| **Firebase console** | **[https://firebase.google.com](https://firebase.google.com)**  |

The Kigali City Services & Places Directory is a mobile app made with Flutter and Firebase. It helps people in Kigali find important places like hospitals, police stations, restaurants, cafés, parks, and tourist spots. The app works like a digital guide, making it easier and faster to find services in the city.

Users can add, view, update, and delete service listings. All the data is saved safely in Firebase Firestore. The app also has email login, real-time updates, search and filter options, and a map with navigation. Users need to log in before using the app, which keeps it secure.

While making this app, I learned how to connect a mobile app to the cloud, manage app data with the Provider package, and use Firebase features like authentication, email verification, real-time updates, and map integration. Some parts were tricky, but they helped me gain valuable experience.

## **Features**

The app functions as a digital guide for Kigali, providing a variety of user-focused features:

1. **User Authentication:** Users can register and log in, gaining secure access to the app. Email verification ensures that only authorized users can access sensitive features.

2. **Service Listings:** Users can browse and interact with service listings. Each listing provides details such as name, description, contact information, and location on a map.

3. **CRUD Operations:** Users can add, edit, or delete their own listings, giving them control over the content they contribute.

4. **Search and Filter:** Services can be searched and filtered by category, allowing users to quickly find the services they need.

5. **Map Integration:** Each service listing includes geographic coordinates, enabling users to view locations on a map and open Google Maps directly for navigation.

Making the Kigali City Services & Places Directory came with some technical challenges. These challenges helped me learn more about mobile app development, cloud databases, and app security.

#### 

#### **Authentication and Email Verification**

One of the first challenges was making sure users verify their email before using the app. At first, users could use the app right after signing up, even without verifying their email, which was unsafe. To fix this, I added an Email Verification Screen. This screen checks if the user’s email is verified and blocks access to the app until verification is complete. I also added a “Reload User” button to update the verification status after the user clicks the email link.

Example code:

await FirebaseAuth.instance.currentUser?.reload();

bool verified \= FirebaseAuth.instance.currentUser\!.emailVerified;

This way, the app only lets users in when their email is verified, keeping it secure.

### **Real-Time Database Updates**

Originally, Firestore data loaded only once using `FutureBuilder`, so newly added or deleted listings did not appear without manually refreshing the screen. Switching to **StreamBuilder** and using `Firestore.collection('services').snapshots()` allowed the UI to respond to database changes in real-time. By combining this with the **Provider** state management system, the app now reflects all updates automatically, ensuring a smooth and consistent user experience.

### **Search, Filtering, and Security Challenges**

#### **Search and Filtering**

Adding search and filtering was tricky because filters needed to remember settings even when users moved between screens and handle multiple conditions at the same time. I solved this by creating a method called `getFilteredListingsStream()` in the ListingsProvider. This method applies both text search and category filters directly to the Firestore data stream. This way, filtered results update automatically whenever the data changes, instead of using old snapshots.

#### Security Rules

Setting up Firebase security rules was important to keep the app safe. Early attempts caused “Permission Denied” errors. After reviewing the rules for listings and users, the final setup:

* Only authenticated users can write data.

* Users can edit only their own listings.

* All logged-in users can read listings.

### 

### **Fingerprint Authentication**

When connecting my Android project to Firebase, it was important to generate a fingerprint (SHA-1 or SHA-256 key). This fingerprint is required by Firebase to identify and link the app securely. Without it, features like authentication, email login, and other Firebase services would not work properly on Android devices. Generating the fingerprint ensured the app could communicate safely with Firebase and function correctly.

## **Project Structure**

Initially, Firebase functions were called directly from the UI, making the code difficult to maintain. Refactoring the project with **Provider controllers** and service classes separated UI logic from backend operations, resulting in cleaner, more maintainable code. This structure also facilitated future scalability and the addition of new features.

## **Activating and Running the Project**

To run the application, follow these steps:

1. **Clone the Project:**

git clone [https://github.com/josep-prog/kigali\_service\_app.git](https://github.com/josep-prog/kigali_service_app.git) 

cd kigali\_service\_app

2. **Set Up Firebase:**

   * Create a Firebase account and a new project in the Firebase Console.

   * Obtain the project credentials and configuration.

   * Enable **Email/Password Authentication** in the Authentication section to allow users to sign up and verify their email addresses.

3. **Install and Configure Firebase CLI:**

firebase login

firebase projects:list

Connect the local project to your Firebase backend.

4. **Configure Environment Variables:**  
    Add the Firebase credentials to the `.env` file located in the `lib/` directory. This step links the app to your Firebase project.

5. **Run the Application:**

flutter emulators \--launch \<emulator\_name\>

flutter run \-d \<emulator\_name\>

This will launch the app in your chosen emulator.

