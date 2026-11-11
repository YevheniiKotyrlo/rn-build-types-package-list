# rn-build-types-package-list

A library whose `react-native.config.js` sets `platforms.android.buildTypes: ['debug']` is kept out of the release variant's classpath, but the Gradle plugin's `PackageList.java` still names its package, so the release variant fails to compile.

`ReproducerApp/modules/debug-only-library` is that library, with a `ReactPackage` (`com.debugonlylibrary.DebugOnlyPackage`); the app depends on it with `file:`.

```sh
./reproduce.sh
```

It runs `yarn install` in `ReproducerApp`, then `./gradlew :app:compileDebugJavaWithJavac :app:compileReleaseJavaWithJavac --continue` in `ReproducerApp/android`, and prints the lines of `PackageList.java` that name the library. It exits 1 while the release variant fails on `package com.debugonlylibrary does not exist` and the debug one compiles, 0 once both compile, and 2 when a step fails another way.

# How to use this Reproducer

This project has been created with `npx @react-native-community/cli init` and is a vanilla React Native app.

> [!IMPORTANT]  
> Make sure you have completed the [React Native - Environment Setup](https://reactnative.dev/docs/set-up-your-environment) so that you have a working environment locally.

## Step 1: Start the Metro Server

First, you will need to start **Metro**, the JavaScript _bundler_ that ships _with_ React Native.

To start Metro, run the following command from the _root_ of your React Native project:

```bash
# using npm
npm start

# OR using Yarn
yarn start
```

## Step 2: Start your Application

Let Metro Bundler run in its _own_ terminal. Open a _new_ terminal from the _root_ of your React Native project. Run the following command to start your _Android_ or _iOS_ app:

### For Android

```bash
# using npm
npm run android

# OR using Yarn
yarn android
```

### For iOS

First, make sure you install dependencies with:

```bash
cd ios && bundle install && bundle exec pod install
```

Then you can run the iOS app with:

```bash
# using npm
npm run ios

# OR using Yarn
yarn ios
```

If everything is set up _correctly_, you should see your new app running in your _Android Emulator_ or _iOS Simulator_ shortly provided you have set up your emulator/simulator correctly.

This is one way to run your app — you can also run it directly from within Android Studio and Xcode respectively.

## Step 3: Modifying your App

Now that you have successfully run the app, let's modify it.

1. Open `App.tsx` in your text editor of choice and edit some lines.
2. For **Android**: Press the <kbd>R</kbd> key twice or select **"Reload"** from the **Developer Menu** (<kbd>Ctrl</kbd> + <kbd>M</kbd> (on Window and Linux) or <kbd>Cmd ⌘</kbd> + <kbd>M</kbd> (on macOS)) to see your changes!

   For **iOS**: Hit <kbd>Cmd ⌘</kbd> + <kbd>R</kbd> in your iOS Simulator to reload the app and see your changes!
