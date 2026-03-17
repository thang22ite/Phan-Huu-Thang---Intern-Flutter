# Hệ Thống Dự Đoán Dân Số Toàn Cầu (Population Prediction System)

Dự án này là một hệ thống dự đoán dân số các quốc gia trong tương lai dựa trên dữ liệu lịch sử, sử dụng Machine Learning. Hệ thống được xây dựng theo kiến trúc **Clean Architecture** nghiêm ngặt cho cả Backend và Frontend để đảm bảo tính mở rộng và dễ bảo trì.

## Tính Năng Chính
- **AI Đa Mô Hình:** Hỗ trợ dự báo bằng 3 thuật toán: Linear Regression, Random Forest và Gradient Boosting.
- **Dữ liệu 25 Quốc gia:** Gồm Việt Nam, Mỹ, Trung Quốc, Ấn Độ và nhiều quốc gia khác (dữ liệu lịch sử 2000-2024).
- **Trực quan hóa sinh động:** Biểu đồ đường (Line Chart) so sánh kết quả dự báo của các mô hình khác nhau.
- **Đánh giá AI:** Tự động tính toán các chỉ số lỗi MAE (Mean Absolute Error) và RMSE (Root Mean Squared Error).

---

## Kiến Trúc Hệ Thống (Clean Architecture)

Dự án được phân tách rạch ròi thành các lớp (layers) để đảm bảo Core Logic không phụ thuộc vào Framework.

### 1. Python Backend (FastAPI)
- **Domain:** Định nghĩa các Entities (Country, PredictionResult) và Interfaces (IModelRepository).
- **Use Cases:** Chứa logic xử lý yêu cầu dự đoán và tính toán metrics.
- **Infrastructure:**
    - `ml_models/`: Chứa các Model Adapter (Scikit-learn).
    - `data_adapters/`: Xử lý đọc dữ liệu từ file CSV.
- **API:** Cung cấp RESTful API bằng FastAPI.

### 2. Flutter Frontend
- **Domain:** Chứa các thực thể và định nghĩa Repository Interface.
- **Data:** Triển khai Repository gọi API qua HTTP, parse JSON thành Model.
- **Presentation:**
    - **BLoC:** Quản lý logic trạng thái (Initial, Loading, Loaded, Error).
    - **UI:** Giao diện Material 3 với bộ lọc thông minh và biểu đồ `fl_chart`.

---

## Công Nghệ Sử Dụng

| Thành phần | Công nghệ |
| :--- | :--- |
| **Backend** | Python 3.14+, FastAPI, Scikit-learn, Pandas, Numpy, Uvicorn |
| **Frontend** | Flutter (Dart), BLoC Pattern, fl_chart, get_it (DI), http |
| **Kiến trúc** | Clean Architecture (Domain - Data - Presentation) |

---


## Giải Thích Thuật Toán AI và Đánh Giá
Trong hệ thống này, chúng tôi thể hiện sự khác biệt đặc thù giữa các nhóm thuật toán:
- **Linear Regression:** Xuất sắc trong việc *extrapolation* (dự báo xu hướng đi lên tương lai) cho các chuỗi thời gian tuyến tính như dân số.
- **Tree-based Models (RF, GB):** Rất mạnh trong việc tìm quy luật phức tạp trong quá khứ (*interpolation*), nhưng có xu hướng "đi ngang" khi dự báo tương lai xa do bản chất của cây quyết định không thể vượt ngưỡng giá trị cao nhất đã học.
- **Metrics (RMSE/MAE):** Giúp người dùng biết được mô hình nào đã "học" sát với dữ liệu thực tế trong quá khứ nhất.

---

## Cấu Trúc Thư Mục
```text
.
├── python_backend/          # Backend AI (FastAPI)
│   ├── api/                 # Endpoints & Router
│   ├── domain/              # Business Entities & Interfaces
│   ├── infrastructure/      # Adapter cho ML Models & CSV
│   ├── use_cases/           # Logic nghiệp vụ dự đoán
│   └── data/                # Dataset dân số toàn cầu
└── flutter_app/             # Ứng dụng di động/web (Flutter)
    ├── lib/data/            # Models & API implementation
    ├── lib/domain/          # Core Business logic
    └── lib/presentation/    # UI & BLoC state management
```
