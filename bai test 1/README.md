# Ứng dụng Tối ưu hóa Tuyến đường Giao hàng (Delivery Route Optimization)

Một ứng dụng Flutter hiện đại được thiết kế để giải quyết và trực quan hóa bài toán tối ưu hóa tuyến đường giao hàng có ràng buộc. Ứng dụng sử dụng **thuật toán tìm đường dựa trên phương pháp Tham lam (Greedy)** để điều khiển xe tải di chuyển trên lưới tọa độ, thực hiện lấy và giao hàng trong khi vẫn tuân thủ nghiêm ngặt các giới hạn về nhiên liệu và tải trọng.

Dự án được xây dựng với **Kiến trúc sạch (Clean Architecture)** và **BLoC (Business Logic Component)** để đảm bảo khả năng bảo trì và kiểm thử cao.

## Tính năng nổi bật

-   **Cấu hình kịch bản linh hoạt:** Cho phép nhập kích thước lưới (n × m), vị trí xuất phát của xe, tải trọng tối đa (W) và dung tích bình xăng (F).
-   **Tạo dữ liệu ngẫu nhiên:** Các đơn hàng (vị trí lấy/giao và trọng lượng) và Trạm xăng được hệ thống tạo ngẫu nhiên dựa trên số lượng người dùng yêu cầu.
-   **Bộ giải thuật tối ưu (Route Solver):**
    -   **Quản lý tải trọng:** Đảm bảo xe không bao giờ chở quá trọng tải quy định.
    -   **Kiểm tra an toàn xăng:** Tự động tính toán liệu xe có đủ xăng để đi đến mục tiêu *vừa đủ* để sau đó đi tiếp đến trạm xăng gần nhất hay không. Nếu không, xe sẽ ưu tiên đi đổ xăng trước.
    -   **Khoảng cách Manhattan:** Sử dụng công thức tính khoảng cách Manhattan để di chuyển trên lưới ô vuông.
    -   **Quay về điểm xuất phát:** Tự động tìm đường quay về tọa độ xuất phát sau khi đã hoàn thành tất cả các đơn hàng.
-   **Trực quan hóa sinh động:**
    -   **Animation thời gian thực:** Xem xe di chuyển từng bước với độ trễ 100ms.
    -   **Bảng điều khiển (Dashboard):** Theo dõi lượng xăng hiện tại, tải trọng hiện tại và tổng quãng đường đã đi.
    -   **Màn hình tổng kết:** Hiển thị thông tin chi tiết về thông số kịch bản và kết quả sau khi kết thúc mô phỏng.

## Kiến trúc dự án

Dự án tuân thủ mô hình **Clean Architecture** để tách biệt các thành phần:

-   **Core:** Chứa các tiện ích dùng chung, hằng số (tiêu thụ nhiên liệu) và model `AppConfig`.
-   **Domain:**
    -   **Entities:** Các thực thể dữ liệu thuần túy như `Truck`, `Order`, `GasStation`, `Point2D`, và `StepRecord`.
    -   **Repositories:** Định nghĩa giao diện (interface) cho bộ giải thuật `RouteSolver`.
-   **Data:**
    -   **Repositories:** Triển khai thực tế giải thuật `GreedyRouteSolverImpl`.
-   **Presentation:**
    -   **BLoC:** `SimulationCubit` quản lý trạng thái của quá trình mô phỏng và logic phát lại (playback).
    -   **Widgets:** `MapPainter` (sử dụng `CustomPainter`) để vẽ lưới và `ControlPanel` cho các nút điều khiển.
    -   **Pages:** `SetupPage` để cấu hình và `HomePage` để hiển thị mô phỏng.

## Giải thuật (Greedy Solver)

Bộ giải thuật triển khai phương pháp tiếp cận tham lam (greedy) kết hợp với kiểm tra an toàn:

1.  **Lựa chọn:** Trong mỗi bước, thuật toán xác định tất cả các hành động khả thi tiếp theo (lấy đơn hàng mới nếu còn chỗ hoặc giao đơn hàng đang chở).
2.  **Độ ưu tiên:** Chọn mục tiêu gần nhất dựa trên khoảng cách Manhattan.
3.  **Xác thực xăng:** Trước khi di chuyển, hệ thống kiểm tra điều kiện:
    `Xăng hiện tại >= Khoảng cách(Đến mục tiêu) + Khoảng cách(Từ mục tiêu đến Trạm xăng gần nhất)`.
    Nếu không đủ, xe sẽ ưu tiên di chuyển đến trạm xăng gần nhất từ vị trí hiện tại.
4.  **Di chuyển:** Tạo ra một chuỗi các bước di chuyển (Lên/Xuống/Trái/Phải), tiêu hao 0.05L xăng cho mỗi ô.
5.  **Kết thúc:** Khi danh sách hàng chờ và hàng trên xe đều trống, thuật toán tạo đường đi quay về tọa độ xuất phát.

## Công nghệ sử dụng

-   **Framework:** Flutter (Mobile/Desktop/Web)
-   **Quản lý trạng thái:** `flutter_bloc`
-   **Ngôn ngữ:** Dart
-   **Đồ họa:** `CustomPainter` API



