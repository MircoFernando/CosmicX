# Cosmic Quest - Development Log (January to March 2026)

## Purpose
This development log records weekly progress, problem-solving, and reflection over a 3-month period. It documents how the project evolved from early setup into a working, tested, and polished application.

---

## January 2026

### Week 1 (Jan 1 - Jan 7)
**Date/Time:** 2026-01-05, 19:00-22:00  
**Tasks Completed:**
- Defined app scope and feature boundaries for Cosmic Quest.
- Drafted initial wireframes for Home, Explore, Quiz, and Profile flows.
- Set up Flutter project structure and base folders (`views`, `data`, `services`, `theme`).

**Challenges Encountered:**
- Translating wireframe ideas into practical Flutter screen hierarchy.

**Solution Attempted:**
- Mapped each wireframe block to widget trees before coding.
- Separated responsibilities into screen-level and repository-level tasks.

**Reflection:**
- Early architecture planning reduced confusion later.

**Next Steps:**
- Implement core app shell and baseline navigation.

**Screenshot Placeholder:**
- [INSERT SCREENSHOT 1: Initial wireframes overview]
- [INSERT SCREENSHOT 2: Project folder setup in IDE]

---

### Week 2 (Jan 8 - Jan 14)
**Date/Time:** 2026-01-12, 18:30-22:30  
**Tasks Completed:**
- Implemented app entry, theme setup, and initial root widget.
- Connected Firebase core/auth bootstrap sequence.
- Added sign-in gate flow and post-login routing.

**Challenges Encountered:**
- Initialization order issues between dotenv loading, Firebase startup, and app launch.

**Solution Attempted:**
- Enforced `WidgetsFlutterBinding.ensureInitialized()` and startup sequence before `runApp()`.

**Reflection:**
- Startup order in Flutter is critical; small mistakes break the whole run path.

**Next Steps:**
- Add main hub navigation and independent tab views.

**Screenshot Placeholder:**
- [INSERT SCREENSHOT 3: Login/sign-in screen]
- [INSERT SCREENSHOT 4: App bootstrapping code snippet]

---

### Week 3 (Jan 15 - Jan 21)
**Date/Time:** 2026-01-19, 19:00-23:00  
**Tasks Completed:**
- Built main hub with multi-tab navigation.
- Added Home, Explore, Leaderboard, and Profile screen stubs.
- Used IndexedStack to preserve tab state and improve UX continuity.

**Challenges Encountered:**
- Platform differences for bottom navigation behavior.

**Solution Attempted:**
- Implemented Cupertino tab bar for iOS and Material navigation for Android/other platforms.

**Reflection:**
- Platform-aware design improved professionalism and usability.

**Next Steps:**
- Begin API integration and live content rendering.

**Screenshot Placeholder:**
- [INSERT SCREENSHOT 5: Main hub with all tabs visible]
- [INSERT SCREENSHOT 6: iOS vs Android navigation comparison]

---

### Week 4 (Jan 22 - Jan 31)
**Date/Time:** 2026-01-28, 18:00-22:00  
**Tasks Completed:**
- Integrated NASA APOD API for Home content.
- Added network image handling and APOD summary display.
- Introduced graceful UI for API loading and error states.

**Challenges Encountered:**
- API variability (missing fields, media format differences).

**Solution Attempted:**
- Added default values and defensive model parsing.
- Added error builders for network image widgets.

**Reflection:**
- Defensive parsing made API features much more reliable.

**Next Steps:**
- Add local persistence and offline fallback behavior.

**Screenshot Placeholder:**
- [INSERT SCREENSHOT 7: APOD card loaded from API]
- [INSERT SCREENSHOT 8: Error/fallback card state]

---

## February 2026

### Week 5 (Feb 1 - Feb 7)
**Date/Time:** 2026-02-04, 19:30-22:30  
**Tasks Completed:**
- Implemented SharedPreferences caching for APOD data.
- Added offline fallback logic when API requests fail.
- Verified cached content retrieval on simulated network failure.

**Challenges Encountered:**
- Cache freshness and fallback branch verification.

