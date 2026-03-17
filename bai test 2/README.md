# Personal Expense Tracker - Quản Lý Chi Tiêu Cá Nhân 

Ứng dụng quản lý chi tiêu cá nhân hiện đại, được xây dựng bằng **Flutter** theo kiến trúc **Clean Architecture**, tích hợp **Supabase** để lưu trữ đám mây. Giao diện được thiết kế theo phong cách **Glassmorphism** lấp lánh và hiện đại.

## Tính Năng Nổi Bật

-   **Quản Lý Thu Chi**: Ghi chép chi phí và thu nhập với tiêu đề, số tiền, danh mục và ngày tháng.
-   **Giao Dịch Lặp Lại (Recurring)**: Tự động tạo giao dịch định kỳ (Hàng ngày, Hàng tuần, Hàng tháng).
-   **Thiết Lập Ngân Sách (Budgeting)**: 
    -   Đặt hạn mức chi tiêu cho từng danh mục theo tháng.
    -   Thanh tiến trình (Progress Bar) trực quan: Chuyển màu từ Xanh sang Đỏ khi sắp vượt mức.
    -   Cảnh báo thông minh: Hiển thị Dialog xác nhận khi người dùng nhập khoản chi vượt ngân sách.
-   **Báo Cáo & Thống Kê**:
    -   Biểu đồ cột (Bar Chart) so sánh Thu nhập - Chi phí - Số dư theo Ngày/Tháng/Năm.
    -   Biểu đồ tròn (Pie Chart) phân tích cơ cấu chi tiêu theo danh mục.
-   **Bộ Lọc & Tìm Kiếm Nâng Cao**: Tìm kiếm theo tên, lọc theo loại (Thu/Chi) và khoảng ngày.
-   **Xuất Dữ Liệu (Export CSV)**:
    -   Hỗ trợ đa nền tảng (Web & Mobile).
    -   **Web**: Tải file trực tiếp qua trình duyệt sử dụng Blob & Anchor element.
    -   **Mobile**: Chia sẻ file .csv qua các ứng dụng (Zalo, Email...).
    -   **Sửa lỗi Font**: Tích hợp UTF-8 BOM để Excel hiển thị đúng tiếng Việt có dấu.
-   **Giao Diện Premium**: 
    -   Phong cách Glassmorphism (Kính mờ) hiện đại.
    -   Đơn vị tiền tệ: **VNĐ** (Định dạng dấu phẩy phân cách hàng nghìn).

## Công Nghệ Sử Dụng

-   **Frontend**: Flutter (Dart).
-   **Backend**: Supabase (PostgreSQL, Realtime, Auth).
-   **Kiến Trúc**: Clean Architecture (Data, Domain, Presentation layers).
-   **Quản Lý Trạng Thái (State Management)**: BLoC (Business Logic Component).
-   **Thư Viện Phụ Trợ**:
    -   `fl_chart`: Vẽ biểu đồ chuyên nghiệp.
    -   `intl`: Định dạng tiền tệ và ngày tháng.
    -   `csv`: Xử lý dữ liệu bảng tính.
    -   `url_launcher`: Xử lý tải file trên Web.
    -   `share_plus`: Chia sẻ file trên Mobile.

## Kiến Trúc Dự Án (Clean Architecture)

Dự án tuân thủ nghiêm ngặt mô hình 3 lớp để đảm bảo khả năng mở rộng và bảo trì:

1.  **Presentation**: Chứa các Widget UI (Glassmorphism), BLoC States và Events.
2.  **Domain**: Chứa các Entity (thực thể lõi) và UseCases (nghiệp vụ chính).
3.  **Data**: Triển khai Repository, Models (Mapper) và Data Sources (gọi API Supabase).



