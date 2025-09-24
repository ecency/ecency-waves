# Release Notes

## 1.1.2

### Added
- Notifications center with filtering and read state management accessible from the drawer menu.
- Universal search view for discovering accounts and tags powered by new API endpoints.
- Ecency login and signing flows, including deep links and dedicated authentication screens.
- Ecency Points tipping support with refreshed tipping dialogs and flows.
- Language picker with localized strings for Russian, Chinese (Simplified), German, Spanish, French, Portuguese, and Hindi.
- Sentry crash monitoring to capture runtime issues.
- Firebase initialization bundled with new configuration to support real-time messaging and notification delivery.

### Improved
- Authentication reliability with clearer method indicators, consistent transaction signing, and more robust status/token handling across providers.
- Composer and reply experiences with better keyboard focus, attachment placement, layout spacing, and publishing feedback.
- Voting and poll flows with remembered weights, integer enforcement, minimum-age gating, and deferred initialization for stability.
- Platform integrations with updated app links, side-menu version details, custom device notices, modernized Android/iOS build tooling, and drawer account state syncing.
- Layout polish across authentication prompts and form inputs for better alignment and spacing on both platforms.

### Fixed
- Notification titles, read-state syncing, and tipping feedback inconsistencies.
- Occasional hangs from main-thread parsing, stored list desynchronization, and reply publishing state resets.
- Comment signing regressions and parameter issues affecting transaction requests.
- OAuth access token responses, app link routing, and authentication button alignment regressions introduced in prior builds.

## 1.1.1

### Added
- Fetch account on login natively for faster authentication.
- Back-to-top button for easier navigation.
- Voters list with image detection.
- Explore and My Waves sections for content discovery.
- Linkified tags and user mentions with avatars on the Explore page.
- Moderations, filter out Muted, Hidden, Gray, Low reputation content.

### Improved
- API service and pagination with sticky RPC node and direct node usage.
- Timeout handling and comment checks with surfaced errors.
- Removed dbuzz integration and improved queries.
- Rewrote `runThisJs` and platform bridges.
- Tag and account waves feeds pull posts directly from the API.

### Fixed
- Avatar resizing, keystroke request handling, profile fetching, and image proxy issues.
- Keystore, placeholder colors, and content fetching/loading.
- Wave timestamp parsing with timezone offsets causing format exceptions.
- Crash when viewing profiles if wave depth was missing in API responses.
- Explore dropdown not reflecting selected thread type.

## 1.1.0

### Added
- Poll functionality including creation, voting, results, and theme options.
- Delete-account option and welcome view requiring terms acceptance.
- Hash tag extraction for wave tags.
- Waves feature.
- Key-based login with HiveAuth/HiveKeychain and upvote support.
- Image upload across authentication methods.
- Report, mute, and filter features.
- Improved pagination and authentication visuals.
- iOS bridges and app icons.

## 1.0.0

- Initial release.

