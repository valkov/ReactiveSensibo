Sensibo test implemented using MVVM and Reactive Cocoa
=================

## Test description
Roy Razon 7/22/16, 14:15 on skype

App should have a login screen allowing to user to specify email and password. Once logged in, the app will show a screen with the list of devices for that user, with the name and on/off state for each device, and a button to toggle the on/off state. Tapping the button will send an actual command to change the power state of the device.

You can deduce the API from the existing project. You can even reuse some of the code where you think it's appropriate.
Having a proper architecture and design is as important as making it work. UI and looks are unimportant.

## Explanation of MVVM pattern implementation
I'm referring to the view controllers as views in that project. The LoginModel and PodsModel are view models(just find that names more suitable in the context) and the model itself is the Realm database.

## Why Reactive Cocoa
In my opinion that would work better comparing to the current Sensibo implementation as it eliminates an entire set of bugs in UI logic(ex: Login button won't be enabled until email and password fields are validated and there is an internet connection.  Login command is only enabled when fields are validated. Login command is attached to the button and executed when button is pressed, network activity indicator is shown while command is executing and hides when completed. And that is just few lines of code).

The Networking layer returns RACSignals so they can be easily attached to the RACCommand, that approach will also help to fight the cancel request problem.

Finally it's less code to write and it's highly testable.

## Features

LOGIN
- keyboard navigation support - tap on next button on the keyboard goes to the password field, done button on the password field executes login
- login button is disabled if email isn't valid or password isn't valid or there is no internet connection, when there is no connection the login button title changes to 'you are offline'
- server request activity indication
- error messages are shown using HTML from error description
- animation between login screen and pods list screen

PODS LIST
- logout support with animation
- pull to refresh support
- offline support (pods with their states are saved to the Realm)
- easy JSON->Realm mapping via Realm+JSON
- automatic TableView cells insertion/removal animation (the pods list changes is done on background thread after network request, table view will react automatically to the model changes)
- server request activity indication
- switches are automatically enabled/disabled when device goes online/offline
- success/error messages are shown when device is toggled or error has occured
- on/off switch is disabled when you are offline

## Tests
There are some unit tests as well as some integration tests. But as you can see the amount of tests isn't even close to 100% coverage, I needed more time to cover all the model and UI logic.

## Test environment
iPhone Simulator 9.3

iPhone SE iOS 9.3.2
