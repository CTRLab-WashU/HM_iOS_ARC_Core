# HM_iOS_ARC_Core


Setting up and Building Projects
================================

To the best of knowledge, getting these applications to build should require pretty minimal setup on your part. Once you've got the projects cloned, all that you should need to change are build settings like the Bundle Identifier and Team for iOS.


Changing Dev/QA/Production Settings
-----------------------------


The iOS projects keep some build-specific settings in an enum that implements the `ArcEnvironment` protocol. This file is usually named something like "XXEnvironment.swift".

To toggle between different build settings, you can change the `environment` property located at the beginning of AppDelegate.swift. 


Application Structure
=====================

Although they achieve it in very different ways, both iOS and Android projects are built with the same ideas in mind: a core project contains all of the basic functionality, and each application is built by customizing certain core classes. 


Before I start describing these different classes, I want to make note that many of these objects are actually enumerations. Swift has a _very_ lenient idea of what an enum is. This allows for the creation of enums that can have additional properties or methods, and even implement protocols (as many of these are doing).

**ArcEnvironment**

The `ArcEnvironment` protocol contains many different configuration settings that handle participant authentication, test cycle schedule, among others.

In each application, this protocol is implemented by an enum, named something like "XXEnvironment". Different cases exist for different build configurations (dev, qa, production, etc). These types control the value of some properties, such as the `baseUrl`, `crashReporterApiKey`, `isDebug` values. This protocol also contains a number of settings that generally would apply to any build configuration, such as `arcStartDays`, `authenticationStyle`, `scheduleStyle`.


**State**

The `State` protocol contains two methods to be implemented, `viewForState()` and `surveyTypeForState()`. 

Again, this protocol is implemented by an enum, named something like "XXState". The enumerated cases represent the different possible application states (welcome, auth, schedule, chronotype, wake, gridTest, etc etc).

**Phase**

The `Phase` protocol itself is mostly a collection of methods meant to return different `PhasePeriod` objects, which are simply objects that implement the `Phase` protocol. 

Again, this protocol is implemented by an enum, named something like "XXPhase". This enum typically contains only three cases: none, baseline, and active. These different phases represent differences between certain test cycles. For instance, the first test cycle for EXR, known as the baseline cycle, contains an extra test session, and technically runs for 8 days instead of 7.

**AppNavigationController**

The primary function of the `AppNavigationController` class is to decide, given a current State, what State the application should navigate to next, through the `nextAvailableState()` method. It also provides access to different default States through methods like `defaultAuth()`, `defaultAbout()`, etc.

**Arc**

The `Arc` class is used as a singleton object, accessed through `Arc.shared`. It provides access to different controller objects, and is used to store the current state of the application through properties like `currentStudy`, `availableTestSession`, `currentTestSession`, and `currentState`.

The most important part of the `Arc` class is the `nextAvailableState()` method, which is called any time the application is opened, and any time the current state of the application has finished. For example, it's called whenever the participant reaches the end of a survey, or finishes updating their wake/sleep schedule.


