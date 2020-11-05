# 𝚿 Psi App

![](./assets/630.jpg)



A Flutter app

## Run

```
flutter run
```

## Regenerate Icons

```
flutter pub run flutter_launcher_icons:main
```

## Set Splash Pages 


Change the files in `android -> app -> src -> main -> res`

and `iOS -> Runner -> Assets.xcassets -> LaunchImage.imageset`

See this SO answer for more details : https://stackoverflow.com/a/48101776/1290746

This tool seems ok for generating splash images : https://www.spdoctor.com/articles/App_Image_Generator.html



## Other bits

##### Database

There is a Firebase database which controls the shared tests.
(This is owned by kris.randall@gmail.com)

##### Image service

The service .... is used for fetching images.

##### URL shortening

The service https://developers.rebrandly.com/docs is used for URL shortening, for sharing tests.
(The account for this is linked to kris.randall@gmail.com)
I have also configured at rebrandly link.cocreations.com.au to work as a custom URL (set up at crazydomains, as per : https://app.rebrandly.com/domains)

##### Testinng Android URL links

```
adb shell monkey -p au.com.cocreations.psiappX  1
```

... trying to figure out how to specify path ...

