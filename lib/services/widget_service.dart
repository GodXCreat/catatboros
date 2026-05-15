import 'package:home_widget/home_widget.dart';

class WidgetService {
  static const androidWidgetName = 'CatatBorosWidgetProvider';

  Future<void> updateTodayTotal({required String total, required String subtitle}) async {
    try {
      await HomeWidget.saveWidgetData<String>('today_total', total);
      await HomeWidget.saveWidgetData<String>('widget_subtitle', subtitle);
      await HomeWidget.updateWidget(androidName: androidWidgetName);
    } catch (_) {}
  }
}
