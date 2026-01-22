# KTMT Assignment — Gomoku Game (MIPS Assembly)

Mô tả
-----
Đây là đồ án trò chơi Gomoku (Caro) được triển khai hoàn toàn bằng Assembly cho kiến trúc MIPS với các chế độ như tính thời gian, đánh với máy, chế độ cờ thế. Yêu cầu của dự án là minh họa cách cài đặt logic trò chơi, quản lý bàn cờ và xử lý nhập liệu/hiển thị cơ bản trong ngôn ngữ Assembly, phục vụ cho bài tập lớn môn Kiến Trúc Máy Tính.

Ngôn ngữ
-------
- Assembly (MIPS) — mã nguồn cho kiến trúc MIPS.

Môi trường phát triển và chạy
----------------------------
- Trình mô phỏng/biên dịch: MARS (MIPS Assembler and Runtime Simulator).
- Phiên bản khuyến nghị: MARS 4.x trở lên.
- Chạy trên Java (MARS là một file JAR).

Tính năng chính
---------------
- Chơi hai người (local) trên cùng một máy (hot seat).
- Hiển thị bàn cờ bằng ký tự trong console của MARS.
- Phát hiện người chiến thắng khi có 5 quân liên tiếp theo hàng ngang, dọc hoặc chéo.
- Cho phép undo và đầu hàng.
- Xử lý nhập liệu từ người chơi thông qua cửa sổ console của MARS.
- Có rất nhiều chế độ:
  1. Chế độ custom: Người chơi có thể tuỳ chỉnh kích thước bàn cờ, số quân liên tiếp cần để chiến thắng
  2. Chế độ thời gian: Giảm thời gian cho mỗi nước đi
  3. Chế độ đánh với bot: Thuật toán đánh với máy đơn giản với 14 mức logic chọn lựa nước đi.
  4. Chế độ puzzle: Có sẵn các quân trên bàn cờ lúc bắt đầu (cờ thế)
- Kiến trúc và tổ chức mã theo mô-đun Assembly để dễ theo dõi cho mục đích học tập.

Hướng dẫn chạy (MARS)
---------------------
1. Tải MARS từ: http://courses.missouristate.edu/KenVollmar/mars/ (hoặc nguồn chính thức).
2. Mở MARS (jar file) bằng Java: java -jar Mars.jar
3. Trong MARS: File -> Open -> chọn file .asm chính của dự án (thường là file chứa nhãn bắt đầu, ví dụ: main.asm hoặc gomoku.asm).
4. Nhấn Assemble (hoặc Ctrl+L) để dịch mã.
5. Chọn Run -> Go (hoặc F5) để chạy chương trình.
6. Theo các hướng dẫn trên Console của MARS để nhập tọa độ hoặc lựa chọn. Chương trình sẽ yêu cầu nhập theo định dạng mà mã nguồn in ra (hãy xem phần comment trong mã nếu cần biết định dạng chính xác).

Ghi chú về nhập liệu
---------------------
- Dạng và cú pháp nhập tọa độ tùy thuộc vào cách triển khai trong mã (ví dụ: "x y" dưới dạng hai số nguyên, hoặc một mã ký tự + số).
- Nếu không chắc, kiểm tra thông báo trên console khi chương trình bắt đầu hoặc đọc comment ở file code chính (Assignment.asm).
