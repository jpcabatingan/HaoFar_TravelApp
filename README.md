**Name:** Lester Centino <br/>
**Name:** Joanne Maryz Cabatingan <br/>
**Name:** Elmo Del Valle <br/>
**Section:** UV-3L <br/>

## Code Description
This mobile application is a Mood Tracker where a user can log their name, nickname, age, if they exercised today, their current emotion, their emotion intensity, and the weather today. After answering the necessary fields with valid inputs, a summary of their choices will then be displayed.

NEW FEATURES:
    After saving the filled up form, the information will be stored and displayed in another page called "Mood Entries". It shows a brief overview of the entry containing the name of the user and date&time of submission. Once a specific entry is clicked, a page containing the full summary will also be displayed.

## Things you did in the code
I utilized rows, columns, and paddings to set the initial layout of the application. After that, I added the necessary and appropriate widgets needed for an emotion tracker.
Name, Nickname, Age:
    - used text field since user text input is applicable here
Exercised today?:
    - used switch since it is boolean
Emotions
    - used radio buttons since it accepts a single-value selection
Emotion Intensity
    - used sliders since it measures a specific nominal degree of intensity
Weather
    - used dropdown menu for single-value selection

For the design, I used Google Fonts, Flutter Icons, and widget customization by changing their sizes and colors. I looked up the necessary documentations to be used for the layout and design.

Routes
    - This app starts at the Mood Entries page (/mood_entries), which is initially empty. It will then prompt user to fill up a form to add mood entries in /mood_form. After submission, it will allow user to check the list of recorded moods and click them to open up a new page containing the full summary.

Drawer
    - I used the drawer widget to allow the user to navigate throught different pages.

Mood Entries
    - This page displays each object in the list of saved mood records. It contains the name of the user and the submission date & time. It also allows for deletion of saved mood records.

Mood Entry Details
    - I created a page that reads the provider's stored selected object values and displays them as string. This page has two ways of going back to the mood entries page, through the arrow back button at the appBar and the back button after the summary.

Disabling Button
    - To avoid double submissions, i disabled the save button upon submission. It only gets enabled once there are changes done in the input fields, wherein I set the _disableButton variable to false once input value changes are detected.

GIF
    - I followed this sample code https://pub.dev/packages/gif/example 

## Challenges encountered
    - The GIFs do not work in my Android emulator. However, it works perfectly fine when I use Chrome.

## References
Google Fonts
    - https://docs.flutter.dev/cookbook/design/fonts
    - https://pub.dev/packages/google_fonts
    - https://fonts.google.com/selection?preview.text=Mood%20Tracker&categoryFilters=Feeling:%2FExpressive%2FPlayful
Icons 
    - https://api.flutter.dev/flutter/material/Icons-class.html
Text Field Outlined Text 
    - https://m2.material.io/components/text-fields/flutter#outlined-text
Radio Button 
    - https://www.youtube.com/watch?v=ogHx-WEElF8
Switch 
    - https://m2.material.io/develop/flutter/components/switches
Slider 
    - https://api.flutter.dev/flutter/material/Slider-class.html
Dropdown Menu 
    - https://m3.material.io/components/menus/specs
    - https://sylviedie.medium.com/styling-a-flutter-dropdownbutton-widget-with-color-and-some-bling-62c5423f41db
Drawer Styling 
    - https://flutterdesk.com/flutter-drawer-header-height/#:~:text=You%20can%20specify%20Flutter%20drawer,the%20change%20in%20DrawerHeader%20height.&text=As%20you%20can%20see%2C%20we,to%20wrap%20the%20DrawerHeader%20class.
Button Design 
    - https://m2.material.io/components/buttons/flutter
Date & Time 
    - https://stackoverflow.com/questions/73532570/how-to-show-time-on-page-after-pressing-elevated-button-in-flutter
    - https://api.flutter.dev/flutter/intl/DateFormat-class.html
Disable Button
    - https://www.geeksforgeeks.org/how-to-disable-a-button-in-flutter/
GIF
    - https://pub.dev/packages/gif/example



----------------------------------------------------------------------------
