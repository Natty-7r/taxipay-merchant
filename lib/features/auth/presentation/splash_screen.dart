import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: AppTheme.white,
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            BrandLogo(size: 200),
            SizedBox(height: 32),
            SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3)),
          ]),
        ),
      );
}
