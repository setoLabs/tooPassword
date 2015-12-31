![tooPassword | The one and read-only app for 1Password keychains.](tooPassword.jpg)

tooPassword for iOS offers read-only(!) access to AgileBits' 1Password keychains. That means you must own 1Password on your Mac or PC. If you would like to manage, generate and save new passwords on your iOS device, consider downloading AgileBits' 1Password iOS app.

## Introduction

tooPassword is now open source. You can [download it on the App Store](https://itunes.apple.com/app/toopassword/id596958240) for free. We decided to discontinue support and development of tooPassword, because we're moving on with new projects.

Check out our current project [Cryptomator](https://cryptomator.org/) (free & open source), a multiplatform solution for transparent client-side encryption of your files in the cloud.

## Notes

We didn't preserve the complete Git history, because of private information that we couldn't redact individually. If you would like to use tooPassword with Dropbox, you have to set `kTPWDropboxAppKey` and `kTPWDropboxAppSecret` accordingly in `TPWAppDelegate.m`. Other than that the project should build.

The code isn't state-of-the-art. We didn't write a lot of tests, back then CocoaPods wasn't as popular as today, the deployment target is set to iOS 5 (resulting in a lot of backwards compatibility code/assets), in that regard the code is already ancient. However especially the cryptographic code and directory browsing/import concepts are still worth a look.

## Credits

tooPassword is made by setoLabs GbR [Tobias Hagemann](https://github.com/MuscleRumble) & [Sebastian Stenzel](https://github.com/overheadhunter). We love 1Password! Seriously. It's amazing! If you don't have it, go buy it for your Mac or PC!

1Password is a trademark of AgileBits Inc., registered in the US and other countries. tooPassword is not affiliated with 1Password or endorsed by AgileBits Inc. in any way.

## License

Distributed under the GNU General Public License. See the LICENSE file for more info.
