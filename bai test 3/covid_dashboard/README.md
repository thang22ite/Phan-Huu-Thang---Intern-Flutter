# COVID-19 Vietnam Behavioral Dashboard 🚀

Một ứng dụng Flutter Web chuyên sâu về trực quan hóa dữ liệu hành vi cộng đồng trong đại dịch COVID-19 tại Việt Nam. Dự án được xây dựng với các tiêu chuẩn kỹ thuật cao cấp, tập trung vào tính tương tác và thẩm mỹ hiện đại.

---

## Kiến trúc Hệ thống (Architecture)

Dự án tuân thủ nghiêm ngặt nguyên lý **Clean Architecture**, chia tách mã nguồn thành 3 lớp rõ rệt để đảm bảo tính bảo trì và mở rộng:

1.  **Lớp Domain (Cốt lõi)**:
    - Định nghĩa các thực thể (`CovidRecord`) và giao diện Repository (`ICovidRepository`). 
    - Đây là lớp "thuần khiết" không phụ thuộc vào bất kỳ thư viện bên ngoài nào.
2.  **Lớp Data (Dữ liệu)**:
    - Triển khai Logic tải dữ liệu CSV từ GitHub (YouGov raw data).
    - Xử lý Parse dữ liệu thủ công để đảm bảo tính chính xác và hiệu năng cao nhất trên môi trường Web.
3.  **Lớp Presentation (Giao diện & Trạng thái)**:
    - Quản lý trạng thái bằng **Bloc Pattern**, giúp tách biệt hoàn toàn Logic nghiệp vụ khỏi UI.
    - Hệ thống định danh giao diện đồng nhất qua các Widget tùy chỉnh.

---


## Chức năng Chính (Core Features)

1.  **Phân tích Xu hướng Hành vi (Behavioral Trends)**:
    - Theo dõi tỷ lệ đeo khẩu trang, rửa tay theo thời gian.
    - Hỗ trợ **Universal Zoom**: Phóng to từng điểm dữ liệu để xem con số chính xác theo ngày.
2.  **Hồ sơ Đa chiều (Multi-dimensional Radar)**:
    - Sử dụng Radar Chart để so sánh 6 chỉ số hành vi cùng lúc (Khẩu trang, Rửa tay, Tụ tập, Đám đông, Ở nhà, Nỗi sợ).
3.  **Phân bổ Vùng miền (Regional Distribution)**:
    - Biểu đồ Tròn (Pie Chart) trực quan hóa dữ liệu theo 6 vùng lớn của Việt Nam.
    - Chú thích thông minh tự động xử lý tràn chữ và hỗ trợ zoom để xem số liệu tuyệt đối.
4.  **Nhân khẩu học (Age Demographics)**:
    - Biểu đồ Cột (Bar Chart) phân tích tỷ lệ tham gia khảo sát theo từng nhóm độ tuổi.
5.  **Bộ lọc Thời gian Thông minh**:
    - Cho phép lọc dữ liệu theo khoảng ngày bất kỳ, toàn bộ dashboard sẽ cập nhật dữ liệu mượt mà trong thời gian thực.
6.  **Tương tác Nâng cao (Interactive Zoom)**: 
    - Toàn bộ 5 loại biểu đồ đều hỗ trợ thu phóng để "soi" sâu vào từng con số cụ thể, giúp người dùng khai phá dữ liệu tầng sâu.

---

## 🛠️ Công nghệ Sử dụng

- **Flutter SDK**: Phiên bản mới nhất, tối ưu cho Web.
- **fl_chart**: Thư viện biểu đồ mạnh mẽ nhất hiện nay.
- **flutter_bloc**: Quản lý trạng thái chuyên nghiệp.
- **http & csv**: Xử lý mạng và xử lý dữ liệu cấu trúc.
- **intl**: Định dạng thời gian và ngôn ngữ.

---

