The idea for this utility is to provide a way to generate simple QR codes that do not require a new account, a login, or the sharing of information with others, such as WiFi passwords. 
I have tinkered with this multiple times, but didn't finish and publish an app. For this version, I used Android Studio (with Gemini for parts) and OpenCode from OpenCode.ai. I gave OpenCode the requirements. It built a an app that worked. With a Mac Mini 4 I started to make an iOS and an Android version.
Many iterations, many failed tries. I finnaly a working iOS version.
Opencode built the code base. Then I spent time correcting the errors.
It was built to not require an account, login, or email info. I don't want your stuff.

Recommendations to readers.
1) Use OpenCode to generate the application.
2) Specify the Android, JDK, and API versions you want it to build for. I had an issue because I didn't specify and it built the initial code for Gradle 8.x, not 9.x. 
3) Think about graphical assets, icons you want it to have. Specify the UX with as much specifics as possible. Ask AI about how to list it, have the AI check it.

Now to figure out how to get it publish on two app stores..

If you like the app, buy me a coffee. https://buymeacoffee.com/bdmurph73i
