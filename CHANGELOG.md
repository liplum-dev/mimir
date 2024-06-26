# Changelog

## v2.5.1
- Revealed the `game` navigation.
- Redesigned details pages of OA announcement and second class activity.

## v2.4.3
- Fixed 2048 not working on portrait mode.
- [Android] support predictive back gesture.
- Fixed color issues of Wordle on light mode
- Fixed translucent colors in timetable palette not working with theme harmonization.
- [Android] drop the support of `x86` and `x86_64`.
- Changed default locale to `zh_Hans`.
- The support to reset Sudoku game.
- Importing timetable form the next school year was allowed.
- Display check connectivity sheet when importing timetable.
- Display the best score and the max value of 2048 on app card.

## v2.4.2
- Introduced Sudoku game.
- Introduced a new navigation page, Game. (dev mode only)
- Improved visual effects of minesweeper.
- Game will pause when putting app into background.
- Game records: play again & share the game with QR code.
- Introduced Wordle game. (dev mode only)
- Save image of QR code.
- Timetable built-in start date and related student ID.
- [macOS] Deep link supports.
- Fixed authentication issue of undergraduate registration.

## v2.4.1
- Changed the custom URL and provided backward compatibility:
  - scheme: from `life.mysit` to `sit-life`.
  - Added host, `timetable`, for timetable-related data.
- Changed timetable file format and provided backward compatibility.
- Fixed QR code scanner issue.
- [Dev] Added debug deep link tile in developer options.
- Timetable *Out of Range* issue.

## v2.4.0
- Redesigned the expense statistics page.
- Redesigned the network tool page.
- Changed duration of skipping update up to 7 days.
- Changed web icons.
- Timetable background support on web.
- Fixed: Gif image not working in timetable wallpaper
- Allowed to join QQ group on desktop and web.
- [Demo mode] Attended activity mock service in class 2nd.
- Timetable issue inspection.
- Prompt user to save changes before quit.
- Timetable courses can be hidden now.
- Toggle haptic feedback in game settings.
- Toggle quick look lesson on tap feature in timetable settings.
- Improved zh-Hans and zh-Hant localization.
- Timetable patch for moving, copying, swapping and removing lessons of days.
- Shrunk the size of .ics file exported from timetable.
- Redesigned entities of proxy.
- [BREAKING CHANGES] New QR code formats of timetable palette and proxy.
- Share timetable in QR code.
- [Migration] Proxy settings and timetable background.
- [iOS] Shortcut for importing .ics file to Calendar app.
- Redesigned pull down menu.

## v2.3.0
- The 2048 game supports save/load feature.
- You can add, delete, and edit courses in the timetable.
- The Timetable is now more colorful than ever.
- Improved "Classic" timetable color palette.
- A new page for customizing theme colors has been added.
- You can withdraw applications of second class activities.
- The Cache is no longer cleared when the device runs out of storage space.
- Other minor UI improvements and localizations.

## v2.2.0
- The Minesweeper game was introduced.
- Login-related error dialogs now have detailed description.
- [Bug fix] Wrong localization text.
- UI and performance improvement.

## v2.1.3
- More types of OA login errors can be recognized.
- Except for iOS and macOS, the app automatically checks update on startup.
- By following school changes, electricity price rises from 0.61 to 0.636.
- [iOS] It's supported to scan QR code generated from this app with Camera app.
- [Bug fix] In some cases, OA captcha is infinitely asking for input, but the login doesn't work.

## v2.1.2
- GPA calculator was added.
- Library searching and borrowing list were added.
- HTTP and HTTPS proxy settings page was added.
- The UI of some pages was redesigned.
- ICP licence was added.
- [Bug Fix] Applying for a second classroom activity would make a double-application.
- [Bug Fix] In some cases, it is not possible to load the activities already attended in the second class.