**Solution Attempted:**
- Stored serialized APOD model and validated retrieval paths.

**Reflection:**
- Local persistence directly improved resilience and assignment alignment.

**Next Steps:**
- Expand Explore tab with asteroid feed and Earth gallery.

**Screenshot Placeholder:**
- [INSERT SCREENSHOT 9: Cache write/read code block]
- [INSERT SCREENSHOT 10: Offline APOD shown from cache]

---

### Week 6 (Feb 8 - Feb 14)
**Date/Time:** 2026-02-11, 18:00-23:00  
**Tasks Completed:**
- Added asteroid feed from NASA NEO API.
- Displayed near-earth object metadata (size, velocity, risk state).
- Created visual hazard indicators for potentially hazardous asteroids.

**Challenges Encountered:**
- Deeply nested JSON structures with inconsistent assumptions.

**Solution Attempted:**
- Introduced safe extraction pattern and controlled type parsing.

**Reflection:**
- Parsing real-world API data required stronger null safety discipline.

**Next Steps:**
- Add details modal for asteroid item interaction.

**Screenshot Placeholder:**
- [INSERT SCREENSHOT 11: Asteroid list with hazard badges]
- [INSERT SCREENSHOT 12: Parsed NEO JSON structure annotation]

---

### Week 7 (Feb 15 - Feb 21)
**Date/Time:** 2026-02-18, 19:00-22:00  
**Tasks Completed:**
- Added Earth gallery stream via NASA image search API.
- Built visual page-view layout for gallery content.
- Added loading and empty gallery fallback views.

**Challenges Encountered:**
- Long descriptions reduced readability in compact card layout.

**Solution Attempted:**
- Applied text truncation in card view and planned dedicated full-read interaction.

**Reflection:**
- Information density needs context-aware presentation.

**Next Steps:**
- Add post details modal for full descriptions.

**Screenshot Placeholder:**
- [INSERT SCREENSHOT 13: Earth gallery carousel/page view]
- [INSERT SCREENSHOT 14: Truncated description in card view]

---

### Week 8 (Feb 22 - Feb 28)
**Date/Time:** 2026-02-26, 18:30-23:00  
**Tasks Completed:**
- Implemented theme personalization with persistent dark/light preference.
- Connected profile settings to app-level theme update callback.
- Standardized app theme palette and typography treatment.

**Challenges Encountered:**
- Theme synchronization across nested widgets and navigation stack.

**Solution Attempted:**
- Centralized theme mode in app state and updated through callback pipeline.

**Reflection:**
- User personalization improved both UX and rubric coverage.

**Next Steps:**
- Build and connect quiz/gameplay loop with score updates.

**Screenshot Placeholder:**
- [INSERT SCREENSHOT 15: Theme toggle in profile settings]
- [INSERT SCREENSHOT 16: Light vs dark theme comparison]

---

## March 2026

### Week 9 (Mar 1 - Mar 7)
**Date/Time:** 2026-03-03, 19:00-23:00  
**Tasks Completed:**
- Completed quiz question rendering and answer selection flow.
- Added session scoring and final mission summary modal.
- Integrated score write-back behavior through repository layer.

**Challenges Encountered:**
- Ensuring consistent state transitions between question, answer, and next-step flow.

**Solution Attempted:**
- Explicit state flags (`answered`, `selectedAnswer`, current index) and controlled transitions.

**Reflection:**
- Simple, explicit state modeling reduced UI inconsistency bugs.

**Next Steps:**
- Add leaderboard retrieval and ranking presentation.

**Screenshot Placeholder:**
- [INSERT SCREENSHOT 17: Quiz question with options]
- [INSERT SCREENSHOT 18: Mission completed score summary modal]

---

### Week 10 (Mar 8 - Mar 14)
**Date/Time:** 2026-03-10, 18:30-22:30  
**Tasks Completed:**
- Added leaderboard retrieval and top-user list display.
- Improved fallback labels for missing user profile fields.
- Added stronger error handling in user repository methods.

**Challenges Encountered:**
- Incomplete backend profile data caused inconsistent labels.

