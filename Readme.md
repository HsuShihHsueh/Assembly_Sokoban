# Sokoban by 8086

 👇 youtube link<br>

<kbd><a href="https://www.youtube.com/watch?v=6fKehSFpv5g"><img src="http://img.youtube.com/vi/6fKdhSFpv5g/maxresdefault.jpg" width="700" style="border:2px #ccc solid;padding:5px;"></a></kbd><br> 


# masm資料容量限制

因為本程式使用MASM(Microsoft Macro Assembler)組合語言，在smal model下資料總長度不能超過64KB
![(規定)](https://books.google.com.tw/books?id=PhJRrlxoczMC&pg=PA129&lpg=PA129&dq=%E5%9F%B7%E8%A1%8C%E6%AA%94%E6%9C%80%E5%A4%A764KB%E7%84%A1%E6%B3%95%E5%9F%B7%E8%A1%8C&source=bl&ots=5pgt6LUs1M&sig=ACfU3U3F-JvcqfdIanJ6L1_FFPi4kOnCbg&hl=zh-TW&sa=X&ved=2ahUKEwiWydDL4fv1AhUGVpQKHbALDGQQ6AF6BAgTEAI#v=onepage&q=%E5%9F%B7%E8%A1%8C%E6%AA%94%E6%9C%80%E5%A4%A764KB%E7%84%A1%E6%B3%95%E5%9F%B7%E8%A1%8C&f=false)
，所以在第一版執行時發現當資料大小超出一點時，資料的結尾會發生毀損，如下圖，關卡八按鈕圖案毀損，因此檔案必需經過壓縮，而組合語言相較其他語言無法簡單的找到對應的函式庫，所以選擇的壓縮方式會以兼具易於撰寫及壓縮比來做選擇。

依上述需求實作了三種壓縮方法：
- Huffman Coding
- Huffman Code by Differential Coding
- Run Length Coing
最後選擇Run Length Coing做壓縮，並與比較現有的壓縮檔案如PNG、JPEG等比較壓縮比

# Huffman Coding

# Huffman Code by Differential Coding

# Run Length Coing



# 與現有壓縮檔案比較