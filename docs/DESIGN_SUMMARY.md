# Design Summary Document
**Application:** Kigali City Services & Places Directory  
**Platform:** Flutter (Android & iOS)  
**Backend:** Firebase (Authentication + Cloud Firestore)  
**State Management:** Provider

---

## 1. Application Architecture

### Architectural Pattern
The application follows a **layered architecture** with clear separation of concerns:

```
┌─────────────────────────────────────┐
│      Presentation Layer             │
│   (Screens, Widgets, UI)            │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│    State Management Layer           │
│   (AuthProvider, ListingsProvider)  │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│       Service Layer                 │
│  (AuthService, FirestoreService)    │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│       Data Layer                    │
│   (Firebase Auth, Firestore)        │
└─────────────────────────────────────┘
```

### Design Principles Applied
1. **Separation of Concerns:** UI components never directly call Firebase APIs
2. **Single Responsibility:** Each class has one clear purpose
3. **Dependency Injection:** Services injected into providers
4. **Observer Pattern:** Provider notifies UI of state changes
5. **Repository Pattern:** Services abstract Firebase operations

---

## 2. Firestore Database Structure

### Collections Schema

#### Users Collection
```
users/
  {userId}/
    - email: string
    - displayName: string
    - createdAt: timestamp
```

**Purpose:** Store user profile information linked to Firebase Auth UID

**Access Control:** Users can only read/write their own profile

#### Listings Collection
```
listings/
  {listingId}/
    - name: string
    - category: string (Restaurant, Hospital, School, etc.)
    - description: string
    - address: string
    - latitude: number
    - longitude: number
    - phoneNumber: string
    - createdBy: string (User UID)
    - createdAt: timestamp
    - updatedAt: timestamp (optional)
```

**Purpose:** Store all service and place listings with geographic data

**Access Control:**
- All authenticated users can read
- Users can only create listings with their own UID
- Users can only update/delete their own listings

### Indexing Strategy
Firestore automatically indexes single fields. For complex queries, I created a composite index:
- Collection: `listings`
- Fields: `createdBy` (Ascending), `createdAt` (Descending)
- Purpose: Efficiently query user-specific listings sorted by date

---

## 3. Data Models

### UserModel
```dart
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;
}
```

**Serialization:** Includes `fromFirestore()` and `toFirestore()` methods for type-safe data conversion.

### ListingModel
```dart
class ListingModel {
  final String? id;
  final String name;
  final String category;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
}
```

**Design Decision:** ID is nullable because it's assigned by Firestore after creation. All other fields are required to ensure data integrity.

---

## 4. State Management Implementation

### Provider Architecture

#### AuthProvider
**Responsibilities:**
- Manage authentication state (logged in/out)
- Handle signup, login, logout operations
- Track loading and error states
- Expose authentication stream to UI

**Key Methods:**
- `signUp()`: Creates user account and sends verification email
- `signIn()`: Authenticates user with email/password
- `signOut()`: Logs out current user
- `reloadUser()`: Refreshes authentication state after email verification

#### ListingsProvider
**Responsibilities:**
- Manage listings data and CRUD operations
- Handle search and filter state
- Provide real-time data streams to UI
- Track loading and error states

**Key Methods:**
- `getListingsStream()`: Returns all listings as real-time stream
- `getUserListingsStream()`: Returns user-specific listings
- `getFilteredListingsStream()`: Applies search and category filters
- `createListing()`, `updateListing()`, `deleteListing()`: CRUD operations

**State Variables:**
- `_searchQuery`: Current search text
- `_selectedCategory`: Active category filter
- `_isLoading`: Operation in progress
- `_error`: Error message if operation fails

### State Flow
```
User Action (UI)
    ↓
Provider Method Called
    ↓
Service Method Executed
    ↓
Firebase Operation
    ↓
Firestore Stream Emits New Data
    ↓
Provider Notifies Listeners
    ↓
UI Rebuilds (Consumer/StreamBuilder)
```

---

## 5. Service Layer Design

### AuthService
**Purpose:** Encapsulate all Firebase Authentication operations

**Methods:**
- `signUp()`: Create account with email/password
- `signIn()`: Authenticate user
- `signOut()`: End session
- `reloadUser()`: Refresh user state

**Design Decision:** Returns Firebase types (UserCredential) to allow providers to handle user data creation.

### FirestoreService
**Purpose:** Encapsulate all Cloud Firestore operations

**Methods:**
- `getListingsStream()`: Real-time stream of all listings
- `getUserListingsStream()`: Real-time stream of user's listings
- `createListing()`: Add new listing
- `updateListing()`: Modify existing listing
- `deleteListing()`: Remove listing
- `createUserProfile()`: Store user data
- `getUserProfile()`: Retrieve user data

**Design Decision:** All methods return Streams or Futures, never raw Firestore objects. This abstracts Firebase implementation details from the rest of the app.

---

## 6. Navigation Structure