**Solution Attempted:**
- Added safe defaults and formatting fallback strategy.

**Reflection:**
- Data quality issues should be treated as normal, not exceptional.

**Next Steps:**
- Expand test coverage (widget and unit tests).

**Screenshot Placeholder:**
- [INSERT SCREENSHOT 19: Leaderboard top users list]
- [INSERT SCREENSHOT 20: Missing-data fallback behavior]

---

### Week 11 (Mar 15 - Mar 17)
**Date/Time:** 2026-03-16, 19:00-22:00  
**Tasks Completed:**
- Added isolated widget tests for QuizScreen core states.
- Tested loading state, data render, and local interaction outcomes.
- Implemented fake repositories to avoid network/database coupling in tests.

**Challenges Encountered:**
- Initial test instability due to async timing and viewport/tap hit testing.

**Solution Attempted:**
- Used completer-based loading control and explicit test viewport sizing.

**Reflection:**
- Reliable tests require deterministic setup and controlled async flows.

**Next Steps:**
- Add additional edge-case tests and unit tests for core logic.

**Screenshot Placeholder:**
- [INSERT SCREENSHOT 21: Widget test file with AAA sections]
- [INSERT SCREENSHOT 22: Passing widget test output]

---

### Week 12 (Mar 18 - Mar 20)
**Date/Time:** 2026-03-19, 18:30-22:00  
**Tasks Completed:**
- Added additional widget tests for incorrect answer and empty/failure states.
- Added unit tests for model mapping and theme service behavior.
- Updated documentation for test process and traceability.

**Challenges Encountered:**
- Legacy starter test referenced removed template app class and failed aggregate runs.

**Solution Attempted:**
- Replaced starter test with stable baseline test; validated complete test command.

**Reflection:**
- Test suite health depends on removing stale templates, not just adding new tests.

**Next Steps:**
- Final polish, usability pass, and evaluation write-up.

**Screenshot Placeholder:**
- [INSERT SCREENSHOT 23: Unit test files overview]
- [INSERT SCREENSHOT 24: Full test run all pass]

---

### Week 13 (Mar 21)
**Date/Time:** 2026-03-21, 17:00-21:00  
**Tasks Completed:**
- Added full-description modal for Explore gallery posts.
- Added asteroid detail modal with expanded telemetry on tap.
- Fixed syntax/compile issue and validated clean diagnostics.
- Created consolidated documentation artifacts for testing and logging.

**Challenges Encountered:**
- Parenthesis mismatch introduced compile failure during UI refactor.

**Solution Attempted:**
- Performed focused code inspection around error line and corrected structure.

**Reflection:**
- Fast iteration requires disciplined validation after each UI change.

**Next Steps:**
- Final rubric mapping and submission packaging.

**Screenshot Placeholder:**
- [INSERT SCREENSHOT 25: Explore post modal with full description]
- [INSERT SCREENSHOT 26: Asteroid details modal]

---

## Evaluation

### 1. Final Build vs Initial Wireframe (with Evidence)
Use this section to annotate differences and explain design rationale.

**Planned Wireframe Intent:**
- Home: Hero content + quick actions
- Explore: Multi-content discovery (asteroids + gallery)
- Quiz: Task-driven interaction and score feedback
- Profile: User preferences and account context

**Final Build Alignment:**
- Home includes APOD hero card, quick navigation cards, and XP summary.
- Explore includes two content modes with interaction-rich modals.
- Quiz includes dynamic questions, answer validation, and mission completion dialog.
- Profile supports theme personalization and settings.

**Differences from Wireframe (and justification):**
- Added stronger visual affordances (badges, overlays, gradient cards) for readability and engagement.
- Added modal-based detail reading to reduce clutter in card-level layouts.
- Added platform-aware navigation adaptation for iOS/Android consistency.

**Screenshot Placeholder:**
- [INSERT SCREENSHOT A: Initial wireframe collage]
- [INSERT SCREENSHOT B: Final Home screen annotated]
- [INSERT SCREENSHOT C: Final Explore screen annotated]
- [INSERT SCREENSHOT D: Final Quiz screen annotated]
- [INSERT SCREENSHOT E: Final Profile/settings screen annotated]

