# ✈️ Hao Far
**Developer:** Lester Centino <br/>
**Developer:** Joanne Maryz Cabatingan <br/>
**Developer:** Elmo Del Valle <br/>

## Code Description
This program is a travel app that allows users to create their own travel plans and share it with friends. The users can find people with similar interests and add them as friends. They can also edit their own profile according to their preferences

## Installation Guide
To get hao far running on your device, follow these simple steps:

1. Clone the Repository:
    - First, you'll need to get the project's code. Open your terminal or command prompt and use Git to clone the repository:
        git clone <repository_url_here> # Replace <repository_url_here> with the actual GitHub URL
    - Navigate into the cloned project directory:
        cd project # Or whatever your project folder is named

2. Install Dependencies:
    - Flutter apps rely on various packages. Install them using pub get:
        flutter pub get

3. Check Flutter Doctor:
    - Make sure your Flutter development environment is set up correctly:
        flutter doctor
    - Resolve any issues flutter doctor points out (e.g., missing Android SDK components).

4. Connect a Device or Start an Emulator:
    - Ensure you have an Android or iOS device connected to your computer, or an emulator/simulator running.
5. Run the App:
    - With everything set up, deploy the app:
        flutter run

The app should now launch on your selected device or emulator.

## How to use app
Once you have hao far installed,

Sign Up or Sign In:
When you first open the app, you'll be prompted to either create a new account or log in if you already have one.

Create Your Profile:
After signing in, head to the "Profile" page. Here, you can personalize your details, interests, and preferred travel styles. You can also upload a profile picture and set your profile visibility (public or private).

Add a New Travel Plan:
Navigate to the Travel Plans List section and click the "+" button. Fill in the details for your upcoming trip, including destinations, dates, and activities.

View Your Plans:
Your created plans will appear in the home page or "Travel Plans List." You can view, filter, and sort your travel itineraries here.

Share Plans:
For any plan you create, you'll find an option to generate QR code. Share this code with friends or other users.

Find Similar People:
Looking for travel buddies? Go to the "Find Similar People" page. This feature helps you discover users who share similar interests and travel preferences. You can apply filters or search by interests and travel styles to refine your search.

Manage Friends and Requests:
On the "Find Similar People" page, you can send friend requests. Friend requests and travel plan reminders will appear in your "Notifications Page." You can accept or decline requests there.

View Other Profiles:
If another user has a public profile, you can view their details and send them a friend request from their profile page.

## Code Description
Sign-up and Sign-in - Firebase Authentication
Add new plan - flutter layout forms
Plans list - filtering and sorting
Sharing plans - QR code
Profile Page - showing user's details, interests, and preferred travel styles as well as edit their profile and set their profile to private or public
Edit Profile Page - edit certain user's details
Upload Profile Picture to Database - sets profile picture (either taken from camera or gallery) and converts them to base64 then upload to database
Find Similar People Page - shows people with similar interests and travel styles with current user, can add or remove filters as well as search people by their username/name
Notifications Page - shows friend requests and travel plan reminder
View Profile Page - see another user's profile (if public) and add them as a friend

