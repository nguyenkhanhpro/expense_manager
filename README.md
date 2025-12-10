# Expense Manager

Expense Manager là ứng dụng quản lý thu – chi cá nhân đa nền tảng được phát triển bằng Flutter kết hợp backend Dart. Ứng dụng giúp người dùng theo dõi chi tiêu hằng ngày một cách trực quan, dễ sử dụng và hiệu quả. Với hệ thống danh mục linh hoạt, lịch sử giao dịch chi tiết và báo cáo tổng quan thu – chi theo thời gian, người dùng có thể kiểm soát dòng tiền của mình tốt hơn. Dữ liệu được lưu trữ bằng SQLite kết hợp API RESTful, đảm bảo tốc độ xử lý nhanh và hoạt động ổn định trên nhiều thiết bị như Android, iOS, web và desktop.

## 1. Giới thiệu & Kiến trúc
- Frontend Flutter (mobile/web/desktop) gọi API qua `ApiService`.
- Backend Dart (Shelf) + SQLite FFI, cung cấp RESTful API `/api/categories`, `/api/transactions`, `/api/summary`.
- CORS mở để chạy trên thiết bị thật/giả lập.
- Dữ liệu mẫu category được seed tự động khi khởi tạo DB.

## 2. Tính năng đã hoàn thiện
- CRUD danh mục (thu/chi) và giao dịch.
- Tính toán tổng thu, tổng chi, số dư; hiển thị biểu đồ chia quỹ đơn giản.
- UI thân thiện: màn hình tổng quan, thêm giao dịch, lịch sử, cập nhật sau thao tác không cần reload app.
- Xử lý lỗi API, snackbar thông báo rõ ràng.
- Hỗ trợ build đa nền tảng, có widget tests mẫu.

## 3. Công nghệ & Thư viện chính
- Flutter, Dart.
- Backend: `shelf`, `shelf_router`, `sqflite_common_ffi`.
- HTTP client: `http`.
- Kiểm thử: `flutter_test`, `mockito` (nếu cần mở rộng), widget test mẫu.
- CI/CD: GitHub Actions (workflow `ci.yml`, chạy `flutter analyze`, `flutter test`).

## 4. Hướng dẫn cài đặt & chạy
### Cài đặt môi trường
- Cài đặt Flutter SDK: https://flutter.dev/
- Cài đặt máy ảo Android/iOS hoặc sử dụng thiết bị thật.
### clone repository
```bash 
git clone https://github.com/nguyenkhanhpro/expense_manager.git
cd expense_manager
```
### Backend (Dart)
```bash
cd backend
dart pub get
dart run bin/backend.dart
# Server chạy tại http://localhost:8080
```

### Frontend (Flutter)
```bash
cd frontend
flutter pub get
# Cấu hình host API trong lib/services/platform_host_io.dart nếu cần
flutter doctor # kiểm tra môi trường
flutter run -d windows   # hoặc chrome/android/ios
```

## 5. API nổi bật
- `GET /api/categories` — danh sách danh mục.
- `POST /api/categories` — thêm danh mục `{name,type,icon}`.
- `PUT /api/categories/:id` — cập nhật danh mục.
- `DELETE /api/categories/:id` — xóa danh mục (kèm giao dịch liên quan).
- `GET /api/transactions` — danh sách giao dịch (mới nhất trước).
- `POST /api/transactions` — thêm giao dịch `{amount,categoryId,note,date,type}`.
- `PUT /api/transactions/:id` — cập nhật giao dịch.
- `DELETE /api/transactions/:id` — xóa giao dịch.
- `GET /api/summary` — `{income, expense, balance}`.

## 6. Kiểm thử & chất lượng
- Backend: unit test cho database và routes (thư mục `backend/test`).
- Frontend: widget test (thư mục `frontend/test`), có thể thêm mock API để bao phủ CRUD.
- Chạy toàn bộ kiểm thử:
```bash
# Backend
cd backend
dart test                       # Chạy tất cả test
dart test test/database_test.dart  # Chạy test cụ thể
# Frontend
cd frontend
flutter test                    # Chạy tất cả test
flutter test test/history_screen_test.dart  # Chạy test cụ thể
```

## 7. CI/CD
- GitHub Actions workflow `ci.yml` (thư mục `.github/workflows`) chạy:
  - `flutter analyze` cho frontend.
  - `flutter test` cho frontend, `dart test` cho backend.
  - Build/check đa nền tảng nếu cần mở rộng.

## 8. Quá trình thực hiện
- Thiết kế DB: 2 bảng `categories`, `transactions`, ràng buộc khóa ngoại, seed dữ liệu mặc định.
- API: tách router `CategoryRoutes`, `TransactionRoutes`, middleware CORS + logging.
- Frontend: màn hình Home tóm tắt số dư, thêm giao dịch (thu/chi), lịch sử, thẻ phân bổ quỹ.
- Xử lý lỗi: bắt exception API, snackbar thông báo, refresh dữ liệu sau thao tác.
- Đã viết test mẫu và cấu hình CI để build/test tự động.
- video demo: [video demo](https://drive.google.com/file/d/17nzVr8yljPSGp_r2ilZzYbZtfu9SPgWW/view?usp=sharing)

## 9. Hướng dẫn demo nhanh
1) Chạy backend: `dart run bin/backend.dart`.
2) Chạy frontend: `flutter run` (đảm bảo API host khớp).
3) Tạo giao dịch thu/chi, xem cập nhật số dư và lịch sử.
4) Chạy kiểm thử: `dart test` và `flutter test`.
5) Kiểm tra CI trên GitHub Actions: trạng thái Success.
6) Có thêm xem qua video demo nếu cần [video demo]  (https://drive.google.com/file/d/17nzVr8yljPSGp_r2ilZzYbZtfu9SPgWW/view?usp=sharing).


