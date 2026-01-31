### TODO
- [x] Refactor Codebase using Bloc
- [x] Use viewmodels
- [x] Use Jni+gen to sync call kotlin function
- [x] FileLogger should also use jni calls for SST
- [x] Update readme, add images and running instructions
- [x] Better error handling
- [ ] Permission handling and dynamic location
- [x] Add icon

---
### FUTURE
- [ ] Snooze time addition
- [ ] Custom offset / snooze behaviour for adhan alarms
- [ ] multiselect + actions

---
### BUGS
- [x] Fix delay
- [x] Fix prayers not reseting on boot
- [x] Fix day alarms
- [x] Fix ctd first launch
- [x] Fix issue with wrong dhur time. Check if system millis is correct? old was correct.
- [x] Fix no name alarm?
- [x] Fix for setting an alarm for before now!
- [x] Fix for __snoozed
- [ ] Fix prayer alarms not triggering
- [x] Fix refetch all alarms on resume and restart
- [x] Fix alarm date not updating on enable
- [ ] Fix prayer alarms toggle not working

---
### OLD
- [x] Change to fullscreen dialog (used setAlarmClock)
- [x] Implement snooze
- [x] Sound and Vbration
- [x] Issue with multiple alarms? maybe dont work if too close. (needed different IDs)
- [x] Set alarms for prayer
  - [x] Set name
  - [x] Set proper times
  - [x] Set for next day/s
  - [x] Do not set expired alarms
- [x] Potential issue if phone turns off and the next are not scheduled?
  - [x] Reset **ALL** alarms on boot
- [x] Location dynamic
- [x] Ask for location perms (and device location)
- [x] Reset alarms after they go off (set extra long)
  - [x] Change to repeatInterval?
- [x] Alarm Features 
  - [x] Implement disable, vibrate, sound statuses for individual alarms
  - [x] Handle repeat days
  - [x] Handle disable period
  - [x] Disable one off alarms after they have rung
  - [x] Delete Alarm
  - [x] Scroll to new
- [x] Use flutter ui for alarm
  - [x] Main Page
  - [x] Add/Edit Alarm dialog
  - [x] Alarm Features UI
  - [x] Adhan Features UI
- [x] Alarm set collisions
- [x] Clear disable period
