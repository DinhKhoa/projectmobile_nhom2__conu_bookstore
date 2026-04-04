import 'package:flutter_test/flutter_test.dart';
import 'package:projectmobile_nhom2__conu_bookstore/app/app.dart';

void main() {
  testWidgets('App should render login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ConuBookstoreApp());
    await tester.pumpAndSettle();

    expect(find.text('Đăng nhập vào cửa hàng của bạn'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);
  });
}