### Screen Hierarchy
```
AuthWrapper (Root)
    ↓
├─→ LoginScreen
│       ↓
│   SignupScreen
│       ↓
│   EmailVerificationScreen
│
└─→ HomeScreen (Bottom Navigation)
        ↓
    ┌───┼───────────┬──────────┐
    ↓   ↓           ↓          ↓
Directory  MyListings  MapView  Settings
    ↓       ↓
Detail  AddListing
        EditListing
```

### Navigation Implementation
- **AuthWrapper:** StreamBuilder listens to authentication state and routes accordingly
- **Bottom Navigation:** Maintains state across tab switches
- **Stack Navigation:** Push/pop for detail and form screens

---

## 7. Search and Filter Implementation

### Search Functionality
**Implementation:** Client-side filtering on Firestore stream
```dart
filtered = listings.where((l) => 
  l.name.toLowerCase().contains(query.toLowerCase())
).toList();
```

**Design Trade-off:** Client-side filtering is simpler but less efficient for large datasets. For production, would implement Firestore full-text search or Algolia integration.

### Category Filter
**Implementation:** Filter stream by category field
```dart
filtered = listings.where((l) => 
  l.category == selectedCategory
).toList();
```

**Combined Filtering:** Both filters applied sequentially to the same stream, ensuring real-time updates.

---

## 8. Security Implementation

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    match /listings/{listingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
                      request.resource.data.createdBy == request.auth.uid;
      allow update, delete: if request.auth.uid == resource.data.createdBy;
    }
  }
}
```

**Security Principles:**
1. **Authentication Required:** All operations require authenticated user
2. **Ownership Validation:** Users can only modify their own data
3. **UID Verification:** Server-side validation prevents UID spoofing
4. **Read Access:** All authenticated users can browse listings

---

## 9. UI/UX Design Decisions

### Visual Design
- **Material Design 3:** Modern Flutter components
- **Color Scheme:** Blue primary color for trust and professionalism
- **Gradient Backgrounds:** Authentication screens use gradients for visual appeal
- **Card-Based Layouts:** Listings displayed in elevated cards for hierarchy
- **Category Icons:** Visual indicators for quick recognition

### User Experience
- **Loading States:** CircularProgressIndicator during async operations
- **Error Handling:** User-friendly error messages displayed in UI
- **Empty States:** Helpful messages when no data exists
- **Real-Time Updates:** Instant UI refresh when data changes
- **Form Validation:** Client-side validation before submission

---

## 10. Technical Challenges and Solutions

### Challenge 1: Real-Time Synchronization
**Problem:** UI not updating when Firestore data changes

**Solution:** Switched from FutureBuilder to StreamBuilder with Firestore snapshots(). This enables automatic UI updates whenever data changes in the database.

### Challenge 2: Email Verification Enforcement
**Problem:** Users accessing app without verified email

**Solution:** Created AuthWrapper that checks emailVerified status and routes to EmailVerificationScreen until verified.

### Challenge 3: State Persistence Across Screens
**Problem:** Search/filter state lost when navigating

**Solution:** Stored state in ListingsProvider, which persists across navigation. Provider ensures state is shared across all screens.

### Challenge 4: CRUD Operation Feedback
**Problem:** Users unsure if operations succeeded

**Solution:** Implemented loading states in providers and displayed CircularProgressIndicator during operations. Error states show user-friendly messages.

---

## 11. Performance Considerations

### Optimization Strategies
1. **Stream Optimization:** Only subscribe to needed data collections
2. **Lazy Loading:** ListView.builder for efficient scrolling
3. **Indexed Queries:** Firestore indexes for fast sorted queries
4. **Minimal Rebuilds:** Consumer widgets only rebuild affected UI parts
5. **Cached Data:** Firestore automatically caches data for offline access

### Scalability
The architecture supports future enhancements:
- Add image uploads to listings
- Implement user ratings and reviews
- Add advanced search with multiple filters
- Integrate push notifications
- Support offline mode with local database

---

## 12. Testing Strategy

### Manual Testing Performed
1. **Authentication Flow:** Signup → verify → login → logout
2. **CRUD Operations:** Create → read → update → delete listings
3. **Real-Time Updates:** Verified UI updates automatically
4. **Search/Filter:** Tested various combinations
5. **Firebase Console:** Verified all operations reflected in backend
6. **Security Rules:** Tested unauthorized access attempts

### Edge Cases Handled
- Empty search results
- No listings available
- Network errors
- Invalid form inputs
- Unverified email attempts

---

## 13. Conclusion

This design successfully implements a scalable, maintainable Flutter application with Firebase backend integration. The clean architecture with service layer separation, Provider state management, and real-time Firestore streams demonstrates best practices in mobile app development.

Key achievements:
- ✅ Clean separation of concerns
- ✅ Real-time data synchronization
- ✅ Secure authentication and authorization
- ✅ Efficient state management
- ✅ User-friendly interface
- ✅ Scalable architecture

The application is production-ready and can be extended with additional features while maintaining code quality and architectural integrity.

---

**Total Pages:** 2 pages

**GitHub Repository:** https://github.com/Elvin100s/kigali_city_services
