Copy lib/, analysis_options.yaml and NOTES.md over the Practice 11 repo (adapt names if yours differ), then:

flutter pub add shared_preferences flutter_secure_storage path_provider image_picker permission_handler url_launcher
dart format .
flutter analyze

Apply platform_config.md. Take screenshot_offline_banner.png and screenshot_permission_dialog.png yourself and commit them.
Check: grep -rl "package:http" lib   -> main.dart, core/net/api_client.dart only.
