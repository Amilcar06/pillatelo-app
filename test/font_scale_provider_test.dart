import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_gestion_financiera_personal/core/providers/font_scale_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FontScaleProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Valores por defecto son escala 1.0, label Normal y step 0', () {
      final provider = FontScaleProvider();
      expect(provider.scale, 1.0);
      expect(provider.label, 'Normal');
      expect(provider.stepIndex, 0);
    });

    test('setFromStep cambia correctamente escala, label y stepIndex', () async {
      final provider = FontScaleProvider();

      await provider.setFromStep(1);
      expect(provider.scale, 1.15);
      expect(provider.label, 'Grande');
      expect(provider.stepIndex, 1);

      await provider.setFromStep(2);
      expect(provider.scale, 1.3);
      expect(provider.label, 'Muy Grande');
      expect(provider.stepIndex, 2);

      await provider.setFromStep(0);
      expect(provider.scale, 1.0);
      expect(provider.label, 'Normal');
      expect(provider.stepIndex, 0);
    });

    test('init restaura escala guardada en SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'font_scale': 1.3});
      final provider = FontScaleProvider();
      await provider.init();

      expect(provider.scale, 1.3);
      expect(provider.label, 'Muy Grande');
      expect(provider.stepIndex, 2);
    });
  });
}
