# Vietnam University Network Graph

Ứng dụng Flutter trực quan hóa mạng lưới các trường đại học tại Việt Nam , tuân thủ nghiêm ngặt **Clean Architecture** và quản lý trạng thái bằng **Bloc**.

## Tổng quan giải pháp

Dự án xử lý bài toán hiển thị dữ liệu mạng lưới (Graph) phức tạp bằng cách kết hợp giữa tính toán vật lý (Physics-based) và đồ họa tùy chỉnh (Custom Graphic). Mục tiêu là tạo ra một trải nghiệm người dùng sống động, nơi dữ liệu không chỉ là các con số mà là những thực thể tương tác được trong không gian 2D.

### Các điểm nhấn kỹ thuật:
- **Kiến trúc sạch (Clean Architecture):** Phân chia rõ ràng giữa Domain, Data và Presentation layers giúp mã nguồn dễ bảo trì, mở rộng và kiểm thử độc lập.
- **Quản lý trạng thái (State Management):** Sử dụng `flutter_bloc` để tách biệt logic xử lý dữ liệu (filter, select, update position) khỏi giao diện.
- **Hiệu ứng Anti-Gravity:** Kết hợp thiết kế Glassmorphism (hiệu ứng kính mờ) với các lớp đổ bóng (BoxShadow) sâu để tạo cảm giác các Node đang lơ lửng trong không gian "không trọng lực".
- **Tương tác Vật lý:** Tích hợp `SpringSimulation` cho hiệu ứng kéo thả (Drag & Drop) mượt mà, có độ nảy vật lý khi nhả tay.
- **Đồ họa tùy chỉnh:** Sử dụng `CustomPainter` để vẽ các đường kết nối (Edges) bằng đường cong Bézier mượt mà, tự động cập nhật theo vị trí thực tế của Node.

## Các chức năng chính (Features)

- **Trực quan hóa đồ thị (Graph Visualization):** Hiển thị mạng lưới phân cấp giữa 3 khu vực (Bắc, Trung, Nam) và 25 trường đại học với tọa độ được tính toán thẩm mỹ.
- **Tương tác kéo thả (Drag & Drop):** Người dùng có thể tự do di chuyển bất kỳ Node nào. Khi kéo thả, các đường nối (Edges) sẽ tự động uốn lượn và co giãn theo thời gian thực.
- **Hiệu ứng vật lý (Spring Physics):** Khi kết thúc hành động kéo, các Node sẽ nảy nhẹ (bounce) và tự tìm về trạng thái cân bằng nhờ hệ thống giả lập lò xo.
- **Phóng to & Thu nhỏ (Infinite Canvas):** Sử dụng `InteractiveViewer` cho phép điều hướng không giới hạn không gian đồ thị.
- **Bộ lọc thông minh (Region Filtering):** Cung cấp các Filter Chips phía trên màn hình để lọc trường đại học theo khu vực. Các trường không thuộc vùng chọn sẽ được làm mờ (dimming) bằng hiệu ứng Opacity Animation mượt mà.
- **Thông tin chi tiết (Quick Info):** Nhấn vào một Node để hiển thị Card thông tin trôi nổi (Glassmorphism card) chứa: Tên đầy đủ, mã trường, số lượng sinh viên, giảng viên và loại hình đào tạo.
- **Kích thước Node động (Data-driven Scaling):** Kích thước của mỗi Node trường đại học tự động thay đổi dựa trên số lượng sinh viên thực tế.
- **Hệ thống màu sắc Gradient (Dynamic Coloring):** Màu sắc của Node được đổ Gradient dựa trên số lượng giảng viên, giúp nhận diện quy mô nhân lực của trường ngay lập tức qua thị giác.

## Cấu trúc thư mục (Clean Architecture)

```plaintext
lib/
  ├── core/
  │    ├── constants/      # AppColors, PhysicsConfigs (Cấu hình bóng đổ, vật lý)
  │    └── utils/          # Logic tính toán kích thước Node theo số lượng sinh viên
  ├── domain/
  │    ├── entities/       # Region, University (Thực thể dữ liệu cốt lõi)
  │    └── repositories/   # Interface của Repository (Tính trừu tượng)
  ├── data/
  │    ├── models/         # UniversityModel (Dữ liệu có khả năng Serialize)
  │    ├── datasources/    # Mock data 25 trường đại học tiêu biểu tại VN
  │    └── repositories/   # Triển khai thực tế của Repository lấy dữ liệu
  ├── presentation/
  │    ├── bloc/           # Quản lý sự kiện: Tải đồ thị, Lọc vùng, Kéo thả node
  │    ├── pages/          # NetworkGraphPage (Trang chính hiển thị không gian mạng lưới)
  │    └── widgets/        # NodeWidget (Vật lý), EdgePainter (Vẽ dây nối), InfoCard (Tooltip)
  └── main.dart            # Cấu hình Dependency Injection và khởi chạy App
```

## Cách xử lý bài toán (Approach)

1.  **Mô hình hóa dữ liệu (Modeling):** Các trường đại học được phân nhóm theo 3 khu vực chính (Bắc, Trung, Nam). 
    - **Kích thước Node:** Tính toán động dựa trên lượng sinh viên.
    - **Màu sắc Node:** Gradient thay đổi dựa trên số lượng giảng viên (thể hiện quy mô đào tạo).
2.  **Hệ thống tọa độ động:** Toàn bộ bản đồ được đặt trong `InteractiveViewer`, cho phép người dùng phóng to/thu nhỏ (Zoom) và di chuyển (Pan) tự do. Tọa độ các Node được quản lý tập trung trong Bloc, cho phép vẽ lại các đường kết nối ngay khi Node bị kéo lê.
3.  **Vẽ kết nối (Bezier Curves):** Edges sử dụng `CustomPainter` vẽ dưới cùng layer. Thuật toán sử dụng đường cong Bézier bậc 3 nối từ University Node đến trung tâm của Region Node tương ứng, tạo sự mềm mại và liên kết tự nhiên.
4.  **Phản hồi tương tác (User Feedback):**
    - Khi **Hover/Touch**: Node thu nhỏ nhẹ (`onPanStart`) và nảy lại khi thả (`SpringSimulation`).
    - Khi **Select**: Hiển thị `InfoCard` trôi nổi với hiệu ứng Blur nền (BackdropFilter).
    - Khi **Filter**: Các node không thuộc vùng chọn sẽ mờ đi (giảm Opacity) để làm nổi bật dữ liệu quan trọng.

