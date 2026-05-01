# 📚 CONU Bookstore - Detailed Project Structure

Dưới đây là cấu trúc chi tiết toàn bộ các tệp tin mã nguồn của dự án, được tổ chức theo kiến trúc **Clean Architecture**.

```text
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart           # Màu sắc chủ đạo (Primary, Secondary, Background)
│   │   ├── app_constants.dart        # Các hằng số API URL, Timeout
│   │   ├── app_sizes.dart            # Kích thước lề (padding), bo góc (radius)
│   │   └── app_text_styles.dart      # Kiểu chữ (Font size, weight, height)
│   ├── error/
│   │   └── failures.dart             # Định nghĩa các loại lỗi hệ thống (Server, Cache)
│   ├── theme/
│   │   └── app_theme.dart            # Cấu hình ThemeData cho ứng dụng
│   ├── usecases/
│   │   └── usecase.dart              # Lớp trừu tượng cho mọi UseCase
│   ├── utils/
│   │   ├── error_handler.dart        # Xử lý lỗi Dio và chuyển đổi sang tiếng Việt
│   │   └── formatters.dart           # Định dạng tiền tệ VND và ngày tháng Việt Nam
│   ├── widgets/
│   │   ├── app_drawer.dart           # Menu điều hướng bên trái (Drawer)
│   │   ├── app_logo.dart             # Logo ứng dụng
│   │   ├── common_app_bar.dart       # Thanh tiêu đề dùng chung cho các màn hình
│   │   ├── notification_dialog.dart  # Thông báo thành công/lỗi tập trung
│   │   └── widgets.dart              # Export tập trung các widgets
│   └── core.dart                     # Export tập trung các thành phần core
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       └── login_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       └── screens/
│   │           └── login_screen.dart
│   ├── category/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── category_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── category_model.dart
│   │   │   └── repositories/
│   │   │       └── category_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── category_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── category_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_categories_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── category_bloc.dart
│   │       │   ├── category_event.dart
│   │       │   └── category_state.dart
│   │       └── screens/
│   │           ├── add_category_screen.dart
│   │           ├── category_detail_screen.dart
│   │           └── category_screen.dart
│   ├── customer/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── customer_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── customer_model.dart
│   │   │   └── repositories/
│   │   │       └── customer_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── customer_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── customer_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_customers_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── customer_bloc.dart
│   │       │   ├── customer_event.dart
│   │       │   └── customer_state.dart
│   │       └── screens/
│   │           ├── customer_detail_screen.dart
│   │           └── customer_screen.dart
│   ├── home/
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── dashboard_bloc.dart
│   │       └── screens/
│   │           └── home_screen.dart
│   ├── product/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── product_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   └── product_model.dart
│   │   │   └── repositories/
│   │   │       └── product_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── product_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── product_repository.dart
│   │   │   └── usecases/
│   │   │       └── get_all_products_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── product_bloc.dart
│   │       │   ├── product_event.dart
│   │       │   └── product_state.dart
│   │       └── screens/
│   │           ├── product_detail_screen.dart
│   │           └── products_screen.dart
│   ├── report/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── report_remote_data_source.dart
│   │   │   ├── repositories/
│   │   │   │   └── report_repository_impl.dart
│   │   │   └── report_models.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── report_entity.dart
│   │   │   └── repositories/
│   │   │       └── report_repository.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── report_bloc.dart
│   │       │   ├── report_event.dart
│   │       │   └── report_state.dart
│   │       ├── screens/
│   │           └── report_screen.dart
│   │       └── widgets/
│   │           ├── report_data_table.dart
│   │           ├── report_summary_card.dart
│   │           └── revenue_bar_chart.dart
│   └── sales/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── order_remote_data_source.dart
│       │   ├── models/
│       │   │   └── order_model.dart
│       │   └── repositories/
│       │       └── order_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── order_entity.dart
│       │   └── repositories/
│       │       └── order_repository.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── sales_bloc.dart
│           │   ├── sales_event.dart
│           │   └── sales_state.dart
│           ├── screens/
│               ├── add_sale_screen.dart
│               ├── sale_detail_screen.dart
│               └── sales_screen.dart
│           └── widgets/
│               └── (các widgets con cho sales)
├── navigation/
│   └── main_screen.dart               # Màn hình khung (Scaffold chính của app)
├── features.dart                     # Export tập trung các màn hình chính
├── injection_container.dart          # Cấu hình Dependency Injection (GetIt)
└── main.dart                         # Hàm main() khởi chạy ứng dụng
```