---

### 2. Heuristic Evaluation (Critical Reflection)
Evaluation method used: Nielsen's 10 Usability Heuristics.

#### Heuristic 1: Visibility of system status
**Observed:**
- Loading spinners and state indicators are present across API views.

**Strengths:**
- Users receive immediate feedback during network requests.

**Gaps:**
- Some loading contexts could be made more descriptive (text + spinner).

**Improvement:**
- Add context-specific loading labels and estimated action hints.

#### Heuristic 2: Match between system and real world
**Observed:**
- Terminology like XP, mission, and cosmic intel matches app theme.

**Strengths:**
- Consistent thematic language reinforces engagement.

**Gaps:**
- A small number of labels are technical and could be simplified.

**Improvement:**
- Add optional plain-language tooltips for advanced terms.

#### Heuristic 3: User control and freedom
**Observed:**
- Users can switch tabs, dismiss dialogs, and navigate naturally.

**Strengths:**
- Non-destructive interactions and recoverable flows.

**Gaps:**
- Some modals could include stronger close affordance text.

**Improvement:**
- Add explicit close actions in all detail sheets.

#### Heuristic 4: Consistency and standards
**Observed:**
- Typography and visual language are mostly consistent.

**Strengths:**
- Shared design style across screens and components.

**Gaps:**
- Minor spacing/size variation still exists between sections.

**Improvement:**
- Introduce a tokenized spacing system and shared component styles.

#### Heuristic 5: Error prevention
**Observed:**
- Defensive parsing and fallback states prevent many crashes.

**Strengths:**
- Null safety and fallback strings reduce runtime failures.

**Gaps:**
- More precondition checks can be added in complex API transformations.

**Improvement:**
- Add stricter validation around nested API fields.

#### Heuristic 6: Recognition rather than recall
**Observed:**
- Navigation labels and icons reduce memory load.

**Strengths:**
- Persistent tab structure helps users re-locate features quickly.

**Gaps:**
- Certain advanced data points need inline hints.

**Improvement:**
- Add short helper text under specialized metrics.

#### Heuristic 7: Flexibility and efficiency of use
**Observed:**
- Fast switching between content tabs and direct interaction cards.

**Strengths:**
- Supports both exploration and targeted usage.

**Gaps:**
- No quick filters/sort options for long content lists.

**Improvement:**
- Add simple filter chips (e.g., hazard-only asteroids).

#### Heuristic 8: Aesthetic and minimalist design
**Observed:**
- Strong visual identity with thematic design and controlled content hierarchy.

**Strengths:**
- High visual quality and coherent branding.

**Gaps:**
- Some data-heavy views could reduce secondary decoration.

**Improvement:**
- Tone down visual density in information-dense sections.

#### Heuristic 9: Help users recognize, diagnose, recover from errors
**Observed:**
- Error UIs communicate failures without crashing.

**Strengths:**
- Friendly error messaging and fallback data behavior.

**Gaps:**
- Some errors could include direct retry actions.

**Improvement:**
- Add Retry buttons for API failure states.

#### Heuristic 10: Help and documentation
**Observed:**
- Developer-facing documentation exists for test process and implementation details.

**Strengths:**
- Good internal traceability and maintainability.

**Gaps:**
- End-user guidance is limited in-app.

**Improvement:**
- Add a lightweight in-app help/about section.

---

## Critical Summary
The final build demonstrates strong technical progression, consistent problem solving, and thoughtful adaptation from initial wireframes to implementation reality. The project shows robust handling of asynchronous content, progressive resilience improvements, and meaningful testing coverage. The largest future gains are in expanded offline support consistency, richer user assistance, and additional efficiency controls for data-heavy screens.

**Screenshot Placeholder:**
- [INSERT SCREENSHOT F: Heuristic annotation example with callouts]
- [INSERT SCREENSHOT G: Error handling state comparison]
- [INSERT SCREENSHOT H: Final polished UI montage]
